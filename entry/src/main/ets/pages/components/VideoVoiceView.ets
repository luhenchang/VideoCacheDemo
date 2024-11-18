import { SendVideoState } from "../AMPSVideoCachePage"

@Component
export struct AMPSVideoVoiceView {
  @Consume('muted')
  muted: number
  @Consume('videoState')
  videoState: SendVideoState

  aboutToAppear() {
  }

  build() {
    Image(this.muted == 1 ? $r('app.media.asnp_voice_off') : $r('app.media.asnp_voice_on'))
      .objectFit(ImageFit.Contain)
      .size({ width: 25, height: 25 })
      .align(Alignment.TopStart)
      .onClick(() => {
        if (this.muted == 1) {
          this.muted = 0
        } else {
          this.muted = 1
        }
      })
      .visibility(this.videoState === SendVideoState.COMPLETE ? Visibility.None : Visibility.Visible)
  }
}