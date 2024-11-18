import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct ASNPInnerLandingComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  @State url: string = ""

  aboutToAppear() {

  }

  build() {
    Column() {
      Row().height(26)
      Row() {
        Image($r('app.media.asnp_icon_back_left'))
          .objectFit(ImageFit.Contain)
          .width("40")
          .height("40")
          .padding(8)
          .onClick(() => {
            router.back()
          })
      }.height("46")
      .width("100%")
      .alignItems(VerticalAlign.Center)

      Row().width("100%").height(1)
        .backgroundColor("#ffc1c1c1")

      this.textWeb(this.url)

    }
    .width('100%')
    .height("100%")

  }

  @Builder
  textWeb(src: string) {
    Web({
      src,
      controller: this.controller,
    })
      .domStorageAccess(true)
      .onlineImageAccess(true)
      .imageAccess(true)
      .zoomAccess(true)
      .javaScriptAccess(true)
      .allowWindowOpenMethod(true)
      .mediaPlayGestureAccess(false)
      .fileAccess(false)
      .horizontalScrollBarAccess(false)
      .verticalScrollBarAccess(false)
      .mixedMode(MixedMode.All)
      .onLoadIntercept((event) => {
        if (event.data.getRequestUrl().search("http") > -1) {
          return false
        }
        // 返回true表示阻止此次加载，否则允许此次加载
        return true
      })
      .onControllerAttached(() => {
        console.log("onControllerAttached");
        try {
          let userAgent = this.controller.getUserAgent();
          this.controller.setCustomUserAgent(userAgent);
        } catch (error) {
          console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
        }
      })
  }
}
