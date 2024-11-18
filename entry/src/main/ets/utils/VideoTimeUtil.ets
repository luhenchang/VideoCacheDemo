import { VideoContentInfo } from '../data/VideoContentInfo'
import { VideoModel } from '../data/VideoModel'

export class VideoTimeUtil {
  static getShowTime(videoModel: VideoModel): number {
    if (videoModel.adResponse && videoModel.adResponse.length > 0) {
      return videoModel.adResponse[0].rewardedVideo?.showTime ?? 0
    }
    return 0
  }
  static getOptimizeType(videoModel: VideoModel): number {
    if (videoModel.adResponse && videoModel.adResponse.length > 0) {
      return videoModel.adResponse[0].rewardedVideo?.optimizeType ?? 0
    }
    return 0
  }

  static getOptimizeTime(videoModel: VideoModel): number {
    if (videoModel.adResponse && videoModel.adResponse.length > 0) {
      return videoModel.adResponse[0].rewardedVideo?.optimizeTime ?? 0
    }
    return 0
  }

  static getTimeDown(videoModel: VideoModel): number {
    let timeDown = 0
    if (videoModel.adResponse && videoModel.adResponse.length > 0) {
      if (videoModel.adResponse[0].contentInfo && videoModel.adResponse[0].contentInfo.length > 0) {
        let template = videoModel.adResponse[0].contentInfo[0].template
        if (template) {
          let contentInfo = JSON.parse(template) as VideoContentInfo
          if (videoModel.minTime) {
            if (videoModel.minTime > Number(contentInfo.videoTime)) {
              timeDown = videoModel.minTime
            } else {
              timeDown = Number(contentInfo.videoTime)
            }
          }
        }
      }
    }
    return timeDown
  }

  static getVideoContentInfo(videoModel: VideoModel): VideoContentInfo | undefined {
    let contentInfo: VideoContentInfo | undefined = undefined
    if (videoModel.adResponse && videoModel.adResponse.length > 0) {
      if (videoModel.adResponse[0].contentInfo && videoModel.adResponse[0].contentInfo.length > 0) {
        let template = videoModel.adResponse[0].contentInfo[0].template
        if (template) {
          contentInfo = JSON.parse(template) as VideoContentInfo
        }
      }
    }
    return contentInfo
  }

  static getMinTime(videoModel: VideoModel): number {
    return videoModel.minTime ?? 1
  }
}