import { CircleShape, window } from '@kit.ArkUI'
import { VideoModel } from '../../data/VideoModel'
import { AdActionUtil } from '../../utils/AdActionUtil'
import { VideoTimeUtil } from '../../utils/VideoTimeUtil'
import { JumpThreadAppState } from './ThreaWayAdView'
import { Params } from './TimeDownAndCloseView'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
enum  DialogLifeCycle{
   ON_NORMAL,
   ON_RESUME,
   ON_PAUSE,
   ON_DESTROYED
}
@Preview
@Component
export struct PrDialogContentView {
  @State jumpTime: number = 0
  @State intervalId: number = -1 //快捷键
  @Prop timeDown: number = 10
  @State time: number = 10
  @Prop params: Params
  @State optimizeType:number = 0
  @State lifeCycle:DialogLifeCycle = DialogLifeCycle.ON_NORMAL
  @Prop
  videoModel: VideoModel
  @State first: boolean = true
  @Watch('jumpThreadAppListener') @State
  jumpThreadAppState: JumpThreadAppState = JumpThreadAppState.JUMP_BEFORE

  aboutToAppear(): void {
    this.optimizeType = VideoTimeUtil.getOptimizeType(this.videoModel)
    if (this.optimizeType === 2 && this.first) {
        this.intervalId = setInterval(() => {
          if (this.lifeCycle === DialogLifeCycle.ON_RESUME || this.lifeCycle === DialogLifeCycle.ON_NORMAL) {
            this.timeDown -= 1
            if (this.timeDown == 0) {
              clearInterval(this.intervalId)
              this.params.onContinue()
            }
          }
        }, 1000)
      this.windowStageEvent()
    }
  }

  jumpThreadAppListener() {
    if (this.jumpThreadAppState === JumpThreadAppState.JUMP_START) {
      hilog.info(0x0000, 'testTag', `jumpThreadAppListener =${this.jumpThreadAppState}}`);
      this.jumpThreadAppState = JumpThreadAppState.JUMP_INTO_APP
      this.jumpTime = new Date().getTime()
    }
  }

  /**
   * 根据进入后台等进行相关状态操作。
   */
  private windowStageEvent() {
    let context = getContext(this) as common.UIAbilityContext;

    context.windowStage.on('windowStageEvent', async (data) => {
      let stageEventType: window.WindowStageEventType = data;
      switch (stageEventType) {
        case window.WindowStageEventType.SHOWN: // 切到前台
          hilog.info(0x0000, 'testTag', `windowStage SHOWN.`);
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_INTO_APP) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BACK
            this.time -= Math.floor((new Date().getTime() - this.jumpTime) / 1000)
          }
          this.lifeCycle = DialogLifeCycle.ON_RESUME
          break;
        case window.WindowStageEventType.ACTIVE: // 获焦状态
          hilog.info(0x0000, 'testTag', `windowStage active.`);
          this.lifeCycle = DialogLifeCycle.ON_RESUME
          break;
        case window.WindowStageEventType.INACTIVE: // 失焦状态
          hilog.info(0x0000, 'testTag', `windowStage inactive.`);
          this.lifeCycle = DialogLifeCycle.ON_PAUSE

          break;
        case window.WindowStageEventType.HIDDEN: // 切到后台
          hilog.info(0x0000, 'testTag', `windowStage background.`);
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
          }
          this.lifeCycle = DialogLifeCycle.ON_PAUSE
          break;
        case window.WindowStageEventType.RESUMED: // 前台可交互状态
          hilog.info(0x0000, 'testTag', `windowStage resumed.`);

          break;
        case window.WindowStageEventType.PAUSED: // 前台不可交互状态
          hilog.info(0x0000, 'testTag', `windowStage paused.`);
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
          }
          this.lifeCycle = DialogLifeCycle.ON_PAUSE
          break;
        default:
          break;
      }
    });
  }

  build() {
    Column() {
      Column() {
        Text("恭喜获得特权")
          .fontSize(22)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 50, bottom: 10 })
        Text("继续体验内容").margin({ top: 10, bottom: 10 })
        Row() {
          if (this.optimizeType === 1){
            Text(`${this.params.time}秒`).fontColor(Color.Blue)
          }else if (this.optimizeType === 2){
            Text(`${this.time}秒`).fontColor(Color.Blue)
          }

          Text("即可获得奖励")
        }

        Column() {
          Row() {
            Image($r('app.media.app_icon'))
              .clipShape(new CircleShape({ width: 40, height: 40 }))
              .size({ width: 40, height: 40 }).objectFit(ImageFit.Cover).margin({ right: 10 })
            Column() {
              Text("App 标题内容").fontSize(16).fontColor(Color.Black)
              Text("App 描述内容").fontSize(14).fontColor(Color.Gray).margin({ top: 10 })
            }.alignItems(HorizontalAlign.Start)
          }
          .width('90%')
          .padding({
            top: 15,
            bottom: 15,
            left: 15,
            right: 15
          })
          .alignItems(VerticalAlign.Center)
          .margin({ top: 30 })
          .backgroundColor('#1730a0ea')
          .border({ radius: 10 })

          Button(this.params.button)
            .fontSize(16)
            .fontColor(Color.White)
            .padding({ top: 18, bottom: 18 })
            .width('90%')
            .margin({ top: 25 })
            .onClick(() => {
              this.first = false
              clearInterval(this.intervalId)
              this.jumpOtherApp()
            })
          if (this.optimizeType === 2) {

              Text(`${this.timeDown}秒后继续播放视频`).margin(25).fontColor(Color.Gray).visibility(this.timeDown > 0?Visibility.Visible:Visibility.Hidden)

          } else {
            Text("浏览时间不足，无法提前获取奖励").margin(25).fontColor(Color.Gray)
          }
        }.alignItems(HorizontalAlign.Center)
      }
      .width('85%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Center)
      .border({ radius: 20 })

      Text("放弃特权")
        .padding({
          left: 24,
          right: 24,
          top: 6,
          bottom: 6
        })
        .fontSize(13)
        .fontColor(Color.White)
        .border({ radius: 25 })
        .backgroundColor('#e88d8d8d')
        .margin({ top: 20 })
        .onClick(() => {
          this.params.onAbandonCall()
        })
    }
  }

  private jumpOtherApp() {
    if (this.videoModel?.deeplinkUrl) {
      AdActionUtil.jumpOtherApp(this.videoModel?.deeplinkUrl).then(() => {
        if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
          this.jumpThreadAppState = JumpThreadAppState.JUMP_START
          this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
        } else if (VideoTimeUtil.getOptimizeType(this.videoModel) === 2) {
          this.jumpThreadAppState = JumpThreadAppState.JUMP_START
          this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
        }
      }).catch((e: Error) => {
        if (this.videoModel.appintro) {
          AdActionUtil.jumpOtherApp(this.videoModel?.appintro).then(() => {
            if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
              this.jumpThreadAppState = JumpThreadAppState.JUMP_START
              this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
            } else if (VideoTimeUtil.getOptimizeType(this.videoModel) === 2) {
              this.jumpThreadAppState = JumpThreadAppState.JUMP_START
              this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
            }
          }).catch((e: Error) => {
            if (this.videoModel?.landingPageUrl) {
              AdActionUtil.jumpToLandPage(this.videoModel?.landingPageUrl, "111").then(() => {
                if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                  if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                    this.jumpThreadAppState = JumpThreadAppState.JUMP_START
                    this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
                  } else if (VideoTimeUtil.getOptimizeType(this.videoModel) === 2) {
                    this.jumpThreadAppState = JumpThreadAppState.JUMP_START
                    this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
                  }
                }
              }).catch((e: Error) => {
                if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                  this.params.jumpAppStateCall(JumpThreadAppState.JUMP_FAIL)
                }
              })
            } else {
              this.params.jumpAppStateCall(JumpThreadAppState.JUMP_FAIL)
            }
          })
        } else {
          this.params.jumpAppStateCall(JumpThreadAppState.JUMP_FAIL)

        }
      })
    }
  }
}