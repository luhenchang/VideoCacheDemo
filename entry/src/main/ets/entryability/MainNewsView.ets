// /**
//  * 通用新闻模块
//  */
// import {
//   CommonConstants as Const,
//   logger,
//   ResponseResult,
//   WindowUtil,
//   PageState,
//   ShowToast,
//   CommonConstants,
//   PreferenceUtil
// } from '@ohos/commons';
// import { MainNewsViewModel } from '../viewmodel/MainNewsViewModel';
// import NewsModel from '../viewmodel/NewsModel';
// import { CustomRefreshLoadLayoutClass, NewsData } from '../viewmodel/NewsData'
// import { NewsApi } from '../networkApi/NewsApi';
// import CustomRefreshLoadLayout from './CustomRefreshLoadLayout';
// import RefreshLayout from './RefreshLayout';
// import NewsItem from './NewsItem';
// import LoadMoreLayout from './LoadMoreLayout';
// import NoMoreLayout from './NoMoreLayout';
// import { listTouchEvent, onRefresh } from '../utils/PullDownRefresh';
// import { MainNewsModulesConfig } from '../viewmodel/MainNewsModulesConfig';
// import { RetryAndFollowUpInterceptor } from '@ohos/httpclient/src/main/ets/interceptor/RetryAndFollowUpInterceptor';
// import Top from './NewListComponent/Top';
// import ItemBanner from './NewListComponent/ItemBanner';
// import ItemCustomPicView from './NewListComponent/ItemCustomPicView';
// import ItemArticlesListView from './NewListComponent/ItemArticlesListView';
// import ItemShortVideoView from './NewListComponent/ItemShortVideoView';
// import ItemBigPicView from './NewListComponent/ItemBigPicView';
// import ItemLeftTextRightPicView from './NewListComponent/ItemLeftTextRightPicView';
// import LineNameItem from './NewListComponent/LineNameItem';
// import News4picItem from './NewListComponent/News4picItem';
// import VerticalVideoList from './NewListComponent/VerticalVideoList';
// import { display, router, window } from '@kit.ArkUI';
// import { deviceInfo } from '@kit.BasicServicesKit';
// import { MyDataSource } from '../viewmodel/LazyDataNewsModel';
// import ItemSmallPicsView from './NewListComponent/ItemSmallPicsView';
// import ItemHoriPicsView from './NewListComponent/ItemHoriPicsView';
// import HorizontalVideoList from './NewListComponent/HorizontalVideoList';
// import FounderVideoList from './NewListComponent/FounderVideoList';
// import ItemBroadView from './NewListComponent/ItemBroadView';
// import SpecialView from './NewListComponent/SpecialView';
// import ItemPicsCollectionView from './NewListComponent/ItemPicsCollectionView';
// import HotLineView from './NewListComponent/HotLineView';
// import ItemSomePicsView from './NewListComponent/ItemSomePicsView';
// import ScrollNoticeItem from './NewListComponent/ScrollNoticeItem';
// import H5LinkItem from './NewListComponent/H5LinkItem';
// import Empty from './ugc/components/Empty';
// import { onLoadMore } from '../utils/PullUpLoadMore';
// import { BottomSafeBlank } from './ugc/components';
// import { NewsUtils } from '../utils/NewsUtils';
// import ItemMediaView from './NewListComponent/ItemMediaView';
// import {
//   ampsAd,
//   AMPSNativeAd,
//   AMPSNativeAdListener,
//   AMPSNativeAdView,
//   AMPSNativeAdWrapper,
//   AMPSNativeExpressListener,
//   AMPSNativeInteractiveListener,
//   AMPSNativeRenderListener
// } from 'amps';
//
// @Component
// export struct MainNewsView {
//   @StorageLink('enableAdvertisement') enableAdvertisement: boolean = false
//   @Prop indexName: string;
//   @Prop typeSeg: string;
//   @Prop loadDefault: boolean;
//   @Prop wordId: string;
//   mainNewsViewModel: MainNewsViewModel = new MainNewsViewModel()
//   @State newsModel: NewsModel = new NewsModel();
//   @Watch('changeCategory') @Link currentIndex: number;
//   @State refreshing: boolean = false;
//   @State loopIndex: number = 0;
//   @State ModeList: Array<string> = [];
//   @State lockRefresh: boolean = false
//   @State finalList: NewsData[] = []
//   @State markModules: string = '';
//   @State markCurrentIndex: number = 0;
//   @State markFirstModule: string = '';
//   @State adWrapperList: AMPSNativeAdWrapper[] = [];
//   @State adWrapperIndex: number = 0;
//   @State toCloseAdID: string = "";
//   @State heightMap: Map<string, number> = new Map()
//   private preferenceUtil: PreferenceUtil = new PreferenceUtil();
//
//   aboutToAppear() {
//     this.newsModel.typeSeg = this.typeSeg
//     this.newsModel.wordId = this.wordId
//     if (this.enableAdvertisement) {
//       let option: ampsAd.AdOptions = {
//         apiKey: CommonConstants.APPKEY,
//         spaceId: CommonConstants.SPACE_ID_NATIVE_TYPE_1,
//         adCount: 10,
//         expressSize: [px2vp(display.getDefaultDisplaySync().width - 35), 200]
//       }
//       // let map:ParamModel= router.getParams() as ParamModel
//       // option.spaceId = map.spaceId
//       //SDK外部调用加载广告
//       new AMPSNativeAd(this.getUIContext(), option, this.callback)
//         .load()
//     } else {
//       this.changeCategory()
//     }
//
//
//   }
//
//   changeCategory() {
//     this.newsModel.currentPage = 1;
//     if (this.markModules.length > 0 && this.markCurrentIndex != 0) {
//       return
//     }
//     this.mainNewsViewModel.getNewsList(this.newsModel.currentPage, this.newsModel.pageSize,
//       NewsApi.queryModulesDefaultLocal(this.newsModel.typeSeg, this.newsModel.wordId))
//       .then((data: ResponseResult) => {
//         let temp: Map<string, string>[] = JSON.parse(JSON.stringify(data.data))
//         let Modules = ''
//         let useModules: Map<string, string>[] = temp
//         if (temp.length > 9) {
//           if (temp.length > (this.newsModel.currentPage - 1) * 8 + 9) {
//             this.newsModel.hasMore = true;
//             this.newsModel.isCanLoadMore = true
//             useModules = temp.slice((this.newsModel.currentPage - 1) * 8, 9)
//             useModules.forEach((info: object) => {
//               Modules = Modules + info['_id'] + ','
//             })
//             this.newsModel.currentPage++;
//           } else {
//             this.newsModel.isLastPage = true;
//             useModules =
//               temp.slice((this.newsModel.currentPage - 1) * 8, temp.length - (this.newsModel.currentPage - 1) * 8)
//             useModules.forEach((info: object) => {
//               Modules = Modules + info['_id']?.toString() + ','
//             })
//           }
//         } else {
//           this.newsModel.hasMore = false;
//           this.newsModel.isCanLoadMore = false
//           temp.forEach((info: object) => {
//             Modules = Modules + info['_id'] + ','
//           })
//         }
//         let tempModule: string[] = Modules.split(',')
//         this.markFirstModule = tempModule[0]
//         this.loadData(Modules)
//       })
//       .catch((err: string | Resource) => {
//         this.newsModel.pageState = PageState.Fail;
//       });
//   }
//
//   loadData(modules: string) {
//     let newModules = modules.substring(0, modules.length - 1)
//     if (newModules.length > 0) {
//       this.ModeList = newModules.split(',')
//       this.recursionloop(this.loopIndex, this.ModeList)
//     }
//   }
//
//   recursionloop(index: number, ModeList: Array<string>) {
//     if (index == ModeList.length) {
//       this.loopIndex = 0
//       this.newsModel.isWaitNetWorkFinish = true
//       return
//     }
//     let module = ModeList[index]
//     let currentPage = 1
//     this.getData(module, currentPage)
//   }
//
//   getDataWithoutLoop(module: string, currentPage: number) {
//     let Modules = `${module}_${currentPage}_10,`
//     this.finalList = []
//     this.mainNewsViewModel.getNewsListFinal(NewsApi.queryData(this.newsModel.typeSeg, this.newsModel.wordId,
//       encodeURIComponent(Modules)))
//       .then((queryData: ResponseResult) => {
//         this.newsModel.pageState = PageState.Success;
//         if (module.length > 0) {
//           let dataUse: object = JSON.parse(JSON.stringify(queryData.data))
//           if (dataUse[module]) {
//             let info: NewsData = JSON.parse(JSON.stringify(dataUse[module]))
//             if (info.docs.results && info.docs.results.length > 0) {
//               if ((info.docs.results.length < info.docs.totalRecord)) {
//                 this.markModules = module
//                 this.markCurrentIndex = currentPage
//                 this.newsModel.hasMore = true
//                 this.newsModel.isWaitNetWorkFinish = true
//                 this.finalList.push(info)
//                 if (this.finalList.length > 0) {
//                   this.finalList.forEach((FData: NewsData) => {
//                     this.newsModel.newsDataSource.pushData(FData)
//                   })
//                 }
//                 this.finalList = []
//               } else {
//                 this.newsModel.hasMore = false
//                 this.newsModel.isWaitNetWorkFinish = true
//                 this.finalList.push(info)
//                 if (this.finalList.length > 0) {
//                   this.finalList.forEach((FData: NewsData) => {
//                     this.newsModel.newsDataSource.pushData(FData)
//                   })
//                 }
//                 this.finalList = []
//               }
//             } else {
//               this.newsModel.hasMore = false
//               this.newsModel.isWaitNetWorkFinish = true
//               this.finalList.push(info)
//               if (this.finalList.length > 0) {
//                 this.finalList.forEach((FData: NewsData) => {
//                   this.newsModel.newsDataSource.pushData(FData)
//                 })
//               }
//               this.finalList = []
//             }
//           }
//         }
//       })
//       .catch((err: string | Resource) => {
//         this.newsModel.pageState = PageState.Fail;
//
//       });
//   }
//
//   getData(module: string, currentPage: number) {
//     if (currentPage == 1) {
//       this.adWrapperIndex = 0
//       this.toCloseAdID = ""
//     }
//     let Modules = `${module}_${currentPage}_10,`
//     this.mainNewsViewModel.getNewsListFinal(NewsApi.queryData(this.newsModel.typeSeg, this.newsModel.wordId,
//       encodeURIComponent(Modules)))
//       .then((queryData: ResponseResult) => {
//         if (module == this.markFirstModule) {
//           this.newsModel.newsDataSource.clear()
//         }
//         this.newsModel.pageState = PageState.Success;
//         if (module.length > 0) {
//           let dataUse: object = JSON.parse(JSON.stringify(queryData.data))
//           if (dataUse[module]) {
//             let info: NewsData = JSON.parse(JSON.stringify(dataUse[module]))
//             if (info.docs.results && info.docs.results.length > 0) {
//               if ((info.docs.results.length < info.docs.totalRecord) &&
//                 (info.type == '文章列表' || info.type == '左文右图' || info.type == '小视频播放新') &&
//                 ((this.loopIndex == this.ModeList.length - 1) && this.newsModel.isLastPage)) {
//                 if (currentPage > 1) {
//                   this.markModules = module
//                   this.markCurrentIndex = currentPage
//                   this.newsModel.hasMore = true
//                   this.newsModel.isWaitNetWorkFinish = true
//                   this.markCurrentIndex += 1
//                   this.finalList.push(info)
//                   if (this.finalList.length > 0) {
//                     this.finalList.forEach((FData: NewsData) => {
//                       this.newsModel.newsDataSource.pushData(FData)
//                     })
//                   }
//                   this.getDataWithoutLoop(module, this.markCurrentIndex)
//                 } else {
//                   this.markModules = ''
//                   this.markCurrentIndex = 0
//                   this.finalList.push(info)
//                   this.getData(module, currentPage + 1)
//                 }
//               } else {
//                 this.finalList.push(info)
//                 if (this.finalList.length > 0) {
//                   this.finalList.forEach((FData: NewsData) => {
//                     this.newsModel.newsDataSource.pushData(FData)
//                   })
//                 }
//                 this.finalList = []
//                 this.loopIndex += 1
//                 this.recursionloop(this.loopIndex, this.ModeList)
//               }
//             } else {
//               this.finalList.push(info)
//               if (this.finalList.length > 0) {
//                 this.finalList.forEach((FData: NewsData) => {
//                   this.newsModel.newsDataSource.pushData(FData)
//                 })
//               }
//               this.finalList = []
//               this.loopIndex += 1
//               this.recursionloop(this.loopIndex, this.ModeList)
//             }
//           }
//
//         }
//
//
//       })
//       .catch((err: string | Resource) => {
//         this.newsModel.pageState = PageState.Fail;
//         this.loopIndex += 1
//         this.recursionloop(this.loopIndex, this.ModeList)
//       });
//   }
//
//   private mRenderCallback: AMPSNativeRenderListener = {
//     renderSuccess: (adWrapper: AMPSNativeAdWrapper) => {
//       this.adWrapperList = []
//       this.adWrapperList.push(adWrapper)
//       this.adWrapperIndex += 1
//       logger.info("TAG", this.adWrapperIndex + "")
//       adWrapper.interactCallBack = this.mInterCallback
//       adWrapper.expressCallBack = this.expressCallBack
//       this.heightMap.set(adWrapper.adId, 202)
//       // setTimeout(() => {
//       //   let ad = new NewsData()
//       //   ad.type = "广告"
//       //   ad.moduleId = adWrapper.adId
//       //   ad.wrapper = adWrapper
//       //   this.newsModel.newsDataSource.addData(2, ad)
//       //   for (let i = 0; i < this.newsModel.newsDataSource.totalCount(); i++) {
//       //     if (i % 5 == 0) {
//       //       this.newsModel.newsDataSource.addData(i, ad)
//       //     }
//       //   }
//       // }, 10)
//     },
//     renderFailed: (adWrapper: AMPSNativeAdWrapper) => {
//       console.log("onAdShown:" + adWrapper.adId)
//     }
//   }
//   private expressCallBack: AMPSNativeExpressListener = {
//     onAdShown: (adId?: string): void => {
//       console.log("onAdShown:" + adId)
//     },
//     onAdExposure: (adId?: string): void => {
//       console.log("onAdExposure" + adId)
//     }
//   }
//   private mInterCallback: AMPSNativeInteractiveListener = {
//     onAdClicked: (adId?: string): void => {
//       console.log("客户端onAdClicked:" + adId)
//     },
//     toCloseAd: (adId?: string): void => {
//       if (adId != undefined) {
//         this.toCloseAdID = adId
//       }
//       // let index = -1;
//       // for (let i = 0; i < this.newsModel.newsDataSource.totalCount(); i++) {
//       //
//       //   let ad = this.newsModel.newsDataSource.getData(i) as NewsData
//       //   if (ad.moduleId == adId) {
//       //     index = i;
//       //   }
//       //
//       // }
//       // if (index >= 0) {
//       //   this.newsModel.newsDataSource.deleteData(index);
//       // }
//     },
//     onOpenLandingPage: (adId?: string | undefined): void => {
//       console.log("onOpenLandingPage:" + adId)
//     },
//     onCloseLandingPage: (adId?: string): void => {
//       console.log("onCloseLandingPage:" + adId)
//     }
//   }
//   private callback: AMPSNativeAdListener = {
//     loadOk: (adItems: AMPSNativeAdWrapper[]): void => {
//
//       for (let adItemsElement of adItems) {
//         logger.info("TAG", adItemsElement.adId + "广告id")
//         adItemsElement.renderCallBack = this.mRenderCallback
//         //adItemsElement.option.mExpressSize = [300,400]
//         adItemsElement.renderAd()
//       }
//       this.changeCategory();
//     },
//     loadFail: (code: number, message: string): void => {
//       // ShowToast.shortToast(message)
//       this.changeCategory();
//     }
//   }
//
//   LoadMore() {
//     if (this.loopIndex != 0) {
//       return
//     }
//     animateTo({
//       duration: Const.ANIMATION_DURATION,
//     }, () => {
//       this.newsModel.offsetY = 0;
//     })
//     if ((this.newsModel.isCanLoadMore === true) && (this.newsModel.hasMore === true) &&
//       (this.newsModel.isWaitNetWorkFinish === true)) {
//       this.newsModel.isLoading = true;
//       setTimeout(() => {
//         this.closeLoadMore();
//
//         let mainNewsViewModel: MainNewsViewModel = new MainNewsViewModel()
//         this.newsModel.isWaitNetWorkFinish = false
//         mainNewsViewModel.getNewsList(this.newsModel.currentPage, this.newsModel.pageSize,
//           NewsApi.queryModulesDefaultLocal(this.newsModel.typeSeg, this.newsModel.wordId))
//           .then((data: ResponseResult) => {
//
//             let temp: Map<string, string>[] = JSON.parse(JSON.stringify(data.data))
//             let Modules = ''
//             if (temp.length > 9) {
//               if (temp.length > (this.newsModel.currentPage - 1) * 8 + 9) {
//                 this.newsModel.hasMore = true;
//                 this.newsModel.isCanLoadMore = true
//                 let useModules =
//                   temp.slice((this.newsModel.currentPage - 1) * 9, (this.newsModel.currentPage - 1) * 9 + 9)
//                 useModules.forEach((info: object) => {
//                   Modules = Modules + info['_id'] + ','
//                 })
//                 this.newsModel.currentPage++;
//               } else {
//                 let useModules = temp.slice((this.newsModel.currentPage - 1) * 9, temp.length)
//                 useModules.forEach((info: object) => {
//                   Modules = Modules + info['_id'] + ','
//                 })
//                 this.newsModel.hasMore = false;
//                 this.newsModel.isCanLoadMore = false
//                 this.newsModel.isLastPage = true;
//               }
//
//             } else {
//               this.newsModel.hasMore = false;
//               this.newsModel.isCanLoadMore = false;
//               this.newsModel.isLastPage = true;
//               temp.forEach((info: object) => {
//                 Modules = Modules + info['_id'] + ','
//               })
//             }
//             this.loadData(Modules)
//           })
//           .catch((err: string | Resource) => {
//             this.newsModel.pageState = PageState.Fail;
//             this.newsModel.isWaitNetWorkFinish = true
//           });
//
//
//       }, Const.DELAY_TIME);
//     } else {
//       this.closeLoadMore();
//     }
//   }
//
//   closeLoadMore() {
//     this.newsModel.isLoading = false;
//     this.newsModel.isVisiblePullUpLoad = false;
//     this.newsModel.isWaitNetWorkFinish = true
//
//   }
//
//   build() {
//     if (this.currentIndex == -1) {
//       Stack() {
//         Image($r('app.media.TopBackImage')).height(368).width('100%')
//         Refresh({ refreshing: $$this.refreshing }) {
//           Column() {
//             this.ListLayout()
//           }
//         }
//         .width(Const.FULL_WIDTH)
//         .height('90%')
//         .margin({ top: '20%' })
//         .onRefreshing(async () => {
//           this.changeCategory()
//           this.refreshing = !this.refreshing
//         })
//       }.alignContent(Alignment.TopStart)
//
//     } else {
//       Refresh({ refreshing: $$this.refreshing }) {
//         Column() {
//           this.ListLayout()
//         }
//       }
//       .onRefreshing(async () => {
//         this.changeCategory()
//         this.refreshing = !this.refreshing
//       })
//       .width(Const.FULL_WIDTH)
//       .height(Const.FULL_HEIGHT)
//     }
//   }
//
//   @Builder
//   ListLayout() {
//     List() {
//       if (this.indexName == "金色热线") {
//         ListItem() {
//           HotLineView()
//         }
//       }
//       if (this.newsModel.newsDataSource.totalCount()) {
//         LazyForEach(this.newsModel.newsDataSource, (item: NewsData, index: number) => {
//           ListItem() {
//             Column() {
//               if (index != 0 && index % 5 == 0 && this.adWrapperList.length > 0 && this.indexName == "推荐" &&
//                 item.type != "自定义标题") {
//                 if (this.adWrapperList.length >= this.adWrapperIndex) {
//                   if (this.toCloseAdID != this.adWrapperList[this.adWrapperIndex].adId) {
//                     AMPSNativeAdView({ nativeWrapper: this.adWrapperList[this.adWrapperIndex] })
//                       .margin({ top: 10, bottom: 15 })
//                   }
//                 } else {
//                   if (this.toCloseAdID != this.adWrapperList[0].adId) {
//
//                     AMPSNativeAdView({ nativeWrapper: this.adWrapperList[0] }).margin({ top: 10, bottom: 15 })
//                   }
//                 }
//               }
//               Row() {
//
//                 if (item.type == "top") {
//                   Top({ info: item })
//                 } else if (item.type == 'imagesNew' || item.type == '轮播图') {
//                   ItemBanner({ info: item })
//
//                 } else if (item.type == '自定义图片') {
//                   ItemCustomPicView({ info: item })
//                 } else if (item.type == '文章列表') {
//                   ItemArticlesListView({ info: item })
//                 } else if (item.type == '多图列表') {
//                   ItemSomePicsView({ info: item })
//                 } else if (item.type == '自定义标题') {
//                   if (item.docs.moduleTitle.content == '四图联播') {
//                     News4picItem({ info: item })
//                   } else {
//                     LineNameItem({ info: item })
//                   }
//                 } else if (item.type == '左文右图') {
//
//                   ItemLeftTextRightPicView({ info: item })
//
//                 } else if (item.type == '大图列表') {
//
//                   if (item.docs.results.length > 0) {
//                     ItemBigPicView({ info: item })
//                   }
//
//                 } else if (item.type == '小图列表') {
//
//                   ItemSmallPicsView({ info: item })
//
//                 } else if (item.type == '横版多图') {
//
//                   ItemHoriPicsView({ info: item })
//
//                 } else if (item.type == '应急广播') {
//
//                   ItemBroadView({ info: item })
//
//                 } else if (item.type == 'specialList') {
//
//                   SpecialView({ info: item })
//
//                 } else if (item.type == '图集' || item.type == '新版图集') {
//
//                   ItemPicsCollectionView({ info: item.docs.results[0] })
//
//                 } else if (item.type == '小视频播放新' || item.type == '小视频播放') {
//                   if (item.docs.results.length > 0) {
//                     if (item.moduleStyle == 2) {
//                       VerticalVideoList({ info: item })
//                     } else if (item.moduleStyle == 0) {
//                       ItemShortVideoView({ info: item })
//
//                     } else if (item.moduleStyle == 1) {
//                       HorizontalVideoList({ info: item })
//                     } else if (item.moduleStyle == 3) {
//                       FounderVideoList({ info: item })
//                     } else {
//                       ItemShortVideoView({ info: item })
//
//                     }
//                   }
//
//                 } else if (item.type == '滚动公告区') {
//                   ScrollNoticeItem({ info: item })
//
//                 } else if (item.type == 'H5外链') {
//                   H5LinkItem({ info: item })
//                 } else if (item.type == '媒体号推荐') {
//                   ItemMediaView({ info: item })
//                 } else {
//                   NewsItem({ newsData: item })
//                 }
//               }
//
//               if (index != 0 && index % 5 == 0 && this.adWrapperList.length > 0 && this.indexName == "推荐" &&
//                 item.type == "自定义标题") {
//                 if (this.adWrapperList.length > this.adWrapperIndex) {
//                   if (this.toCloseAdID != this.adWrapperList[this.adWrapperIndex].adId) {
//                     AMPSNativeAdView({ nativeWrapper: this.adWrapperList[this.adWrapperIndex] }).margin({ bottom: 10 })
//                   }
//                 } else {
//                   if (this.toCloseAdID != this.adWrapperList[0].adId) {
//
//                     AMPSNativeAdView({ nativeWrapper: this.adWrapperList[0] }).margin({ bottom: 10 })
//                   }
//                 }
//               }
//             }
//           }
//           .backgroundColor($r('app.color.white'))
//           .margin({ top: Const.NewsListConstant_ITEM_MARGIN_TOP })
//
//         }, (item: NewsData, index?: number) => JSON.stringify(item) + index)
//         ListItem() {
//           if (this.newsModel.hasMore) {
//             Row({ space: 4 }) {
//               Image($r('app.media.ic_pull_up_load')).width(18).height(18)
//               Text($r('app.string.pull_up_load_text')).fontSize(14).fontColor($r('app.color.main_text_color'))
//             }.width('100%').justifyContent(FlexAlign.Center).padding(10)
//           } else {
//             Row() {
//               Text($r('app.string.prompt_message')).fontSize(14).fontColor($r('app.color.main_text_color'))
//             }.width('100%').justifyContent(FlexAlign.Center).padding(10)
//           }
//         }
//
//         ListItem() {
//           BottomSafeBlank()
//         }
//       } else {
//         Empty()
//       }
//     }
//     .width(Const.FULL_WIDTH)
//     .height(Const.FULL_HEIGHT)
//     .padding({ left: Const.NewsListConstant_LIST_MARGIN_LEFT, right: Const.NewsListConstant_LIST_MARGIN_RIGHT })
//     .backgroundColor($r('app.color.white'))
//     .borderRadius(10)
//     .divider({
//       color: $r('app.color.dividerColor'),
//       strokeWidth: Const.NewsListConstant_LIST_DIVIDER_STROKE_WIDTH,
//       endMargin: Const.NewsListConstant_LIST_MARGIN_RIGHT
//     })
//
//     .edgeEffect(EdgeEffect.None)
//     .onReachEnd(() => {
//       if (this.markModules.length > 0 && this.markCurrentIndex != 0) {
//         if (this.newsModel.hasMore) {
//           this.markCurrentIndex += 1
//           this.getDataWithoutLoop(this.markModules, this.markCurrentIndex)
//         }
//       } else {
//         if (this.newsModel.hasMore) {
//           this.LoadMore()
//         }
//       }
//
//
//     }
//     )
//   }
// }
//
// class Item {
//   index: number = 0
//   message: string = ''
// }
//
// class AdItem extends Item {
//   wrapper: AMPSNativeAdWrapper
//   suggestHeight = 200
//
//   constructor(aWrapper: AMPSNativeAdWrapper) {
//     super()
//     this.wrapper = aWrapper
//   }
// }