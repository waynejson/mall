import { OrderService } from '../service/OrderService';
import { PayInfoBean } from '../model/PayInfoBean';
import { router } from '@kit.ArkUI';

/**
 * 支付信息页
 * 对应 Android 项目中的 PayInfoActivity.java
 */
@Entry
@Component
export struct PayInfoPage {
  @State payInfo: PayInfoBean | null = null;
  @State tn: string = '';
  @State userId: number = 1;
  @State payPassword: string = '';

  aboutToAppear() {
    // 从路由参数获取数据
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['tn']) {
        this.tn = params['tn'] as string;
      }
      if (params['userId']) {
        this.userId = params['userId'] as number;
      }
      if (params['payInfoJson']) {
        this.payInfo = JSON.parse(params['payInfoJson'] as string) as PayInfoBean;
      }
    }
    if (!this.payInfo && this.tn.length > 0) {
      this.loadPayInfo();
    }
  }

  async loadPayInfo() {
    try {
      this.payInfo = await OrderService.getPayInfo(this.tn, this.userId);
    } catch (e) {
      console.error('获取支付信息失败');
    }
  }

  async doPay() {
    if (this.payPassword.length === 0) {
      console.info('请输入支付密码');
      return;
    }
    try {
      await OrderService.pay('15018888888', '123456', this.payPassword, this.tn, this.userId);
      console.info('支付成功');
      router.back();
    } catch (e) {
      console.info('支付失败: ' + (e as Error).message);
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
        Text('支付信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.payInfo) {
        Column() {
          Column() {
            Text('订单号')
              .fontSize(13)
              .fontColor($r('app.color.ui_text_light'))
            Text(this.payInfo.oinfo || '--')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_dark'))
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)

          Divider()

          Column() {
            Text('商品名称')
              .fontSize(13)
              .fontColor($r('app.color.ui_text_light'))
            Text(this.payInfo.pname || '--')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_dark'))
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)

          Divider()

          Column() {
            Text('支付时间')
              .fontSize(13)
              .fontColor($r('app.color.ui_text_light'))
            Text(this.payInfo.payTime || '--')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_dark'))
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)

          Divider()

          Column() {
            Text('支付金额')
              .fontSize(13)
              .fontColor($r('app.color.ui_text_light'))
            Text('¥' + (this.payInfo.totalPrice || '--'))
              .fontSize(22)
              .fontColor($r('app.color.ui_primary_red'))
              .fontWeight(FontWeight.Bold)
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)
        }
        .backgroundColor(Color.White)
        .margin({ top: 8 })

        // 支付密码输入
        Column() {
          Text('请输入支付密码')
            .fontSize(14)
            .fontColor($r('app.color.ui_text_dark'))
            .margin({ bottom: 8 })
          TextInput({ placeholder: '支付密码', text: this.payPassword })
            .type(InputType.Password)
            .height(44)
            .onChange((value: string) => {
              this.payPassword = value;
            })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .margin({ top: 8 })

        Button('确认支付')
          .type(ButtonType.Capsule)
          .width('90%')
          .height(44)
          .backgroundColor($r('app.color.ui_primary_red'))
          .fontColor(Color.White)
          .fontSize(16)
          .margin({ top: 24 })
          .onClick(() => {
            this.doPay();
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_search_bg'))
  }
}
