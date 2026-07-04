import { router } from '@kit.ArkUI';
import { Constants } from '../common/Constants';
import { preferences } from '@kit.ArkData';

/**
 * 我的Tab组件
 * 对应 Android 项目中的 MineFragment.java
 */
@Component
export struct MineComponent {
  @StorageProp(Constants.STORAGE_USER_NAME) userName: string = '';
  private context = getContext(this);

  async logout() {
    // 清除AppStorage中的登录状态
    AppStorage.setOrCreate(Constants.STORAGE_IS_LOGGED_IN, false);
    AppStorage.setOrCreate(Constants.STORAGE_USER_ID, 0);
    AppStorage.setOrCreate(Constants.STORAGE_USER_NAME, '');

    // 清除持久化存储
    try {
      const store = await preferences.getPreferences(this.context, 'user_prefs');
      await store.delete(Constants.STORAGE_USER_ID);
      await store.delete(Constants.STORAGE_USER_NAME);
      await store.delete(Constants.STORAGE_IS_LOGGED_IN);
      await store.flush();
    } catch (e) {
      console.error('清除用户信息失败');
    }

    // 登录状态变化后，Index.ets会自动检测并切换到登录页
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('我的')
          .fontSize(18)
          .fontColor($r('app.color.bot_text_color_normal'))
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(48)
          .backgroundColor(Color.White)

        Divider().color($r('app.color.ui_indicator_red')).strokeWidth(1)

        // 用户信息区域
        Column() {
          Image($r('app.media.user_mgr'))
            .width(70)
            .height(70)
            .borderRadius(35)
            .objectFit(ImageFit.Cover)

          Text(this.userName || '未登录')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })

          Text('普通会员')
            .fontSize(16)
            .fontColor($r('app.color.ui_text_hint'))
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ bottom: 5 })
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Center)

        Divider().color($r('app.color.ui_divider_light')).strokeWidth(1)

        // 待付款/待收货区域
        Row() {
          Column() {
            Text('0')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_mine_func'))
            Text('待付款')
              .fontSize(14)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(50)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/OrderListPage', params: { status: 0 } });
          })

          Divider().vertical(true).color($r('app.color.ui_divider_light')).strokeWidth(1).height(40)

          Column() {
            Text('0')
              .fontSize(16)
              .fontColor($r('app.color.ui_text_mine_func'))
            Text('待收货')
              .fontSize(14)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(50)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/OrderListPage', params: { status: 2 } });
          })
        }
        .width('100%')
        .backgroundColor(Color.White)

        Divider().color($r('app.color.ui_divider_light')).strokeWidth(1)

        // 8个功能模块 - 第一行
        Row() {
          Column() {
            Image($r('app.media.mine_order'))
              .width(50)
              .height(50)
            Text('全部订单')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/OrderListPage' });
          })

          Column() {
            Image($r('app.media.mine_wallet'))
              .width(50)
              .height(50)
            Text('我的钱包')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_record'))
              .width(50)
              .height(50)
            Text('浏览记录')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_follow'))
              .width(50)
              .height(50)
            Text('我的关注')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .backgroundColor(Color.White)

        // 8个功能模块 - 第二行
        Row() {
          Column() {
            Image($r('app.media.mine_manager'))
              .width(50)
              .height(50)
            Text('服务管家')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_account'))
              .width(50)
              .height(50)
            Text('账户管理')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_bespoke'))
              .width(50)
              .height(50)
            Text('我的预约')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_app'))
              .width(50)
              .height(50)
            Text('应用推荐')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_mine_func'))
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(100)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .margin({ top: 10 })

        // 退出登录按钮
        Button('退 出 登 录')
          .type(ButtonType.Capsule)
          .width('85%')
          .height(44)
          .backgroundColor($r('app.color.ui_primary_red'))
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 40 })
          .onClick(() => {
            this.logout();
          })
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor($r('app.color.ui_page_bg'))
    .scrollBar(BarState.Off)
  }
}
