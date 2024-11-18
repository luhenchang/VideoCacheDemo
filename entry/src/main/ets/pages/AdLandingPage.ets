import { router } from '@kit.ArkUI'
import { ASNPInnerLandingComponent } from './components/ASNPInnerLandingComponent'


@Entry({ routeName: 'AdLandingPage' })
@Component
struct
AdLandingPage{
  @State url: string = ""
  bidId:string = ''
  aboutToAppear(){
    try {
      let pa = router.getParams() as AsnpLandingParam
      this.url = pa.url
      this.bidId = pa.bidId
    } catch (e) {
    }
  }
  build() {
    Row(){
      ASNPInnerLandingComponent({
        url:this.url
      })
    }.width('100%').height("100%")
  }
}

export interface AsnpLandingParam {
  url: string
  bidId: string
}
