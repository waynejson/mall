import { router } from '@kit.ArkUI';
import { HomeService } from '../service/HomeService';
import { Constants } from '../common/Constants';
import { BrandBean } from '../model/BrandBean';
import { FavBean } from '../model/FavBean';
import { SecKillBean } from '../model/SecKillBean';

/**
 * 首页Tab组件
 * 对应 Android 项目中的 MainFragment.java
 */
@Component
export struct HomeComponent {
  @State adList: BrandBean[] = [];
  @State ad2Url: string = '';
  @State favList: FavBean[] = [];
  @State secKillList: SecKillBean[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  private isDestroyed: boolean = false;

  aboutToAppear() {
    this.loadData();
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async loadData() {
    // 并行加载所有数据，提升加载速度
    const results = await Promise.allSettled([
      HomeService.loadAd1(),
      HomeService.loadAd2(),
      HomeService.loadRecommend(),
      HomeService.loadSecKill()
    ]);

    // 组件已销毁则不更新状态
    if (this.isDestroyed) {
      return;
    }

    // 处理广告1结果
    if (results[0].status === 'fulfilled') {
      this.adList = results[0].value;
    } else {
      console.error('加载广告1失败');
    }

    // 处理广告2结果
    if (results[1].status === 'fulfilled') {
      const ads2 = results[1].value;
      if (ads2 && ads2.length > 0) {
        const adUrl = ads2[0].adUrl;
        this.ad2Url = adUrl.startsWith('http') ? adUrl : (Constants.DOMAIN + adUrl);
      }
    } else {
      console.error('加载广告2失败');
    }

    // 处理猜你喜欢结果
    if (results[2].status === 'fulfilled') {
      this.favList = results[2].value;
    } else {
      console.error('加载猜你喜欢失败');
    }

    // 处理秒杀结果
    if (results[3].status === 'fulfilled') {
      this.secKillList = results[3].value;
    } else {
      console.error('加载秒杀失败');
    }

    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部搜索栏 - 与Android一致
      Row() {
        // 扫码图标
        Image($r('app.media.scan'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .margin({ right: 5 })

        // 搜索框
        Row() {
          Image($r('app.media.icon_search'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .margin({ right: 8 })

          TextInput({ placeholder: '搜索商品', text: this.searchKeyword })
            .type(InputType.Normal)
            .layoutWeight(1)
            .height(36)
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              if (this.searchKeyword.trim().length > 0) {
                router.pushUrl({
                  url: 'pages/ProductListPage',
                  params: { keyword: this.searchKeyword.trim() }
                });
              }
            })
        }
        .layoutWeight(1)
        .height(36)
        .borderRadius(18)
        .backgroundColor($r('app.color.ui_search_bg'))
        .padding({ left: 12, right: 12 })

        // 消息图标
        Image($r('app.media.message'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .margin({ left: 5 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.ui_text_light'))
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 轮播图广告
            if (this.adList.length > 0) {
              Swiper() {
                ForEach(this.adList, (ad: BrandBean) => {
                  Image(ad.adUrl.startsWith('http') ? ad.adUrl : (Constants.DOMAIN + ad.adUrl))
                    .width('100%')
                    .height(180)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                })
              }
              .width('100%')
              .height(180)
              .autoPlay(true)
              .interval(3000)
              .indicator(true)
              .margin({ left: 16, right: 16, top: 8 })
            }

            // 广告2
            if (this.ad2Url.length > 0) {
              Image(this.ad2Url)
                .width('100%')
                .height(100)
                .objectFit(ImageFit.Cover)
                .margin({ left: 16, right: 16, top: 8 })
                .borderRadius(8)
            }

            // 秒杀区域
            if (this.secKillList.length > 0) {
              Column() {
                Row() {
                  Image($r('app.media.sec_kill'))
                    .width(20)
                    .height(20)
                    .objectFit(ImageFit.Contain)
                  Text('限时秒杀')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.ui_primary_red'))
                    .margin({ left: 8 })
                }
                .margin({ left: 16, top: 16, bottom: 8 })

                List() {
                  ForEach(this.secKillList, (item: SecKillBean) => {
                    ListItem() {
                      Column() {
                        Image(item.iconUrl.startsWith('http') ? item.iconUrl : (Constants.DOMAIN + item.iconUrl))
                          .width(80)
                          .height(80)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(4)
                        Text('¥' + item.pointPrice)
                          .fontSize(14)
                          .fontColor($r('app.color.ui_primary_red'))
                          .margin({ top: 4 })
                        Text('¥' + item.allPrice)
                          .fontSize(12)
                          .fontColor($r('app.color.ui_text_light'))
                          .decoration({ type: TextDecorationType.LineThrough })
                      }
                      .width(100)
                      .padding(8)
                      .backgroundColor(Color.White)
                      .borderRadius(8)
                      .margin({ right: 8 })
                    }
                  })
                }
                .listDirection(Axis.Horizontal)
                .width('100%')
                .height(140)
                .padding({ left: 16, right: 16 })
              }
              .width('100%')
              .margin({ top: 8 })
            }

            // 猜你喜欢
            if (this.favList.length > 0) {
              Column() {
                Text('猜你喜欢')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 16, top: 16, bottom: 8 })
                Grid() {
                  ForEach(this.favList, (item: FavBean) => {
                    GridItem() {
                      Column() {
                        Image(item.iconUrl.startsWith('http') ? item.iconUrl : (Constants.DOMAIN + item.iconUrl))
                          .width('100%')
                          .aspectRatio(1)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(4)
                        Text(item.name)
                          .fontSize(13)
                          .fontColor($r('app.color.ui_text_dark'))
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .margin({ top: 4 })
                        Text('¥' + item.price)
                          .fontSize(14)
                          .fontColor($r('app.color.ui_primary_red'))
                          .margin({ top: 2 })
                      }
                      .padding(8)
                      .backgroundColor(Color.White)
                      .borderRadius(8)
                    }
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/ProductDetailPage',
                        params: { productId: parseInt(item.productId) }
                      });
                    })
                  })
                }
                .columnsTemplate('1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .width('100%')
                .padding({ left: 16, right: 16 })
              }
              .width('100%')
            }
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_page_bg'))
  }
}
