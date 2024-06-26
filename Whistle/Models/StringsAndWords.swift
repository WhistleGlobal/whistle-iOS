//
//  StringsAndWords.swift
//  Whistle
//
//  Created by 박상원 on 10/30/23.
//

import Foundation
import SwiftUI

// MARK: - CommonWords

// 일반적인 단어
struct CommonWords {
  let confirm: LocalizedStringKey = "확인"
  let cancel: LocalizedStringKey = "취소"
  let next: LocalizedStringKey = "다음"
  let music: LocalizedStringKey = "음악"
  let volume: LocalizedStringKey = "볼륨"
  let done: LocalizedStringKey = "완료"
  let submit: LocalizedStringKey = "제출"
  let album: LocalizedStringKey = "앨범"
  let timer: LocalizedStringKey = "타이머"
  let following: LocalizedStringKey = "팔로잉"
  let follower: LocalizedStringKey = "팔로워"
  let follow: LocalizedStringKey = "팔로우"
  let whistle: LocalizedStringKey = "휘슬"
  let profile: LocalizedStringKey = "프로필"
  let play: LocalizedStringKey = "플레이"
  let bookmark: LocalizedStringKey = "북마크"
  let delete: LocalizedStringKey = "삭제"
  let deleteAccount: LocalizedStringKey = "계정삭제"
  let logout: LocalizedStringKey = "로그아웃"
  let setNotification: LocalizedStringKey = "알림 설정"
  let notification: LocalizedStringKey = "알림"
  let settings: LocalizedStringKey = "설정"
  let about: LocalizedStringKey = "약관 및 정책"
  let guideStatus: LocalizedStringKey = "가이드 상태"
  let share: LocalizedStringKey = "공유"
  let more: LocalizedStringKey = "더보기"
  let report: LocalizedStringKey = "신고"
  let reportAction: LocalizedStringKey = "신고하기"
  let block: LocalizedStringKey = "차단"
  let blockAction: LocalizedStringKey = "차단하기"
  let unblock: LocalizedStringKey = "차단 해제"
  let unblockAction: LocalizedStringKey = "차단 해제하기"
  let close: LocalizedStringKey = "닫기"
  let hide: LocalizedStringKey = "관심없음"
  let originalAudio: LocalizedStringKey = "원본 오디오"
  let shareProfile: LocalizedStringKey = "프로필 공유"
  let continueWord: LocalizedStringKey = "계속"
}

// MARK: - ProfileEditWords

struct ProfileEditWords {
  let edit: LocalizedStringKey = "프로필 편집"
  let userID: LocalizedStringKey = "사용자 ID"
  let intro: LocalizedStringKey = "소개"
  let photoEdit: LocalizedStringKey = "프로필 사진 수정"
  let albumUpload: LocalizedStringKey = "앨범에서 사진 업로드"
  let setDefaultImage: LocalizedStringKey = "기본 이미지로 변경"
  let recents: LocalizedStringKey = "최근 항목"
  let myTeamSelect: LocalizedStringKey = "마이팀 선택"
  let myTeamSkinSelect: LocalizedStringKey = "마이팀 스킨 설정"
  let showMyTeamFlag: LocalizedStringKey = "마이팀 플래그 표시"
  let showMyTeamProfileBackground: LocalizedStringKey = "마이팀 프로필 배경 표시"
  // "마이팀 플래그 표시" = "마이팀 플래그 표시";
  // "마이팀 프로필 배경 표시" = "마이팀 프로필 배경 표시";
}

// MARK: - VideoCaptureWords

struct VideoCaptureWords {
  let countdown: LocalizedStringKey = "카운트 다운"
  let setVideoLength: LocalizedStringKey = "영상 길이 설정"
  let setTimer: LocalizedStringKey = "타이머 설정"
  let disableTimer: LocalizedStringKey = "타이머 해제"
  let cameraSwitch: LocalizedStringKey = "화면 전환"
  let timerComment: LocalizedStringKey = "끌어서 이 영상의 길이를 선택하세요. 타이머를 설정하면 녹화가 시작되기 전에 카운트 다운이 실행됩니다."
}

// MARK: - VideoEditorWords

struct VideoEditorWords {
  let searchMusic: LocalizedStringKey = "음악 검색"
  let mutateVolume: LocalizedStringKey = "볼륨 조절"
  let originalSound: LocalizedStringKey = "원본 사운드"
  let musicSound: LocalizedStringKey = "추가된 음악 사운드"
  let setVolume: LocalizedStringKey = "음량 설정"
  let trimMusic: LocalizedStringKey = "음악 편집"
  let addMusic: LocalizedStringKey = "음악 추가"
  let editorComment: LocalizedStringKey = "최대 15초까지 동영상을 올릴 수 있어요."
  let musicTrimComment: LocalizedStringKey = "드래그하여 영상에 추가할 부분을 선택하세요."
}

// MARK: - ContentWords

struct ContentWords {
  let newContent: LocalizedStringKey = "새 게시물"
  let post: LocalizedStringKey = "게시"
  let noBookmarkedContent: LocalizedStringKey = "저장된 콘텐츠가 없습니다"
  let noConent: LocalizedStringKey = "콘텐츠가 없습니다"
  let noUploadedContent: LocalizedStringKey = "공유하고 싶은 첫번째 콘텐츠를 업로드해보세요"
  let goUpload: LocalizedStringKey = "업로드하러 가기"
  let uploadNow: LocalizedStringKey = "바로 업로드"
}

// MARK: - AlertTitles

struct AlertTitles {
  let block: LocalizedStringKey = "%@ 님을 차단하시겠어요?"
  let unblock: LocalizedStringKey = "%@ 님을 차단 해제하시겠어요?"
  let logout: LocalizedStringKey = "정말 로그아웃하시겠어요?"
  let removeAccount: LocalizedStringKey = "정말 삭제하시겠어요?"
  let setNotification: LocalizedStringKey = "휘슬 앱 알림이 허용되지 않았습니다.설정에서 알림을 켜시겠습니까?"
  let discardMedia: LocalizedStringKey = "영상을 삭제하시겠어요?"
  let stopEditing: LocalizedStringKey = "처음부터 시작하시겠어요?"
}

// MARK: - AlertContents

struct AlertContents {
  let unblock: LocalizedStringKey = "이제 상대방이 회원님의 게시물을 보거나 팔로우할 수 있습니다. 상대방에게 회원님이 차단을 해제했다는 정보를 알리지 않습니다."
  let block: LocalizedStringKey = "차단된 사람은 회원님의 프로필 또는 콘텐츠를 찾을 수 없게 되며, 상대방에게 차단되었다는 알림이 전송되지 않습니다."
  let removeAccount: LocalizedStringKey = "삭제하시면 회원님의 모든 정보와 활동 기록이 삭제됩니다. 삭제된 정보는 복구할 수 없으니 신중하게 결정해주세요."
  let discardMedia: LocalizedStringKey = "지금 돌아가면 변경 사항이 모두 삭제됩니다."
  let stopEditing: LocalizedStringKey = "지금 돌아가면 해당 작업물이 삭제됩니다."
}

// MARK: - AlertButtons

struct AlertButtons {
  let goSettings: LocalizedStringKey = "설정으로 가기"
  let continueEditing: LocalizedStringKey = "계속 수정"
  let stopEditing: LocalizedStringKey = "처음부터 시작"
  let discardMedia: LocalizedStringKey = "영상 삭제"
}

// MARK: - ToastMessages

struct ToastMessages {
  let undo: LocalizedStringKey = "실행 취소"
  let bookmark: LocalizedStringKey = "북마크에 저장했습니다"
  let bookmarkDeleted: LocalizedStringKey = "북마크를 취소했습니다"
  let contentDeleted: LocalizedStringKey = "삭제되었습니다"
  let profileImageUpdated: LocalizedStringKey = "프로필 사진이 수정되었습니다."
  let bioUpdated: LocalizedStringKey = "소개가 수정되었습니다."
  let usernameUpdated: LocalizedStringKey = "사용자 ID가 수정되었습니다."
  let contentUploaded: LocalizedStringKey = "영상이 게시되었습니다."
  let tagLimit: LocalizedStringKey = "해시태그는 최대 5개까지만 가능합니다"
  let tagLengthLimit: LocalizedStringKey = "해시태그는 최대 16글자까지 가능합니다"
  let postHidden: LocalizedStringKey = "해당 콘텐츠를 숨겼습니다"
}

// MARK: - NotificationWords

struct NotificationWords {
  let agreedTitle: LocalizedStringKey = "광고성 정보 알림 수신동의 안내"
  let disagreedTitle: LocalizedStringKey = "광고성 정보 알림 수신거부 안내"
}

// MARK: - SearchWords

struct SearchWords {
  let recentSearces: LocalizedStringKey = "최근 검색"
  let clearAll: LocalizedStringKey = "모두 지우기"
  let content: LocalizedStringKey = "콘텐츠"
  let account: LocalizedStringKey = "계정"
  let hashtag: LocalizedStringKey = "해시태그"
  let popular: LocalizedStringKey = "인기순"
  let recent: LocalizedStringKey = "최신순"
}
