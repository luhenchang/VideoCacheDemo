import { common, Want } from "@kit.AbilityKit";
import { router } from "@kit.ArkUI";
import '../pages/AdLandingPage'
interface AsnpLandingParam{
  url:string
  bidId:string
}
export class AdActionUtil{
  /*
   * 跳转到其它应用
   * 测试：link:asnp://www.test.com:6060/path1
   * */
  static jumpOtherApp(link:string){
    const want: Want = {
      uri: link
    };
    const context = getContext() as common.UIAbilityContext;
    return context.startAbility(want)
  }

  static jumpToLandPage(url:string,bidId:string){
    let p: AsnpLandingParam = {
      url,
      bidId
    }
    return router.pushNamedRoute({
      name: "AdLandingPage",
      params: p
    })
  }

}