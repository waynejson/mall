import { OrderService } from '../service/OrderService';
import { Constants } from '../common/Constants';
import { ShopCarInfoBean } from '../model/ShopCarInfoBean';
import { AddressBean } from '../model/AddressBean';
import { AddOrderBean } from '../model/AddOrderBean';
import { AddOrderParmBean } from '../model/AddOrderParmBean';
import { router } from '@kit.ArkUI';

/**
 * 订单确认页
 * 对应 Android 项目中的 OrderActivity.java
 */
@Entry
@Component
export struct OrderConfirmPage {
  @State addressList: AddressBean[] = [];
  @State productList: ShopCarInfoBean[] = [];
  @State selectedAddress: AddressBean | null = null;
  @State totalPrice: number = 0;
  @State totalCount: number = 0;
  @State payWay: number = 0;
  @State userId: number = 1;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    // 从路由参数获取数据
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['addressInfo']) {
        this.addressList = JSON.parse(params['addressInfo'] as string) as AddressBean[];
        this.selectDefaultAddress();
      }
      if (params['productInfo']) {
        this.productList = JSON.parse(params['productInfo'] as string) as ShopCarInfoBean[];
        this.calculateTotal();
      }
    }
  }

  onPageShow() {
    const addrJson = AppStorage.get<string>('selectedAddress');
    if (addrJson) {
      try {
        const addr = JSON.parse(addrJson) as AddressBean;
        if (addr && addr.id) {
          this.selectedAddress = addr;
        }
      } catch (e) {
        // ignore
      }
      AppStorage.set('selectedAddress', '');
    }
  }

  selectDefaultAddress() {
    for (const addr of this.addressList) {
      if (addr.isDefault) {
        this.selectedAddress = addr;
        return;
      }
    }
    if (this.addressList.length > 0) {
      this.selectedAddress = this.addressList[0];
    }
  }

  calculateTotal() {
    let total = 0;
    let count = 0;
    for (const item of this.productList) {
      total += item.pprice * item.buyCount;
      count += item.buyCount;
    }
    this.totalPrice = total;
    this.totalCount = count;
  }

  async submitOrder() {
    if (!this.selectedAddress) {
      console.info('请先选择收货地址');
      return;
    }
    if (this.productList.length === 0) {
      console.info('没有可下单的商品');
      return;
    }
    const products: AddOrderParmBean[] = [];
    for (const info of this.productList) {
      if (info.buyCount > 0) {
        products.push({
          buyCount: info.buyCount,
          type: info.pversion || '',
          pid: info.pid
        });
      }
    }
    const orderBean: AddOrderBean = {
      products: products,
      addrId: String(this.selectedAddress.id),
      payWay: this.payWay,
      userId: String(this.userId)
    };
    try {
      const result = await OrderService.createOrder(orderBean);
      console.info('下单成功');
      const orderDetails = await OrderService.getOrderDetails(this.userId, result.oid || String(result.id));
      router.pushUrl({
        url: 'pages/OrderDetailPage',
        params: { orderJson: JSON.stringify(orderDetails) }
      });
    } catch (e) {
      console.info('下单失败: ' + (e as Error).message);
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor($r('app.color.ui_text_dark'))
          .onClick(() => {
            router.back();
          })
        Text('确认订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

        Scroll() {
          Column() {
            // 收货地址
            Column() {
              if (this.selectedAddress) {
                Row() {
                  Column() {
                    Row() {
                      Text(this.selectedAddress.receiverName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                      Text(this.selectedAddress.receiverPhone)
                        .fontSize(14)
                        .fontColor($r('app.color.ui_text_hint'))
                        .margin({ left: 12 })
                    }
                    Text(this.selectedAddress.receiverAddress)
                      .fontSize(14)
                      .fontColor($r('app.color.ui_text_hint'))
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text('>')
                    .fontSize(16)
                    .fontColor($r('app.color.ui_text_disable'))
                }
                .padding(16)
              } else {
                Row() {
                  Text('请选择收货地址')
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_light'))
                  Text('>')
                    .fontSize(16)
                    .fontColor($r('app.color.ui_text_disable'))
                    .margin({ left: 'auto' })
                }
                .padding(16)
              }
            }
            .backgroundColor(Color.White)
            .margin({ top: 8 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddressListPage' });
            })

            // 商品列表
            ForEach(this.productList, (item: ShopCarInfoBean) => {
              Row() {
                Image(item.pimageUrl.startsWith('http') ? item.pimageUrl : (Constants.DOMAIN + item.pimageUrl))
                  .width(70)
                  .height(70)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(4)
                Column() {
                  Text(item.pname)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_dark'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  if (item.pversion && item.pversion.length > 0) {
                    Text(item.pversion)
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_light'))
                      .margin({ top: 2 })
                  }
                  Row() {
                    Text('¥' + item.pprice)
                      .fontSize(14)
                      .fontColor($r('app.color.ui_primary_red'))
                    Text('x' + item.buyCount)
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_light'))
                      .margin({ left: 'auto' })
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
              .margin({ top: 1 })
            })

            // 支付方式
            Column() {
              Text('支付方式')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })
              Row() {
                Text('在线支付')
                  .fontSize(14)
                  .fontColor(this.payWay === 0 ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_hint'))
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .border({ width: 1, color: this.payWay === 0 ? $r('app.color.ui_primary_red') : $r('app.color.ui_border_light') })
                  .borderRadius(4)
                  .onClick(() => {
                    this.payWay = 0;
                  })
                Text('货到付款')
                  .fontSize(14)
                  .fontColor(this.payWay === 1 ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_hint'))
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .border({ width: 1, color: this.payWay === 1 ? $r('app.color.ui_primary_red') : $r('app.color.ui_border_light') })
                  .borderRadius(4)
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.payWay = 1;
                  })
              }
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 订单金额
            Column() {
              Row() {
                Text('商品金额')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Text('¥' + this.totalPrice)
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                  .margin({ left: 'auto' })
              }
              .width('100%')
              Row() {
                Text('运费')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Text('¥0')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                  .margin({ left: 'auto' })
              }
              .width('100%')
              .margin({ top: 8 })
              Divider().margin({ top: 8, bottom: 8 })
              Row() {
                Text('共' + this.totalCount + '件')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Text('合计: ¥' + this.totalPrice)
                  .fontSize(18)
                  .fontColor($r('app.color.ui_primary_red'))
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 'auto' })
              }
              .width('100%')
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })
          }
        }
        .layoutWeight(1)

        // 底部提交栏
        Row() {
          Text('共' + this.totalCount + '件 合计: ¥' + this.totalPrice)
            .fontSize(16)
            .fontColor($r('app.color.ui_primary_red'))
            .fontWeight(FontWeight.Bold)
          Button('提交订单')
            .type(ButtonType.Capsule)
            .backgroundColor($r('app.color.ui_primary_red'))
            .fontColor(Color.White)
            .height(40)
            .margin({ left: 'auto' })
            .onClick(() => {
              this.submitOrder();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { top: 0.5 }, color: $r('app.color.ui_border_min') })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.ui_search_bg'))
  }
}
