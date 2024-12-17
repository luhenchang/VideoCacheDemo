import { VideoContentInfo } from '../data/VideoContentInfo';
import { VideoModel } from '../data/VideoModel';
import { FileUtil } from '../utils/FileUtil';
import { VideoTimeUtil } from '../utils/VideoTimeUtil';
import { AMPSJkVideoCacheView } from './AMPSJkVideoCacheView';
import { AMPSVideoCacheView } from './AMPSVideoCacheView';
import { JumpThreadAppState, ThreeWayAdView } from './components/ThreaWayAdView';
import { TimeDownAndCloseView } from './components/TimeDownAndCloseView';
import { VideoCompletedView } from './components/VideoCompletedView';
import { AMPSVideoVoiceView } from './components/VideoVoiceView';

const TAG: string = 'AMPSVideo Log';

//Video的状态
export enum SendVideoState {
  INITIALIZE,
  PLAYING,
  PAUSED,
  COMPLETE
}

@Entry
@Component
struct AMPSVideoCachePage {
  @Provide('muted')
  muted: number = 1
  @Provide('videoState')
  videoState: SendVideoState = SendVideoState.INITIALIZE
  @Provide('jumpThreadAppState')
  jumpThreadAppState: JumpThreadAppState = JumpThreadAppState.JUMP_BEFORE
  @State videoModel: VideoModel | undefined = undefined
  @State videoContent: VideoContentInfo | undefined = undefined

  // 界面初始化函数
  async aboutToAppear() {
    let videoResponse = await FileUtil.getRawFileContentStr("video_test_type_2.json")
    this.videoModel = JSON.parse(videoResponse) as VideoModel
    this.videoContent = VideoTimeUtil.getVideoContentInfo(this.videoModel)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {

      AMPSVideoCacheView({ videoName: this.videoContent?.videoUrl }).width('100%')
      ThreeWayAdView({ videoModel: this.videoModel, videoContent: this.videoContent })
      VideoCompletedView({ videoModel: this.videoModel, videoContent: this.videoContent })
      Row() {
        AMPSVideoVoiceView().align(Alignment.TopStart)

        Flex().layoutWeight(1)

        TimeDownAndCloseView({
          videoModel:  this.videoModel
        })

      }.layoutWeight(1).margin({ top: 40, left: 20, right: 20 }).justifyContent(FlexAlign.SpaceBetween)

    }.size({ height: '100%', width: '100%' }).backgroundColor(Color.Black)
  }
}