import { ProductService } from '../service/ProductService';
import { ShopCarService } from '../service/ShopCarService';
import { Constants } from '../common/Constants';
import { ProductBean } from '../model/ProductBean';
import { BuyInfoBean } from '../model/BuyInfoBean';
import { SearchProductParamBean } from '../model/SearchProductParamBean';
import { router } from '@kit.ArkUI';

/**
 * 商品列表页
 * 对应 Android 项目中的 ProductActivity.java
 */
@Entry
@Component
struct ProductListPage {
  @State productList: ProductBean[] = [];
  @State keyword: string = '';
  @State sortIndex: number = 0;
  @State userId: number = 1;
  @State categoryId: number | null = null;
  @State isLoading: boolean = true;
  private isDestroyed: boolean = false;

  private sortOptions: string[] = ['综合', '销量', '好评数', '价格升序', '价格降序'];

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    // 从路由参数获取 keyword 和 categoryId
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['keyword']) {
        this.keyword = params['keyword'] as string;
      }
      if (params['categoryId']) {
        this.categoryId = params['categoryId'] as number;
      }
    }
    if (this.keyword.length > 0 || this.categoryId !== null) {
      this.searchProducts();
    } else {
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async searchProducts() {
    this.isLoading = true;
    const params: SearchProductParamBean = {
      keyword: this.keyword,
      categoryId: this.categoryId,
      filterType: '',
      sortType: '',
      deliverChoose: '',
      minPrice: null,
      maxPrice: null,
      brandId: null,
      brandIds: ''
    };
    try {
      const products = await ProductService.searchProduct(params);
      if (!this.isDestroyed) {
        this.productList = products;
      }
    } catch (e) {
      console.error('搜索商品失败');
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  async sortProducts(index: number) {
    if (this.sortIndex === index) {
      return;
    }
    this.sortIndex = index;
    this.isLoading = true;
    try {
      let products: ProductBean[] = [];
      if (index === 0) {
        await this.searchProducts();
        return;
      } else if (index === 1) {
        products = await ProductService.sortByCommentCount(this.keyword);
      } else if (index === 2) {
        products = await ProductService.sortByFavComRate(this.keyword);
      } else if (index === 3) {
        products = await ProductService.sortByPriceUp(this.keyword);
      } else if (index === 4) {
        products = await ProductService.sortByPriceDown(this.keyword);
      }
      if (!this.isDestroyed) {
        this.productList = products;
      }
    } catch (e) {
      console.error('排序失败');
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  async addToCart(item: ProductBean) {
    try {
      const buyInfo: BuyInfoBean = {
        userId: this.userId,
        productId: item.id,
        buyCount: 1,
        productType: ''
      };
      const result = await ShopCarService.addToShopCar(buyInfo);
      if (result.success) {
        console.info('已加入购物车');
      } else {
        console.info('加入购物车失败');
      }
    } catch (e) {
      console.info('加入购物车失败');
    }
  }

  build() {
    Column() {
      // 搜索栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor($r('app.color.ui_text_dark'))
          .onClick(() => {
            router.back();
          })
        TextInput({ placeholder: '搜索商品', text: this.keyword })
          .type(InputType.Normal)
          .layoutWeight(1)
          .height(36)
          .borderRadius(18)
          .backgroundColor($r('app.color.ui_search_bg'))
          .margin({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.keyword = value;
          })
        Text('搜索')
          .fontSize(14)
          .fontColor($r('app.color.ui_primary_red'))
          .onClick(() => {
            this.searchProducts();
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Color.White)

      // 排序栏
      Row() {
        ForEach(this.sortOptions, (option: string, index: number) => {
          Text(option)
            .fontSize(13)
            .fontColor(this.sortIndex === index ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_hint'))
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .height(40)
            .onClick(() => {
              this.sortProducts(index);
            })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: { bottom: 0.5 }, color: $r('app.color.ui_border_min') })

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
      } else if (this.productList.length === 0) {
        Column() {
          Text('暂无商品')
            .fontSize(16)
            .fontColor($r('app.color.ui_text_light'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 商品列表
        List() {
          ForEach(this.productList, (item: ProductBean) => {
            ListItem() {
              Row() {
                Image(item.iconUrl.startsWith('http') ? item.iconUrl : (Constants.DOMAIN + item.iconUrl))
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(4)

                Column() {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_dark'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text('¥' + item.price)
                      .fontSize(16)
                      .fontColor($r('app.color.ui_primary_red'))
                      .fontWeight(FontWeight.Bold)
                    Text(item.commentCount + '条评论')
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_light'))
                      .margin({ left: 'auto' })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                  Row() {
                    Text('好评率' + item.favcomRate + '%')
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_light'))
                    Button('加入购物车')
                      .type(ButtonType.Capsule)
                      .height(28)
                      .fontSize(11)
                      .backgroundColor($r('app.color.ui_primary_red'))
                      .fontColor(Color.White)
                      .margin({ left: 'auto' })
                      .onClick(() => {
                        this.addToCart(item);
                      })
                  }
                  .width('100%')
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .margin({ left: 12 })
                .alignItems(HorizontalAlign.Start)
              }
              .padding(12)
              .backgroundColor(Color.White)
              .margin({ bottom: 1 })
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ProductDetailPage',
                params: { productId: item.id }
              });
            })
          })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_search_bg'))
  }
}
