import { OrderService } from '../service/OrderService';
import { Constants } from '../common/Constants';
import { OrderByStatusBean } from '../model/OrderByStatusBean';
import { router } from '@kit.ArkUI';

/**
 * 订单列表页
 * 对应 Android 项目中的 OrderListActivity.java
 */
@Entry
@Component
struct OrderListPage {
  @State orderList: OrderByStatusBean[] = [];
  @State currentStatus: number = -999;
  @State userId: number = 1;
  @State isLoading: boolean = true;
  private isDestroyed: boolean = false;

  private statusTabs: string[] = ['全部', '待付款', '待发货', '待收货', '已完成'];
  private statusValues: number[] = [-999, 0, 1, 2, 3];

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    // 从路由参数获取status
    const params = router.getParams() as Record<string, Object>;
    if (params && params['status'] !== undefined) {
      this.currentStatus = params['status'] as number;
    }
    this.loadOrders();
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async loadOrders() {
    this.isLoading = true;
    try {
      if (this.currentStatus === -999) {
        const statuses = [0, 1, 2, 3, -1];
        const results = await Promise.allSettled(
          statuses.map((status: number) => OrderService.getOrdersByStatus(this.userId, status))
        );

        if (this.isDestroyed) {
          return;
        }

        const allOrders: OrderByStatusBean[] = [];
        const seenOids = new Set<number>();
        for (const result of results) {
          if (result.status === 'fulfilled' && result.value) {
            for (const order of result.value) {
              if (order.oid !== null && !seenOids.has(order.oid)) {
                seenOids.add(order.oid);
                allOrders.push(order);
              }
            }
          }
        }
        this.orderList = allOrders;
      } else {
        const orders = await OrderService.getOrdersByStatus(this.userId, this.currentStatus);
        if (!this.isDestroyed) {
          this.orderList = orders || [];
        }
      }
    } catch (e) {
      console.error('加载订单失败');
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
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
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

        // 状态Tab
        Row() {
          ForEach(this.statusTabs, (tab: string, index: number) => {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentStatus === this.statusValues[index] ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_hint'))
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .height(44)
              .border({ width: { bottom: this.currentStatus === this.statusValues[index] ? 2 : 0 }, color: $r('app.color.ui_primary_red') })
              .onClick(() => {
                if (this.currentStatus !== this.statusValues[index]) {
                  this.currentStatus = this.statusValues[index];
                  this.loadOrders();
                }
              })
          })
        }
        .width('100%')
        .backgroundColor(Color.White)

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
        } else if (this.orderList.length === 0) {
          Column() {
            Text('暂无订单')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_light'))
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.orderList, (order: OrderByStatusBean) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('订单号: ' + (order.orderNum || order.oid))
                      .fontSize(13)
                      .fontColor($r('app.color.ui_text_hint'))
                    Text(this.statusText(order.status))
                      .fontSize(13)
                      .fontColor(order.status === 0 ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_light'))
                      .margin({ left: 'auto' })
                  }
                  .width('100%')

                  if (order.items && order.items.length > 0) {
                    Row() {
                      ForEach(order.items.slice(0, 3), (url: string) => {
                        Image(url.startsWith('http') ? url : (Constants.DOMAIN + url))
                          .width(60)
                          .height(60)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(4)
                          .margin({ right: 8 })
                      })
                    }
                    .margin({ top: 8 })
                  }

                  Row() {
                    Text('¥' + (order.totalPrice || 0))
                      .fontSize(16)
                      .fontColor($r('app.color.ui_primary_red'))
                      .fontWeight(FontWeight.Bold)
                    Text('查看详情 >')
                      .fontSize(12)
                      .fontColor($r('app.color.ui_text_light'))
                      .margin({ left: 'auto' })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .padding(16)
                .backgroundColor(Color.White)
                .margin({ top: 8 })
              }
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/OrderDetailPage',
                  params: {
                    oid: order.oid || 0,
                    userId: this.userId
                  }
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
