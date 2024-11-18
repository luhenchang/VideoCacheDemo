import { AMPSVideoCacheView } from './AMPSVideoCacheView';
import { systemDateTime } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';
import { router } from '@kit.ArkUI';
import { VideoCacheUtil } from './VideoCachUtil';

//let originUrl = "http://vjs.zencdn.net/v/oceans.mp4"
//可用视频
//https://media.w3.org/2010/05/sintel/trailer.mp4
//http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4  //长视频
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State videoUrl: string | undefined = undefined
  controller: VideoController = new VideoController()
  lastTime: number = 0

  async aboutToAppear(): Promise<void> {
    this.lastTime = systemDateTime.getTime()
    http.createHttp().request('url', {})
  }

  build() {
    Column() {
      Button("点击视频播放-AMPSVideo").onClick(() => {
        router.pushUrl({
          url: "pages/AMPSVideoCachePage",
          params: {
            videoUrl: "https://adhub-assc-file.oss-cn-beijing.aliyuncs.com/83627c5cfea69ed2188452a3e2258de8.mp4"//"http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4"//"https://adhub-assc-file.oss-cn-beijing.aliyuncs.com/83627c5cfea69ed2188452a3e2258de8.mp4"//"https://img.tukuppt.com/video_show/2418175/00/44/50/603eda4ce3c22.mp4"
          }
        })
      })
      Button("点击视频播放-HttpsPlayer").onClick(() => {
        router.pushUrl({
          url: "pages/HttpsPlayer",
          params: {
            videoUrl: "https://img.tukuppt.com/video_show/2418175/00/44/50/603eda4ce3c22.mp4"
          }
        })
      }).margin({ top: 20 })

      Button("点击删除视频缓存").onClick(() => {
        VideoCacheUtil.clearVideoCache(getContext().cacheDir + "/" + "video-cache")
      }).margin({ top: 20 })
      //https://img.tukuppt.com/video_show/2418175/00/44/50/603ed9a7b21b7.mp4 熊猫
      //https://img.tukuppt.com/video_show/2418175/00/44/50/603eda4ce3c22.mp4

      //https://media.w3.org/2010/05/sintel/trailer.mp4
      //https://adhub-assc-file.oss-cn-beijing.aliyuncs.com/83627c5cfea69ed2188452a3e2258de8.mp4//ASNP
      //http://1251017968.vod2.myqcloud.com/3eb04eefvodtransgzp1251017968/8782b1285285890810009576163/v.f30.mp4//16分钟
      //https://adhub-assc-file.oss-cn-beijing.aliyuncs.com/83627c5cfea69ed2188452a3e2258de8.mp4
      //http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4 //缓存结束才会播放？
      //AMPSVideoCacheView({videoName:"https://adhub-assc-file.oss-cn-beijing.aliyuncs.com/83627c5cfea69ed2188452a3e2258de8.mp4"})
      //https://vjs.zencdn.net/v/oceans.mp4  //android播放很慢的一个
      //Video({ src: "https://vjs.zencdn.net/v/oceans.mp4" })
      //   .width('100%')
      //   .height('100%')
      //   .id('HelloWorld')
      //   .autoPlay(true)
      //   .onStart(()=>{
      //     console.log('time onStart==='+(systemDateTime.getTime()-this.lastTime))
      //   })
      //   .onVisibleAreaChange([0, 0.6], (isVisible: boolean, currentRatio: number) => {
      //     console.log('time==='+(systemDateTime.getTime()-this.lastTime))
      //     if (isVisible && currentRatio >= 0.6) {
      //       this.controller.start()
      //     }
      //     if (currentRatio < 0.6 && !isVisible) {
      //       this.controller.pause()
      //     }
      //   })
      //   .alignRules({
      //     center: { anchor: '__container__', align: VerticalAlign.Center },
      //     middle: { anchor: '__container__', align: HorizontalAlign.Center }
      //   })
    }.justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Black)
    .height('100%')
    .width('100%')
  }
}