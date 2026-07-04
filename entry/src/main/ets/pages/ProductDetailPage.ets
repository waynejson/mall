import { ProductService } from '../service/ProductService';
import { ShopCarService } from '../service/ShopCarService';
import { CategoryService } from '../service/CategoryService';
import { Constants } from '../common/Constants';
import { ProductInfoBean } from '../model/ProductInfoBean';
import { CommentBean } from '../model/CommentBean';
import { BuyInfoBean } from '../model/BuyInfoBean';
import { AddressService } from '../service/AddressService';
import { ShopCarInfoBean } from '../model/ShopCarInfoBean';
import { TopBar } from '../components/TopBar';
import { router } from '@kit.ArkUI';

/**
 * 商品详情页
 * 对应 Android 项目中的 ProductDetailsActivity.java
 */
@Entry
@Component
struct ProductDetailPage {
  @State productInfo: ProductInfoBean | null = null;
  @State comments: CommentBean[] = [];
  @State currentTab: number = 0; // 0商品 1详情 2评价
  @State selectedType: string = '';
  @State buyCount: number = 1;
  @State currentImageIndex: number = 0;
  @State userId: number = 1;
  @State productId: number = 0;
  @State isLoading: boolean = true;
  @State isAddingToCart: boolean = false;
  private isDestroyed: boolean = false;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    // 从路由参数获取productId
    const params = router.getParams() as Record<string, Object>;
    if (params && params['productId']) {
      this.productId = params['productId'] as number;
    }
    this.loadProductInfo();
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async loadProductInfo() {
    this.isLoading = true;
    // 并行加载商品信息和评论
    const results = await Promise.allSettled([
      ProductService.getProductInfo(this.productId),
      CategoryService.getProductComments(this.productId)
    ]);

    if (this.isDestroyed) {
      return;
    }

    // 处理商品信息
    if (results[0].status === 'fulfilled') {
      this.productInfo = results[0].value;
      if (this.productInfo && this.productInfo.typeList && this.productInfo.typeList.length > 1) {
        this.selectedType = this.productInfo.typeList[1] || '';
      }
    } else {
      console.error('加载商品详情失败');
    }

    // 处理评论
    if (results[1].status === 'fulfilled') {
      this.comments = results[1].value;
    } else {
      console.error('加载评论失败');
    }

    this.isLoading = false;
  }

  async addToCart() {
    if (!this.productInfo || this.isAddingToCart) {
      return;
    }
    this.isAddingToCart = true;
    try {
      const buyInfo: BuyInfoBean = {
        userId: this.userId,
        productId: this.productInfo.id || 0,
        buyCount: this.buyCount,
        productType: this.selectedType
      };
      const result = await ShopCarService.addToShopCar(buyInfo);
      if (result.success) {
        console.info('已加入购物车');
      } else {
        console.info(result.errorMsg || '加入购物车失败');
      }
    } catch (e) {
      console.info('加入购物车失败');
    } finally {
      this.isAddingToCart = false;
    }
  }

  async buyNow() {
    if (!this.productInfo || !this.productInfo.id || this.isAddingToCart) {
      console.info('商品信息异常');
      return;
    }
    this.isAddingToCart = true;
    try {
      const buyInfo: BuyInfoBean = {
        userId: this.userId,
        productId: this.productInfo.id,
        buyCount: this.buyCount,
        productType: this.selectedType
      };
      await ShopCarService.addToShopCar(buyInfo);
    } catch (e) {
      // ignore
    }
    const cartItem: ShopCarInfoBean = {
      id: 0,
      buyCount: this.buyCount,
      storeName: '',
      pprice: this.productInfo.price || 0,
      pimageUrl: (this.productInfo.imgUrls && this.productInfo.imgUrls.length > 0) ? this.productInfo.imgUrls[0] : '',
      pname: this.productInfo.name || '',
      pid: this.productInfo.id,
      stockCount: this.productInfo.stockCount || 0,
      storeId: 0,
      pversion: this.selectedType,
      isChecked: true
    };
    try {
      const addressList = await AddressService.getAddressList({ userId: this.userId, isDefault: true });
      if (!this.isDestroyed) {
        router.pushUrl({
          url: 'pages/OrderConfirmPage',
          params: {
            addressInfo: JSON.stringify(addressList),
            productInfo: JSON.stringify([cartItem])
          }
        });
      }
    } catch (e) {
      console.error('获取地址失败');
    } finally {
      this.isAddingToCart = false;
    }
  }

  build() {
    Column() {
      // 返回按钮
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor($r('app.color.ui_text_dark'))
          .onClick(() => {
            router.back();
          })
        Text('商品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Color.White)

        // 顶部Tab
        TopBar({
          currentIndex: this.currentTab,
          onTabChange: (index: number) => {
            this.currentTab = index;
          }
        })

        // 内容区域
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
        } else if (this.currentTab === 0) {
          Scroll() {
            Column() {
              if (this.productInfo && this.productInfo.imgUrls && this.productInfo.imgUrls.length > 0) {
                Swiper() {
                  ForEach(this.productInfo.imgUrls, (url: string) => {
                    Image(url.startsWith('http') ? url : (Constants.DOMAIN + url))
                      .width('100%')
                      .height(300)
                      .objectFit(ImageFit.Cover)
                  })
                }
                .width('100%')
                .height(300)
                .autoPlay(true)
                .indicator(true)
                .onChange((index: number) => {
                  this.currentImageIndex = index;
                })
              }

              Column() {
                Text(this.productInfo?.name || '')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.ui_text_dark'))
                if (this.productInfo?.recomProduct) {
                  Text(this.productInfo.recomProduct)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_light'))
                    .margin({ top: 4 })
                }
                Text('¥' + (this.productInfo?.price || 0))
                  .fontSize(22)
                  .fontColor($r('app.color.ui_primary_red'))
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 8 })
                Row() {
                  Text('好评率' + (this.productInfo?.favcomRate || 0) + '%')
                    .fontSize(12)
                    .fontColor($r('app.color.ui_text_light'))
                  Text((this.productInfo?.commentCount || 0) + '人评价')
                    .fontSize(12)
                    .fontColor($r('app.color.ui_text_light'))
                    .margin({ left: 16 })
                }
                .margin({ top: 8 })
              }
              .padding(16)
              .backgroundColor(Color.White)

              // 规格选择
              if (this.productInfo?.typeList && this.productInfo.typeList.length > 1) {
                Column() {
                  Text('选择规格')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 8 })
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.productInfo.typeList.slice(1), (type: string) => {
                      Text(type)
                        .fontSize(13)
                        .fontColor(this.selectedType === type ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_hint'))
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .border({ width: 1, color: this.selectedType === type ? $r('app.color.ui_primary_red') : $r('app.color.ui_border_light') })
                        .borderRadius(4)
                        .margin({ right: 8, bottom: 8 })
                        .onClick(() => {
                          this.selectedType = type;
                        })
                    })
                  }
                }
                .padding(16)
                .backgroundColor(Color.White)
                .margin({ top: 8 })
              }

              // 购买数量
              Row() {
                Text('购买数量')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Row() {
                  Text('-')
                    .fontSize(18)
                    .width(30)
                    .height(30)
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r('app.color.ui_search_bg'))
                    .borderRadius(4)
                    .onClick(() => {
                      if (this.buyCount > 1) this.buyCount--;
                    })
                  Text(String(this.buyCount))
                    .fontSize(16)
                    .width(50)
                    .textAlign(TextAlign.Center)
                  Text('+')
                    .fontSize(18)
                    .width(30)
                    .height(30)
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r('app.color.ui_search_bg'))
                    .borderRadius(4)
                    .onClick(() => {
                      this.buyCount++;
                    })
                }
                .margin({ left: 'auto' })
              }
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })

              // 推荐评论
              if (this.comments.length > 0) {
                Column() {
                  Text('用户评价')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 8 })
                  ForEach(this.comments.slice(0, 3), (comment: CommentBean) => {
                    Column() {
                      Row() {
                        Text(comment.userName)
                          .fontSize(13)
                          .fontColor($r('app.color.ui_text_dark'))
                        Text('好评率' + comment.rate + '%')
                          .fontSize(12)
                          .fontColor($r('app.color.ui_text_light'))
                          .margin({ left: 'auto' })
                      }
                      .width('100%')
                      Text(comment.comment)
                        .fontSize(13)
                        .fontColor($r('app.color.ui_text_hint'))
                        .margin({ top: 4 })
                    }
                    .padding({ top: 8, bottom: 8 })
                    .border({ width: { bottom: 0.5 }, color: $r('app.color.ui_search_bg') })
                  })
                }
                .padding(16)
                .backgroundColor(Color.White)
                .margin({ top: 8 })
              }
            }
          }
          .layoutWeight(1)
        } else if (this.currentTab === 1) {
          Scroll() {
            Column() {
              Text('商品详情')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .padding(16)
              if (this.productInfo?.imgUrls) {
                ForEach(this.productInfo.imgUrls, (url: string) => {
                  Image(url.startsWith('http') ? url : (Constants.DOMAIN + url))
                    .width('100%')
                    .objectFit(ImageFit.Contain)
                })
              }
            }
          }
          .layoutWeight(1)
        } else {
          if (this.comments.length === 0) {
            Column() {
              Text('暂无评论')
                .fontSize(16)
                .fontColor($r('app.color.ui_text_light'))
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            List() {
              ForEach(this.comments, (comment: CommentBean) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(comment.userName)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                      Text('好评率' + comment.rate + '%')
                        .fontSize(12)
                        .fontColor($r('app.color.ui_text_light'))
                        .margin({ left: 'auto' })
                    }
                    .width('100%')
                    Text(comment.comment)
                      .fontSize(13)
                      .fontColor($r('app.color.ui_text_hint'))
                      .margin({ top: 8 })
                    Text(comment.time)
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_disable'))
                      .margin({ top: 4 })
                  }
                  .padding(16)
                  .backgroundColor(Color.White)
                  .margin({ bottom: 8 })
                }
              })
            }
            .layoutWeight(1)
          }
        }

        // 底部操作栏
        Row() {
          Button('加入购物车')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.ui_btn_orange'))
            .fontColor(Color.White)
            .fontSize(15)
            .margin({ right: 8 })
            .enabled(!this.isAddingToCart)
            .onClick(() => {
              this.addToCart();
            })
          Button(this.isAddingToCart ? '处理中...' : '立即购买')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.ui_primary_red'))
            .fontColor(Color.White)
            .fontSize(15)
            .enabled(!this.isAddingToCart)
            .onClick(() => {
              this.buyNow();
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Color.White)
        .border({ width: { top: 0.5 }, color: $r('app.color.ui_border_min') })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.ui_search_bg'))
  }
}
