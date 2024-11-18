@Observed
export class VideoModel {
  adResponse?: AdResponse[]
  minTime?: number
  mute?: boolean
  deeplinkUrl?: string
  appintro?: string
  landingPageUrl?:string
}

export class AdResponse {
  extInfo?: string
  contentInfo?: ContentInfo[]
  rewardedVideo?: RewardedVideo
  adLogo?: AdLogo
  adid?: string
  price?: string
  adverName?: string
  expireSec?: number
}

export class AdLogo {
  adLabelUrl?: string
  adLabel?: string
  sourceUrl?: string
  sourceLabel?: string
}

export class RewardedVideo {
  optimizeType?: number //0、1、2
  optimizeTime?: number
  showTime?: number
  awardTime?: number
}

export class ContentInfo {
  renderType?: number
  template?: string
}
