import { ComponentContent, promptAction, PromptAction, router, window } from '@kit.ArkUI';
import { VideoContentInfo } from '../../data/VideoContentInfo';
import { VideoModel } from '../../data/VideoModel';
import { VideoTimeUtil } from '../../utils/VideoTimeUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { throttle } from '../../utils/Threottle';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SendVideoState } from '../AMPSVideoCachePage';
import { JumpThreadAppState } from './ThreaWayAdView';
import { PrDialogContentView } from './PrDialogContentView';

export enum GetRewardedState {
  NOT_OBTAINABLE, //默认没有获得奖励
  NOW_GET_REWARDED, //立即获取奖励
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
  jumpTime: number = 0
  @State
  optimizeTime: number = 0
  @State
  showTime: number = 0
  @State
  optimizeType: number = 0
  @Watch('updateViewModel')                                @Prop videoModel: VideoModel
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

  aboutToDisappear(): void {
    let context = getContext(this) as common.UIAbilityContext;
    this.rewardState = GetRewardedState.NOT_OBTAINABLE
    this.videoState = SendVideoState.COMPLETE;
    context.windowStage.off('windowStageEvent')
    clearInterval(this.intervalId);
  }

  //播放完成，或者已经获取奖励点击跳转==》显示广告页面
  private finishPlayAndJumpFullAd() {
    this.videoState = SendVideoState.COMPLETE;
    clearInterval(this.intervalId);
  }

  build() {
    if (this.videoModel)
    Row() {
      if (this.optimizeType === 0) {
        if (this.rewardState === GetRewardedState.ALREADY_OBTAINED) {
          Text("已获得奖励").fontColor(Color.White).fontSize(14)
        } else {
          Text(this.minTime + "秒之后领取奖励").fontColor(Color.White).fontSize(14)
        }
      } else if (this.optimizeType === 1) {
        if (this.rewardState === GetRewardedState.ALREADY_OBTAINED) {
          Text("🎁 已获得奖励").fontColor(Color.White).fontSize(14)
        } else if (this.rewardState === GetRewardedState.NOW_GET_REWARDED) {
          Text("🎁 立即领取").fontColor(Color.White).fontSize(14)
        } else {
          Text("🎁 " + this.optimizeTime + "秒后点击广告可领取奖励").fontColor(Color.White).fontSize(14)
        }
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
                new Params(title, sub, 0, this.videoModel, (state: JumpThreadAppState) => {
                  this.jumpThreadAppState = state
                }, () => {
                  if (this.videoState === SendVideoState.PAUSED) {
                    this.videoState = SendVideoState.PLAYING
                  }
                  promptAction.closeCustomDialog(contentNode)
                }, () => {

                }, () => {
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
    console.info("aboutToApper videoModel====" + this.videoModel + "==flag=" + this.intervalFlag)
    if (!this.videoModel || this.intervalFlag === true) {
      return
    }
    this.optimizeType = VideoTimeUtil.getOptimizeType(this.videoModel)
    this.optimizeTime = VideoTimeUtil.getOptimizeTime(this.videoModel)
    this.showTime = VideoTimeUtil.getShowTime(this.videoModel)
    //控制有且只有一次初始化【状态、timeDow、minTime、interval】
    this.intervalFlag = true
    this.videoState = SendVideoState.PLAYING
    this.timeDown = VideoTimeUtil.getTimeDown(this.videoModel)
    this.minTime = VideoTimeUtil.getMinTime(this.videoModel)
    if (this.optimizeType === 0) {
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
    } else if (this.optimizeType === 1) {
      this.intervalId = setInterval(() => {
        if (this.videoState != SendVideoState.PAUSED) {
          this.timeDown -= 1
          this.minTime -= 1
          if (this.optimizeTime > 0) {
            this.optimizeTime -= 1
          }
          console.log("this.optimizeTime==" + this.optimizeTime)
          if (this.optimizeTime === 0 && this.rewardState === GetRewardedState.NOT_OBTAINABLE) {
            this.rewardState = GetRewardedState.NOW_GET_REWARDED
          }
          if (this.minTime < 1) {
            this.rewardState = GetRewardedState.ALREADY_OBTAINED
          }

          if (this.timeDown < 1) {
            //去停止播放、弹出页面
            this.finishPlayAndJumpFullAd();
          }
        }

      }, 1000)
    } else if (this.optimizeType === 2) {

    }
    if (this.optimizeType === 0) {
      this.windowStageEvent();
    } else if (this.optimizeType === 1) {
      console.log("注册次数")
      this.windowStageEventTypeOne()
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

  /**
   * 根据进入后台等进行相关状态操作。
   */
  private windowStageEventTypeOne() {
    let context = getContext(this) as common.UIAbilityContext;
    context.windowStage.on('windowStageEvent', async (data) => {
      let stageEventType: window.WindowStageEventType = data;
      switch (stageEventType) {
        case window.WindowStageEventType.SHOWN: // 切到前台
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_INTO_APP) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BACK
          }
          if (this.videoState === SendVideoState.PAUSED) {
            //1、如果是进入了落地页或则三方应用
            if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
              //1、1如果立即获得奖励==》特权弹窗显示
              if (this.rewardState === GetRewardedState.NOW_GET_REWARDED) {
                hilog.info(0x0000, 'testTag 弹出来', "privilegeDialogAd");
                //确定弹窗是关闭状态再弹出，可能用户没关闭退出后台，此时也需要
                if (this.plgDialogState === PrivilegeDialogStatus.CLOSE) {
                  this.privilegeDialogAd()
                }
                //1、2如果是没有奖励或已经获得了奖励  ==》让其正常播放
              } else if (this.rewardState === GetRewardedState.NOT_OBTAINABLE ||
                this.rewardState === GetRewardedState.ALREADY_OBTAINED) {
                this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
                this.videoState = SendVideoState.PLAYING
              }
              //2、非进入三方APP或者落地页，常规处理即可
            } else {
              if (this.plgDialogState === PrivilegeDialogStatus.CLOSE) {
                this.videoState = SendVideoState.PLAYING;
              }
            }
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
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
          }
          break;
        case window.WindowStageEventType.RESUMED: // 前台可交互状态
          hilog.info(0x0000, 'testTag', `windowStage resumed.`);
          if (this.videoState === SendVideoState.PAUSED) {
            if (this.plgDialogState === PrivilegeDialogStatus.CLOSE) {
              this.videoState = SendVideoState.PLAYING;
            }
          }

          break;
        case window.WindowStageEventType.PAUSED: // 前台不可交互状态
          hilog.info(0x0000, 'testTag', `windowStage paused.`);
          if (this.videoState === SendVideoState.PLAYING) {
            this.videoState = SendVideoState.PAUSED;
          }
          if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
          }
          break;
        default:
          break;
      }
    });
  }

  jumpThreadAppListener() {
    if (this.jumpThreadAppState === JumpThreadAppState.JUMP_START) {
      hilog.info(0x0000, 'testTag', `jumpThreadAppListener =${this.jumpThreadAppState}}`);
      this.jumpThreadAppState = JumpThreadAppState.JUMP_INTO_APP
      this.jumpTime = new Date().getTime()
    }
  }

  privilegeDialogAd() {
    if (this.jumpThreadAppState === JumpThreadAppState.JUMP_BACK) {
      let uiContext = this.getUIContext();
      let promptAction = uiContext.getPromptAction();
      let title = "恭喜获得特权"
      let sub = "继续体验内容"
      this.showTime -= Math.floor((new Date().getTime() - this.jumpTime) / 1000)
      if (this.showTime <= 0) {
        this.videoState = SendVideoState.COMPLETE;
        this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
        this.rewardState = GetRewardedState.ALREADY_OBTAINED
        clearInterval(this.intervalId);
        return
      }
      let contentNode =
        new ComponentContent(uiContext, wrapBuilder(MPrDialogContentView),
          new Params(title, sub, this.showTime, this.videoModel, (state: JumpThreadAppState) => {
            this.plgDialogState === PrivilegeDialogStatus.CLOSE
            this.jumpThreadAppState = state
            promptAction.closeCustomDialog(contentNode).then(() => {
              this.plgDialogState = PrivilegeDialogStatus.CLOSE
            })
          }, () => {
            if (this.videoState === SendVideoState.PAUSED) {
              this.videoState = SendVideoState.PLAYING
            }
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
            hilog.info(0x0000, 'testTag', `privilegeDialogAd closeDialog =${this.jumpThreadAppState}}`);
            promptAction.closeCustomDialog(contentNode).then(() => {
              this.plgDialogState = PrivilegeDialogStatus.CLOSE
            })
          }, () => {
            //放弃特权
            this.showTime = VideoTimeUtil.getShowTime(this.videoModel)
            if (this.videoState === SendVideoState.PAUSED) {
              this.videoState = SendVideoState.PLAYING
            }
            this.jumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
            promptAction.closeCustomDialog(contentNode).then(() => {
              this.plgDialogState = PrivilegeDialogStatus.CLOSE
            })
          }, () => {
            promptAction.closeCustomDialog(contentNode).then(() => {
              this.plgDialogState = PrivilegeDialogStatus.CLOSE
            })
            clearInterval(this.intervalId)
            router.back()
          }));
      let options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        isModal: true,
        maskColor: "#7e090909",
        autoCancel: false,
        onWillDismiss: () => {
        }
      };
      try {
        promptAction.openCustomDialog(contentNode, options).then(() => {
          this.plgDialogState = PrivilegeDialogStatus.OPENING
        });
      } catch (error) {
        let message = (error as BusinessError).message;
        let code = (error as BusinessError).code;
        console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
      }
    }
  }
}

export class Params {
  title: string = '';
  sub: string = ''
  time: number
  videoModel: VideoModel | undefined
  onClose: () => void
  onContinue: () => void
  onAbandonCall: () => void
  jumpAppStateCall: (state: JumpThreadAppState) => void

  constructor(text: string, sub: string, time: number, videoModel: VideoModel | undefined,
    jumpAppStateCall: (state: JumpThreadAppState) => void, onContinue: () => void, onAbandonCall: () => void,
    onClose: () => void) {
    this.title = text
    this.sub = sub
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

@Builder
function MPrDialogContentView(params: Params): void {
  PrDialogContentView({ params, videoModel: params.videoModel })
}
