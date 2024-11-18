import { VideoContentInfo } from '../../data/VideoContentInfo'
import { VideoModel } from '../../data/VideoModel'
import { SendVideoState } from '../AMPSVideoCachePage'
import { CircleShape } from '@kit.ArkUI'
import { AdActionUtil } from '../../utils/AdActionUtil'

@Component
export struct VideoCompletedView {
  @Consume('videoState')
  videoState: SendVideoState
  @Prop
  videoModel: VideoModel
  @Prop
  videoContent: VideoContentInfo

  build() {
    if (this.videoState === SendVideoState.COMPLETE) {
      Stack({ alignContent: Alignment.Center }) {
        //1、高斯模糊蒙版
        Image(this.videoContent?.lauchImageUrl)
          .blur(66)// 使用blur接口为照片组件添加内容模糊效果
          .height('100%')
          .width("100%")
          .objectFit(ImageFit.Cover)
        //2、增加高斯模式的黑暗程度
        Flex().height('100%')
          .width("100%")
          .backgroundColor($r('sys.color.mask_secondary'))
        //3、显示内容
        Column() {
          if (this.videoModel && this.videoModel?.adResponse && this.videoModel?.adResponse.length > 0) {
            Column() {
              Image(this.videoContent?.appIcon)
                .clipShape(new CircleShape({ width: 90, height: 90 }))
                .size({ width: 90, height: 90 }).objectFit(ImageFit.Cover)
              Text(this.videoContent?.title).fontSize(16).fontColor(Color.White).margin({ top: 10 })
              Text(this.videoContent?.desc).fontSize(14).fontColor(Color.White).margin({ top: 10 })
              Button("点击跳转网页或第三方应用")
                .fontSize(14)
                .fontColor(Color.White)
                .padding({ top: 14, bottom: 14 })
                .width('90%')
                .margin({ top: 25 })
                .onClick(() => {
                  if (this.videoModel?.deeplinkUrl) {
                    AdActionUtil.jumpOtherApp(this.videoModel?.deeplinkUrl).catch((e: Error) => {
                      if (this.videoModel.appintro) {
                        AdActionUtil.jumpOtherApp(this.videoModel?.appintro)
                      }
                    })
                  }
                })
            }.layoutWeight(1).alignItems(HorizontalAlign.Center).padding({ top: '45%' })

            Row() {
              Image(this.videoModel?.adResponse[0].adLogo?.sourceUrl).width('10').height('10').margin({ right: 2 })
              Image(this.videoModel?.adResponse[0].adLogo?.adLabelUrl).width('22').height('10')
            }.width('100%').justifyContent(FlexAlign.End).padding(16)

            Text(this.videoModel?.adResponse[0].extInfo)
              .fontSize(6)
              .fontColor(Color.White)
              .size({ width: '100%' })
              .padding({ left: 20, bottom: 6 })
          }
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)

      }.width('100%').height('100%').alignContent(Alignment.Center)
    }
  }
}