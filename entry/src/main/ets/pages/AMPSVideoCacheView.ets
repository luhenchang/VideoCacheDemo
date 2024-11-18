import Logger from './Logger';
import { } from '@ohos/hamock'
import { media } from '@kit.MediaKit';
import HttpProxyCacheServer from '../video_cache/HttpProxyCacheServer';
import { CacheListener } from '../video_cache/CacheListener';
import HttpProxyCacheServerBuilder from '../video_cache/HttpProxyCacheServerBuilder';
import GlobalProxyServer from '../GlobalProxyServer';
import fs from '@ohos.file.fs';
import { audio } from '@kit.AudioKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import MediaLibraryUtils from './MediaLibraryUtils';
import { AMPSVideoVoiceView } from './components/VideoVoiceView';
import { SendVideoState } from './AMPSVideoCachePage';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'AMPSVideo Log';

@Component
export struct AMPSVideoCacheView {
  @Prop videoName: string = '';
  @Watch('setMediaMuted') @Consume('muted')
  muted: number
  @Watch('videoStateCallBack') @Consume('videoState')
  videoState: SendVideoState
  @State loop: boolean = true
  @State videoAspectRatio:number = 1
  @State mediaLibUtils: MediaLibraryUtils = new MediaLibraryUtils();
  private mXCptController: XComponentController = new XComponentController();
  private surfaceID: string = '';
  private avPlayer: media.AVPlayer | undefined = undefined;
  @State currentCachePercent: number = 0;
  @State isPlaying: boolean = true;
  @State currentTime: string = '0';
  @State setValue: number = 0;
  @State durationTimeText: string = '100';
  private duration: number = -1;
  private fdPath: string = '';
  lastTime: number = 0

  aboutToAppear(): void {
    this.lastTime = systemDateTime.getTime()
  }

  async videoStateCallBack() {
    if (this.videoState === SendVideoState.COMPLETE) {
      Logger.info(TAG, 'videoStateCallBack success');
      GlobalProxyServer?.getInstance()?.getServer()?.shutdown()
      this.setOffCallback();
      await this.avPlayer?.stop();
      await this.avPlayer?.release();
    }else if (this.videoState === SendVideoState.PAUSED){
      await this.avPlayer?.pause()
    }else if (this.videoState === SendVideoState.PLAYING){
      await this.avPlayer?.play()
    }
  }
  setMediaMuted() {
    Logger.debug("muted===" + (this.muted == 1))
    this.avPlayer?.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.muted == 1)
  }

  build() {

    Stack({ alignContent: Alignment.Center }) {
      // 根据状态不同设置播放暂停图标显示
      if (this.videoName) {
        XComponent({
          id: 'componentId',
          type: XComponentType.SURFACE,
          controller: this.mXCptController,
        }).onLoad(() => {
          // 加载完成后调用初始化播放器函数
          this.initAVPlayer();
        }).aspectRatio(this.videoAspectRatio)
      }
    }.height('100%').width('100%').backgroundColor(Color.Black)
  }

  // 界面销毁监听
  async aboutToDisappear(): Promise<void> {
    Logger.info(TAG, 'aboutToDisappear success');
    GlobalProxyServer?.getInstance()?.getServer()?.shutdown()
    this.setOffCallback();
    await this.avPlayer?.stop();
    await this.avPlayer?.release();
  }

  // 初始化函数
  async initAVPlayer(): Promise<void> {
    this.surfaceID = this.mXCptController.getXComponentSurfaceId();
    Logger.info(TAG, 'surfaceID is : ' + this.surfaceID);
    await this.createAVPlayer();
    this.setStateChangeCallback();
    // this.setErrorCallback();
    this.timeUpdate();
    this.setSourceInfo();
  }

  // 设置播放时间上报监听
  timeUpdate(): void {
    this.avPlayer?.on('timeUpdate', (time: number) => {
      Logger.info(TAG, 'timeUpdate called: time is :' + time);
      Logger.info(TAG, 'timeUpdate called: currentTime is :' + this.avPlayer?.currentTime);
      this.currentTime = this.mediaLibUtils.getShowTime(time);
      this.setValue = Math.round((time / this.duration) * 100);
    })
  }

  // 视频信息上报函数
  async setSourceInfo(): Promise<void> {1
    // 首帧上报回调函数
    this.avPlayer?.on('startRenderFrame', () => {
      Logger.info(TAG, 'startRenderFrame success');
    });
    this.avPlayer?.on('videoSizeChange', (width: number, height: number) => {
      this.videoAspectRatio = width / height
      Logger.info(TAG, 'videoSizeChange success,and width is:' + width + ', height is :' + height);
    });
  }

  //设置播放surfaceID，播放音频时无需设置
  setSurfaceID(): void {
    if (this.avPlayer !== undefined) {
      this.avPlayer.surfaceId = this.surfaceID;
    }
  }

  // 创建AVPlayer实例对象
  async createAVPlayer(): Promise<boolean> {
    Logger.info(TAG, 'createAVPlayer start');
    let ret = false
    let self = this;
    if (this.avPlayer !== undefined) {
      //释放资源
      await this.avPlayer?.release();
      this.avPlayer = undefined;
    }
    this.avPlayer = await media.createAVPlayer();
    if (this.avPlayer !== undefined) {
      ret = true;
    }

    class MyCacheListener implements CacheListener {
      onCacheAvailable(cacheFilePath: string, url: string, percentsAvailable: number) {
        self.currentCachePercent = percentsAvailable;
        Logger.info(TAG, 'currentCachePercent =' + percentsAvailable);
        Logger.info(TAG, 'cacheFilePath =' + cacheFilePath);
        Logger.info(TAG, 'url =' + url);
      }
    }

    let server: HttpProxyCacheServer = new HttpProxyCacheServerBuilder(getContext()).build();
    server.registerCacheListener(new MyCacheListener(), this.videoName);
    GlobalProxyServer?.getInstance()?.setServer(server)


    let proxyUrl: string | undefined = await GlobalProxyServer?.getInstance()?.getServer()?.getProxyUrl(this.videoName)
    Logger.debug("proxyUrl====" + proxyUrl)
    let newUrl = proxyUrl ? proxyUrl : this.videoName;
    // 由于avplayer不支持直接加载本地文件路径 这里需要转化为fd的路径
    if (newUrl.startsWith(getContext().cacheDir)) {
      let file = fs.openSync(newUrl, fs.OpenMode.READ_ONLY);
      newUrl = "fd://" + file.fd;
      self.currentCachePercent = 100;
    }
    this.fdPath = newUrl;
    Logger.debug("fdPath====" + this.fdPath)
    if (this.avPlayer && this.getState() === 'idle') {
      this.avPlayer.url = this.fdPath;
    }
    Logger.info(TAG, 'createAVPlayer end');
    return ret;
  }

  // 状态机上报回调函数
  async setStateChangeCallback(): Promise<void> {
    this.avPlayer?.on('stateChange', async (state, reason) => {
      Logger.info(TAG, 'stateChange callback function is triggered,state is:' + state + ',reason is :' + reason);
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          Logger.info(TAG, 'state idle called');
          if (!this.loop) {
            this.avPlayer?.release();
          }
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          Logger.info(TAG, 'state initialized called');
          this.setSurfaceID();
          await this.avPlayer?.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          Logger.info(TAG, 'state prepared called');
          Logger.info(TAG, 'time prepared===' + (systemDateTime.getTime() - this.lastTime))
          if (this.avPlayer != undefined) {
            this.avPlayer.loop = this.loop;
            console.log("声音变化=", this.muted)
            this.setMediaMuted()
            this.avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
            this.duration = this.avPlayer?.duration;
            this.durationTimeText = this.mediaLibUtils.getShowTime(this.duration);
            this.avPlayer.play();
          }
          break;
        case 'playing':
          Logger.info(TAG, 'state playing called');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          Logger.info(TAG, 'state paused called');

          break;
        case 'completed':
          Logger.info(TAG, 'state completed called');
          if (!this.loop) {
            this.avPlayer?.stop();
          }
          break;
        case 'stopped':
          Logger.info(TAG, 'state stopped called');
          if (!this.loop) {
            this.avPlayer?.reset(); // 调用reset接口初始化avplayer状态
          }

          break;
        case 'released':
          Logger.info(TAG, 'state released called');
          break;
        case 'error':
          Logger.info(TAG, 'state error called');
          break;
        default:
          Logger.info(TAG, 'unkown state :' + state);
          break;
      }
    });
  }

  // 注销回调函数接口
  setOffCallback(): void {
    this.avPlayer?.off('volumeChange');
    this.avPlayer?.off('endOfStream');
    this.avPlayer?.off('seekDone');
    this.avPlayer?.off('durationUpdate');
    this.avPlayer?.off('speedDone');
    this.avPlayer?.off('bitrateDone');
    this.avPlayer?.off('bufferingUpdate');
    this.avPlayer?.off('startRenderFrame');
    this.avPlayer?.off('videoSizeChange');
    this.avPlayer?.off('audioInterrupt');
    this.avPlayer?.off('availableBitrates');
    this.avPlayer?.off('error');
    this.avPlayer?.off('stateChange');
  }

  // 获取当前播放状态函数
  getState(): string {
    return this.avPlayer?.state ? this.avPlayer?.state : '';
  }

  
}