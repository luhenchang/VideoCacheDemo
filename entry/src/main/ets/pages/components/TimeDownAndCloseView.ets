import { VideoModel } from '../../data/VideoModel';
import { VideoTimeUtil } from '../../utils/VideoTimeUtil';
import { JumpThreadAppState } from './ThreaWayAdView';
import { TimeDownCloseOneView } from './TimeDownCloseOneView';
import { TimeDownCloseThreeView } from './TimeDownCloseThreeView';
import { TimeDownCloseTwoView } from './TimeDownCloseTwoView';


export enum GetRewardedState {
  NOT_OBTAINABLE,
  DIALOG_NOTIFY_GET_REWARD,
  NOW_GET_REWARDED,
  ALREADY_OBTAINED //已经获得了奖励
}

//privilegePopUpStatus
export enum PrivilegeDialogStatus {
  OPENING,
  CLOSE
}

@Preview
@Component
export struct TimeDownAndCloseView {
  @State
  optimizeType: number = -1
  @Watch('updateViewModel')
  @Prop videoModel: VideoModel
  aboutToAppear(): void {
    this.updateViewModel()
  }
  build() {
    if (this.videoModel)
    Row() {
      if (this.optimizeType === 0) {
        TimeDownCloseOneView({ videoModel: this.videoModel })
      } else if (this.optimizeType === 1) {
        TimeDownCloseTwoView({ videoModel: this.videoModel })
      }else if (this.optimizeType ===2){
        TimeDownCloseThreeView({ videoModel: this.videoModel })
      }
    }
    .padding({
      left: 10,
      right: 10,
      top: 4,
      bottom: 4
    })
    .backgroundColor("#5b1d1d1d")
    .border({ radius: 20, color: "#baefecec", width: 0.85 })
  }

  updateViewModel() {
    if (!this.videoModel) {
      return
    }
    this.optimizeType = VideoTimeUtil.getOptimizeType(this.videoModel)
  }
}

export class Params {
  title: string = '';
  sub: string = ''
  button:string = ''
  time: number
  videoModel: VideoModel | undefined
  onClose: () => void
  onContinue: () => void
  onAbandonCall: () => void
  jumpAppStateCall: (state: JumpThreadAppState) => void

  constructor(text: string, sub: string,button:string, time: number, videoModel: VideoModel | undefined,
    jumpAppStateCall: (state: JumpThreadAppState) => void, onContinue: () => void, onAbandonCall: () => void,
    onClose: () => void) {
    this.title = text
    this.sub = sub
    this.button = button
    this.time = time
    this.videoModel = videoModel
    this.onContinue = onContinue
    this.jumpAppStateCall = jumpAppStateCall
    this.onClose = onClose
    this.onAbandonCall = onAbandonCall
  }
}

@Builder
export function buildText(params: Params) {
  Column() {
    Text(params.title)
      .fontSize(16).margin({ top: 15 })
    Text(params.sub)
      .fontSize(16).margin({ top: 15 })
    Button("继续观看").width('100%').fontSize(14).margin({ top: 20 }).onClick(() => {
      params.onContinue()
    })
    Text("关闭广告")
      .fontSize(14)
      .fontColor(Color.Gray)
      .margin({ top: 20, bottom: 15 })
      .onClick(() => {
        params.onClose()
      })
  }
  .width('80%')
  .padding(24)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius(24)
}