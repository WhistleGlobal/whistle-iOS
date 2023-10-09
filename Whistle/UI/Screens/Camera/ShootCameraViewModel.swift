import AVFoundation
import Foundation
import Photos

// MARK: - ShootCameraViewModel

class ShootCameraViewModel: NSObject, ObservableObject {
  let session: AVCaptureSession
  @Published var preview: Preview?
  @Published var recordedVideoURL: URL?
  @Published var isRecording = false
  @Published var isCameraAuthorized = false
  @Published var isMicrophoneAuthorized = false

  override init() {
    session = AVCaptureSession()
    super.init()
    initializeCamera()
  }

  func initializeCamera() {
    Task(priority: .background) {
      switch await AuthorizationChecker.checkAccess() {
      case (let cameraAuthorized, let albumAuthorized, let microphoneAuthorized):
        if cameraAuthorized, albumAuthorized, microphoneAuthorized {
          do {
            try setupCamera()
          } catch {
            print("Error setting up AVCaptureSession: \(error)")
          }
        } else { }
      }
    }
  }

  private func setupCamera() throws {
    guard let videoDevice = AVCaptureDevice.default(for: .video) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    let videoInput = try AVCaptureDeviceInput(device: videoDevice)
    guard session.canAddInput(videoInput) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    session.beginConfiguration()
    session.addInput(videoInput)

    // Add movie file output
    let fileOutput = AVCaptureMovieFileOutput()
    guard session.canAddOutput(fileOutput) else {
      throw VideoError.device(reason: .unableToSetOutput)
    }
    session.addOutput(fileOutput)
    session.commitConfiguration()

    session.startRunning()
    DispatchQueue.main.async {
      self.preview = Preview(session: self.session, gravity: .resizeAspectFill)
    }
  }

  func startCameraPreview() {
    if !session.isRunning, !isRecording {
      session.startRunning()
    }
  }

  func stopCameraPreview() {
    if session.isRunning, !isRecording {
      session.stopRunning()
    }
  }

  func startRecording() {
    guard let output = session.movieFileOutput else {
      print("Cannot find movie file output")
      return
    }

    isRecording = true

    guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("Cannot access local file domain")
      return
    }

    let fileName = UUID().uuidString
    let filePath = directoryPath.appendingPathComponent(fileName).appendingPathExtension("mp4")

    output.startRecording(to: filePath, recordingDelegate: self)
    preview?.previewLayer.connection?.isEnabled = true
  }

  func stopRecording() {
    guard let output = session.movieFileOutput else {
      print("Cannot find movie file output")
      return
    }

    isRecording = false
    output.stopRecording()
  }

  func toggleCameraDirection() {
    guard let currentVideoInput = session.inputs.first as? AVCaptureDeviceInput else {
      print("No video inputs found.")
      return
    }

    let currentPosition = currentVideoInput.device.position
    let newCameraPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

    if
      let newVideoDevice = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: newCameraPosition).devices.first
    {
      do {
        let newVideoInput = try AVCaptureDeviceInput(device: newVideoDevice)

        session.beginConfiguration()
        session.removeInput(currentVideoInput)
        if session.canAddInput(newVideoInput) {
          session.addInput(newVideoInput)
        } else {
          print("Could not add the new video input to the session")
        }
        session.commitConfiguration()
      } catch {
        print("Error creating AVCaptureDeviceInput: \(error)")
      }
    }
  }
}

// MARK: AVCaptureFileOutputRecordingDelegate

extension ShootCameraViewModel: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(
    _: AVCaptureFileOutput,
    didFinishRecordingTo outputFileURL: URL,
    from _: [AVCaptureConnection],
    error _: Error?)
  {
    print("Video recording completed!")
    recordedVideoURL = outputFileURL

    if !isRecording {
      startCameraPreview()
    }
  }
}

extension AVCaptureSession {
  var movieFileOutput: AVCaptureMovieFileOutput? {
    outputs.first as? AVCaptureMovieFileOutput
  }

  func addMovieInput() throws -> Self {
    guard let videoDevice = AVCaptureDevice.default(for: .video) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    let videoInput = try AVCaptureDeviceInput(device: videoDevice)
    guard canAddInput(videoInput) else {
      throw VideoError.device(reason: .unableToSetInput)
    }

    addInput(videoInput)
    return self
  }

  func addMovieFileOutput() throws -> Self {
    guard movieFileOutput == nil else {
      return self
    }

    let fileOutput = AVCaptureMovieFileOutput()
    guard canAddOutput(fileOutput) else {
      throw VideoError.device(reason: .unableToSetOutput)
    }

    addOutput(fileOutput)
    return self
  }
}
