import { OrderService } from '../service/OrderService';
import { Constants } from '../common/Constants';
import { OrderDerailsBean, OrderDerailsItem } from '../model/OrderDerailsBean';
import { router } from '@kit.ArkUI';

/**
 * 订单详情页
 * 对应 Android 项目中的 OrderDetailsActivity.java
 */
@Entry
@Component
export struct OrderDetailPage {
  @State order: OrderDerailsBean | null = null;
  @State userId: number = 1;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    // 从路由参数获取数据
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['orderJson']) {
        this.order = JSON.parse(params['orderJson'] as string) as OrderDerailsBean;
      } else if (params['oid']) {
        this.loadOrderDetails(params['oid'] as number);
      }
    }
  }

  async loadOrderDetails(oid: number) {
    try {
      this.order = await OrderService.getOrderDetails(this.userId, String(oid));
    } catch (e) {
      console.error('加载订单详情失败');
    }
  }

  statusText(status: number | null): string {
    if (status === null) return '';
    switch (status) {
      case -1: return '已取消';
      case 0: return '待支付';
      case 1: return '待发货';
      case 2: return '待收货';
      case 3: return '已完成';
      default: return '未知状态';
    }
  }

  async cancelOrder() {
    if (!this.order || !this.order.oid) return;
    try {
      await OrderService.cancelOrder(this.userId, this.order.oid);
      console.info('订单已取消');
      router.back();
    } catch (e) {
      console.info('取消订单失败');
    }
  }

  async confirmReceive() {
    if (!this.order || !this.order.oid) return;
    try {
      await OrderService.confirmOrder(this.userId, this.order.oid);
      console.info('确认收货成功');
      router.back();
    } catch (e) {
      console.info('确认收货失败');
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
        Text('订单详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.order) {
        Scroll() {
          Column() {
            // 订单状态
            Column() {
              Text(this.statusText(this.order.status))
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.ui_primary_red'))
              Text('订单编号: ' + (this.order.orderNum || this.order.oid || '--'))
                .fontSize(13)
                .fontColor($r('app.color.ui_text_light'))
                .margin({ top: 8 })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .alignItems(HorizontalAlign.Start)

            // 收货地址
            if (this.order.address) {
              Column() {
                Text('收货信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 })
                Row() {
                  Text(this.order.address.receiverName || '')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                  Text(this.order.address.receiverPhone || '')
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_hint'))
                    .margin({ left: 12 })
                }
                Text(this.order.address.receiverAddress || '')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_hint'))
                  .margin({ top: 4 })
              }
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })
              .alignItems(HorizontalAlign.Start)
            }

            // 商品列表
            if (this.order.items && this.order.items.length > 0) {
              Column() {
                Text('商品信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 })
                ForEach(this.order.items, (item: OrderDerailsItem) => {
                  Row() {
                    Image(item.piconUrl.startsWith('http') ? item.piconUrl : (Constants.DOMAIN + item.piconUrl))
                      .width(60)
                      .height(60)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(4)
                    Column() {
                      Text(item.pname || '')
                        .fontSize(14)
                        .fontColor($r('app.color.ui_text_dark'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      if (item.version) {
                        Text(item.version)
                          .fontSize(12)
                          .fontColor($r('app.color.ui_text_light'))
                          .margin({ top: 2 })
                      }
                      Row() {
                        Text('¥' + (item.amount || 0))
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
                  .margin({ bottom: 8 })
                })
              }
              .padding(16)
              .backgroundColor(Color.White)
              .margin({ top: 8 })
            }

            // 金额信息
            Column() {
              Text('金额信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 })
              Row() {
                Text('商品金额')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Text('¥' + ((this.order.totalPrice || 0) - (this.order.freight || 0)))
                  .fontSize(14)
                  .margin({ left: 'auto' })
              }
              .width('100%')
              Row() {
                Text('运费')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_dark'))
                Text('¥' + (this.order.freight || 0))
                  .fontSize(14)
                  .margin({ left: 'auto' })
              }
              .width('100%')
              .margin({ top: 8 })
              Divider().margin({ top: 8, bottom: 8 })
              Row() {
                Text('实付款')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Text('¥' + (this.order.totalPrice || 0))
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

            // 订单信息
            Column() {
              Row() {
                Text('下单时间')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_hint'))
                Text(this.order.buyTime || '--')
                  .fontSize(14)
                  .margin({ left: 'auto' })
              }
              .width('100%')
              Row() {
                Text('支付方式')
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_hint'))
                Text(this.order.payWay === 0 ? '在线支付' : '货到付款')
                  .fontSize(14)
                  .margin({ left: 'auto' })
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 8 })
          }
        }
        .layoutWeight(1)

        // 底部操作按钮
        Row() {
          if (this.order.status === 0) {
            Button('取消订单')
              .type(ButtonType.Capsule)
              .height(36)
              .fontSize(13)
              .backgroundColor(Color.White)
              .fontColor($r('app.color.ui_text_hint'))
              .border({ width: 1, color: $r('app.color.ui_border_light') })
              .onClick(() => {
                this.cancelOrder();
              })
            Button('去支付')
              .type(ButtonType.Capsule)
              .height(36)
              .fontSize(13)
              .backgroundColor($r('app.color.ui_primary_red'))
              .fontColor(Color.White)
              .margin({ left: 12 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/PayInfoPage',
                  params: {
                    tn: this.order?.tn || '',
                    userId: this.userId
                  }
                });
              })
          }
          if (this.order.status === 2) {
            Button('确认收货')
              .type(ButtonType.Capsule)
              .height(36)
              .fontSize(13)
              .backgroundColor($r('app.color.ui_primary_red'))
              .fontColor(Color.White)
              .onClick(() => {
                this.confirmReceive();
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_search_bg'))
  }
}
