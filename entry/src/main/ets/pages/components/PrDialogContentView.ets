import { CircleShape } from '@kit.ArkUI'
import { VideoModel } from '../../data/VideoModel'
import { AdActionUtil } from '../../utils/AdActionUtil'
import { VideoTimeUtil } from '../../utils/VideoTimeUtil'
import { JumpThreadAppState } from './ThreaWayAdView'
import { Params } from './TimeDownAndCloseView'

@Preview
@Component
export struct PrDialogContentView { //快捷键
  @Prop params: Params
  @Prop
  videoModel: VideoModel

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
          Text(`${this.params.time}秒`).fontColor(Color.Blue)
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

          Button("继续体验提前获取奖励")
            .fontSize(16)
            .fontColor(Color.White)
            .padding({ top: 18, bottom: 18 })
            .width('90%')
            .margin({ top: 25 })
            .onClick(() => {
              this.jumpOtherApp()
            })
          Text("浏览时间不足，无法提前获取奖励").margin(25).fontColor(Color.Gray)
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
        .onClick(()=>{
           this.params.onAbandonCall()
        })
    }
  }

  private jumpOtherApp() {
    if (this.videoModel?.deeplinkUrl) {
      AdActionUtil.jumpOtherApp(this.videoModel?.deeplinkUrl).then(() => {
        if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
          this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
        }
      }).catch((e: Error) => {
        if (this.videoModel.appintro) {
          AdActionUtil.jumpOtherApp(this.videoModel?.appintro).then(() => {
            this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
          }).catch((e: Error) => {
            if (this.videoModel?.landingPageUrl) {
              AdActionUtil.jumpToLandPage(this.videoModel?.landingPageUrl, "111").then(() => {
                if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                  this.params.jumpAppStateCall(JumpThreadAppState.JUMP_START)
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