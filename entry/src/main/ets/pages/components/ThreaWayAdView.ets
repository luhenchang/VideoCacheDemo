import { VideoContentInfo } from '../../data/VideoContentInfo'
import { VideoModel } from '../../data/VideoModel'
import { SendVideoState } from '../AMPSVideoCachePage'
import { CircleShape, RectShape } from '@kit.ArkUI'
import { AdActionUtil } from '../../utils/AdActionUtil'
import { VideoTimeUtil } from '../../utils/VideoTimeUtil'

export enum JumpThreadAppState {
  JUMP_BEFORE,
  JUMP_START,
  JUMP_INTO_APP,
  JUMP_BACK,
  JUMP_FAIL
}

@Component
export struct ThreeWayAdView {
  @Consume('videoState')
  videoState: SendVideoState
  @Prop
  videoModel: VideoModel
  @Prop
  videoContent: VideoContentInfo
  @Consume('jumpThreadAppState')
  jumpThreadAppState: JumpThreadAppState

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        if (this.videoModel && this.videoModel?.adResponse && this.videoModel?.adResponse.length > 0) {
          Column() {
            Row() {
              Image(this.videoContent?.appIcon)
                .clipShape(new CircleShape({ width: 50, height: 50 }))
                .size({ width: 50, height: 50 }).objectFit(ImageFit.Cover)
              Column() {
                Text(this.videoContent?.title).fontSize(14).fontColor(Color.White).margin({ top: 10 })
                Text(this.videoContent?.desc).fontSize(12).fontColor(Color.White).margin({ top: 10 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 5 })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .align(Alignment.Center)

            Row() {
              Image(this.videoModel?.adResponse[0].adLogo?.sourceUrl).width('10').height('10').margin({ right: 2 })
              Image(this.videoModel?.adResponse[0].adLogo?.adLabelUrl).width('22').height('10')
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding({
              left: 20,
              right: 20,
              top: 20,
              bottom: 20
            })

            Button("点击跳转网页或第三方应用")
              .fontSize(14)
              .type(ButtonType.Normal)
              .border({ radius: 5 })
              .fontColor(Color.White)
              .padding({ top: 14, bottom: 14 })
              .width('90%')
              .onClick(() => {
                this.jumpOtherApp()
              })
          }.width('100%')

          Text(this.videoModel?.adResponse[0].extInfo)
            .fontSize(6)
            .fontColor(Color.White)
            .size({ width: '100%' })
            .padding({
              left: 20,
              right: 20,
              bottom: 6,
              top: 20
            })
        }
      }
      .width('100%').margin({ bottom: 26 })

    }.width('100%').height('100%').alignContent(Alignment.BottomStart)
  }

  private jumpOtherApp() {
    if (this.videoModel?.deeplinkUrl) {
      AdActionUtil.jumpOtherApp(this.videoModel?.deeplinkUrl).then(() => {
        if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
          this.jumpThreadAppState = JumpThreadAppState.JUMP_START
        }
      }).catch((e: Error) => {
        if (this.videoModel.appintro) {
          AdActionUtil.jumpOtherApp(this.videoModel?.appintro).then(() => {
            this.jumpThreadAppState = JumpThreadAppState.JUMP_START
          }).catch((e: Error) => {
            if (this.videoModel?.landingPageUrl) {
              AdActionUtil.jumpToLandPage(this.videoModel?.landingPageUrl, "111").then(() => {
                if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                  this.jumpThreadAppState = JumpThreadAppState.JUMP_START
                }
              }).catch((e: Error) => {
                if (VideoTimeUtil.getOptimizeType(this.videoModel) === 1) {
                  this.jumpThreadAppState = JumpThreadAppState.JUMP_FAIL
                }
              })
            } else {
              this.jumpThreadAppState = JumpThreadAppState.JUMP_FAIL
            }
          })
        } else {
          this.jumpThreadAppState = JumpThreadAppState.JUMP_FAIL
        }
      })
    }
  }
}