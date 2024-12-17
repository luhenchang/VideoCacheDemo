import { VideoModel } from "../../data/VideoModel"
import { VideoTimeUtil } from "../../utils/VideoTimeUtil"
import { SendVideoState } from "../AMPSVideoCachePage"
import { JumpThreadAppState } from "./ThreaWayAdView"
import { buildText, GetRewardedState, Params, PrivilegeDialogStatus } from "./TimeDownAndCloseView"
import { common } from "@kit.AbilityKit"
import { ComponentContent, promptAction, router, window } from "@kit.ArkUI"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { throttle } from "../../utils/Threottle"
import { BusinessError } from "@kit.BasicServicesKit"

@Component
export struct TimeDownCloseOneView {
  @State
  jumpTime: number = 0
  @State
  optimizeTime: number = 0
  @State
  optimizeType: number = 0
  @Watch('updateViewModel')
  @Prop videoModel: VideoModel
  @Consume('videoState')
  videoState: SendVideoState
  @Watch('jumpThreadAppListener') @Consume('jumpThreadAppState')
  jumpThreadAppState: JumpThreadAppState
  @State timeDown: number = 0
  @State minTime: number = 0
  @State intervalId: number | undefined = undefined
  @State rewardState: GetRewardedState = GetRewardedState.NOT_OBTAINABLE
  @State intervalFlag: boolean = false
  @State plgDialogState: PrivilegeDialogStatus = PrivilegeDialogStatus.CLOSE

  aboutToAppear(): void {
    this.updateViewModel()
  }

  build() {
    Row() {
      if (this.rewardState === GetRewardedState.ALREADY_OBTAINED) {
        Text("已获得奖励").fontColor(Color.White).fontSize(14)
      } else {
        Text(this.minTime + "秒之后领取奖励").fontColor(Color.White).fontSize(14)
      }
      Text("  |  ").fontColor(Color.White)
      if (this.videoState === SendVideoState.COMPLETE) {
        Text("关闭").fontColor(Color.White).fontSize(14).onClick(throttle(() => {
          clearInterval(this.intervalId)
          router.back()
        }, 1000))
      } else {
        Text("跳过").fontColor(Color.White).fontSize(14).onClick(throttle(() => {
          if (this.rewardState === GetRewardedState.ALREADY_OBTAINED) {
            //去停止播放、弹出页面
            this.videoState = SendVideoState.COMPLETE
            clearInterval(this.intervalId)
          } else {
            if (this.videoState === SendVideoState.PLAYING) {
              this.videoState = SendVideoState.PAUSED
            }
            let uiContext = this.getUIContext();
            let promptAction = uiContext.getPromptAction();
            let title = "仅需" + this.minTime + "秒即可获得奖励"
            let sub = "确定要退出么"
            let contentNode =
              new ComponentContent(uiContext, wrapBuilder(buildText),
                new Params(title, sub, "",  0, this.videoModel, (state: JumpThreadAppState) => {
                  this.jumpThreadAppState = state
                }, () => {
                  if (this.videoState === SendVideoState.PAUSED) {
                    this.videoState = SendVideoState.PLAYING
                  }
                  promptAction.closeCustomDialog(contentNode)
                },()=>{}, () => {
                  promptAction.closeCustomDialog(contentNode)
                  clearInterval(this.intervalId)
                  router.back()
                }));
            let options: promptAction.BaseDialogOptions = {
              alignment: DialogAlignment.Center,
              isModal: true,
              maskColor: "#7e090909",
              autoCancel: false
            };
            try {
              promptAction.openCustomDialog(contentNode, options);
            } catch (error) {
              let message = (error as BusinessError).message;
              let code = (error as BusinessError).code;
              console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
            }
          }
        }, 1000))
      }
    }
  }

  updateViewModel() {
    if (!this.videoModel || this.intervalFlag === true) {
      return
    }
    this.optimizeType = VideoTimeUtil.getOptimizeType(this.videoModel)
    this.optimizeTime = VideoTimeUtil.getOptimizeTime(this.videoModel)
    //控制有且只有一次初始化【状态、timeDow、minTime、interval】
    this.intervalFlag = true
    this.videoState = SendVideoState.PLAYING
    this.timeDown = VideoTimeUtil.getTimeDown(this.videoModel)
    this.minTime = VideoTimeUtil.getMinTime(this.videoModel)
    this.intervalId = setInterval(() => {
      if (this.videoState != SendVideoState.PAUSED) {
        this.timeDown -= 1
        this.minTime -= 1

        if (this.minTime < 1) {
          this.rewardState = GetRewardedState.ALREADY_OBTAINED
        }
        if (this.timeDown < 1) {
          //去停止播放、弹出页面
          this.finishPlayAndJumpFullAd();
        }
      }
    }, 1000)
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
          hilog.info(0x0000, 'testTag', `windowStage foreground.`);
          if (this.videoState === SendVideoState.PAUSED) {
            this.videoState = SendVideoState.PLAYING;
          }
          break;
        case window.WindowStageEventType.ACTIVE: // 获焦状态
          hilog.info(0x0000, 'testTag', `windowStage active.`);
          break;
        case window.WindowStageEventType.INACTIVE: // 失焦状态
          hilog.info(0x0000, 'testTag', `windowStage inactive.`);

          break;
        case window.WindowStageEventType.HIDDEN: // 切到后台
          hilog.info(0x0000, 'testTag', `windowStage background.`);
          if (this.videoState === SendVideoState.PLAYING) {
            this.videoState = SendVideoState.PAUSED;
          }
          break;
        case window.WindowStageEventType.RESUMED: // 前台可交互状态
          hilog.info(0x0000, 'testTag', `windowStage resumed.`);
          if (this.videoState === SendVideoState.PAUSED) {
            this.videoState = SendVideoState.PLAYING;
          }
          break;
        case window.WindowStageEventType.PAUSED: // 前台不可交互状态
          hilog.info(0x0000, 'testTag', `windowStage paused.`);
          if (this.videoState === SendVideoState.PLAYING) {
            this.videoState = SendVideoState.PAUSED;
          }
          break;
        default:
          break;
      }
    });
  }

  jumpThreadAppListener(changedPropertyName: string) {
    if (this.jumpThreadAppState === JumpThreadAppState.JUMP_START) {
      hilog.info(0x0000, 'testTag', `jumpThreadAppListener =${this.jumpThreadAppState}}`);
      this.jumpThreadAppState = JumpThreadAppState.JUMP_INTO_APP
      this.jumpTime = new Date().getTime()
    }
  }

  //播放完成，或者已经获取奖励点击跳转==》显示广告页面
  private finishPlayAndJumpFullAd() {
    this.videoState = SendVideoState.COMPLETE;
    clearInterval(this.intervalId);
  }
}