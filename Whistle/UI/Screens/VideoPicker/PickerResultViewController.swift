////
////  PickerResultViewController.swift
////  Whistle
////
////  Created by 박상원 on 2023/09/20.
////
//
// import AVKit
// import UIKit
// import VideoPicker
//
//// MARK: - PickerResultViewController
//
// final class PickerResultViewController: UIViewController {
//  var assets: [Asset] = []
//
//  private lazy var collectionView: UICollectionView = {
//    let layout = UICollectionViewFlowLayout()
//    layout.minimumInteritemSpacing = 10
//    layout.minimumLineSpacing = 10
//    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
//    view.register(PickerPreviewCell.self, forCellWithReuseIdentifier: "PreviewCell")
//    view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 10, right: 16)
//    if #available(iOS 13.0, *) {
//      view.backgroundColor = .systemGray
//    } else {
//      view.backgroundColor = .white
//    }
//    view.dataSource = self
//    view.delegate = self
//    return view
//  }()
//
//  deinit {
//    print("PickerResultViewController deinit")
//  }
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    setupView()
//  }
//
//  private func setupView() {
//    view.addSubview(collectionView)
//    collectionView.snp.makeConstraints { maker in
//      maker.edges.equalToSuperview()
//    }
//  }
// }
//
//// MARK: UICollectionViewDataSource
//
// extension PickerResultViewController: UICollectionViewDataSource {
//  func numberOfSections(in _: UICollectionView) -> Int {
//    1
//  }
//
//  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
//    assets.count
//  }
//
//  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! PickerPreviewCell
//    cell.imageView.image = assets[indexPath.item].image
//    cell.titleLabel.text = assets[indexPath.item].mediaType.description
//    return cell
//  }
// }
//
//// MARK: UICollectionViewDelegate
//
// extension PickerResultViewController: UICollectionViewDelegate {
//  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let asset = assets[indexPath.item]
//    switch asset.mediaType {
//    case .video:
//      let alert = UIAlertController(title: "Processing", message: nil, preferredStyle: .alert)
//      let options = VideoURLFetchOptions(fetchProgressHandler: { progress, _, _, _ in
//        DispatchQueue.main.async {
//          alert.message = "Fetching \(String(format: "%0.1f %", progress * 100))"
//        }
//      }, exportPreset: .h264_1280x720) { progress in
//        DispatchQueue.main.async {
//          alert.message = "Exporting \(String(format: "%0.1f %", progress * 100))"
//        }
//      }
//      present(alert, animated: true, completion: nil)
//      asset.fetchVideoURL(options: options) { result, _ in
//        switch result {
//        case .success(let response):
//          alert.title = "Result"
//          alert.message = response.url.absoluteString
//          alert.addAction(UIAlertAction(title: "Watch", style: .default, handler: { [weak self] _ in
//            guard let self else { return }
//            let player = AVPlayer(url: response.url)
//            let controller = AVPlayerViewController()
//            controller.player = player
//            controller.modalPresentationStyle = .fullScreen
//            present(controller, animated: true) {
//              player.playImmediately(atRate: 1)
//            }
//          }))
//          alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
//        case .failure(let error):
//          print(error)
//        }
//      }
//    default:
//      let alert = UIAlertController(title: "Detail", message: asset.description, preferredStyle: .alert)
//      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//      present(alert, animated: true, completion: nil)
//    }
//  }
// }
//
//// MARK: UICollectionViewDelegateFlowLayout
//
// extension PickerResultViewController: UICollectionViewDelegateFlowLayout {
//  func collectionView(
//    _ collectionView: UICollectionView,
//    layout _: UICollectionViewLayout,
//    sizeForItemAt _: IndexPath)
//    -> CGSize
//  {
//    let width = floor((collectionView.bounds.width - 20 - 10 * 2) / 3)
//    return CGSize(width: width, height: width)
//  }
// }
