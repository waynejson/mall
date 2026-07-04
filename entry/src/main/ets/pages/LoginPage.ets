import { UserService } from '../service/UserService';
import { RResult } from '../model/RResult';
import { Constants } from '../common/Constants';
import { preferences } from '@kit.ArkData';
import { LoadingDialog } from '../components/LoadingDialog';

/**
 * 登录页
 * 对应 Android 项目中的 LoginActivity.java
 * 登录成功后通过AppStorage触发Index页面切换到首页
 */
@Entry
@Component
export struct LoginPage {
  @State userName: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  @State showError: boolean = false;

  private context = getContext(this);

  async login() {
    if (!this.userName || this.userName.trim().length === 0) {
      this.errorMsg = '请输入用户名';
      this.showError = true;
      return;
    }
    if (!this.password || this.password.trim().length === 0) {
      this.errorMsg = '请输入密码';
      this.showError = true;
      return;
    }

    this.showError = false;
    this.isLoading = true;

    try {
      const ret: RResult = await UserService.login(this.userName, this.password);
      this.isLoading = false;

      if (ret.success) {
        const uid = UserService.resolveUserIdAfterLogin(ret);
        // 保存用户信息到全局存储
        AppStorage.setOrCreate(Constants.STORAGE_USER_ID, uid);
        AppStorage.setOrCreate(Constants.STORAGE_USER_NAME, this.userName);
        AppStorage.setOrCreate(Constants.STORAGE_IS_LOGGED_IN, true);

        // 持久化存储
        try {
          const store = await preferences.getPreferences(this.context, 'user_prefs');
          await store.put(Constants.STORAGE_USER_ID, uid);
          await store.put(Constants.STORAGE_USER_NAME, this.userName);
          await store.put(Constants.STORAGE_IS_LOGGED_IN, true);
          await store.flush();
        } catch (e) {
          console.error('保存用户信息失败: ' + JSON.stringify(e));
        }

        console.info('登录成功');
        // 登录成功后，AppStorage的变化会触发Index页面重新渲染，自动切换到首页
      } else {
        this.errorMsg = ret.errorMsg || '登录失败';
        this.showError = true;
      }
    } catch (e) {
      this.isLoading = false;
      const errMsg = JSON.stringify(e);
      console.error('登录异常: ' + errMsg);
      this.errorMsg = '登录失败，请检查网络';
      this.showError = true;
    }
  }

  build() {
    Column() {
      // Logo区域
      Column() {
        Image($r('app.media.login_icon'))
          .width(80)
          .height(80)
          .borderRadius(16)
        Text('京东商城')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ui_primary_red'))
          .margin({ top: 12 })
      }
      .margin({ top: 80 })
      .alignItems(HorizontalAlign.Center)

      // 表单区域
      Column() {
        // 用户名输入
        Row() {
          Image($r('app.media.icon_user'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .margin({ right: 12 })
          TextInput({ placeholder: '请输入用户名', text: this.userName })
            .type(InputType.Normal)
            .layoutWeight(1)
            .height(48)
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.userName = value;
              this.showError = false;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .border({ width: { bottom: 1 }, color: $r('app.color.ui_divider') })

        // 密码输入
        Row() {
          Image($r('app.media.icon_p'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .margin({ right: 12 })
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .layoutWeight(1)
            .height(48)
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.password = value;
              this.showError = false;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .border({ width: { bottom: 1 }, color: $r('app.color.ui_divider') })
        .margin({ top: 8 })

        // 错误提示
        if (this.showError) {
          Text(this.errorMsg)
            .fontSize(13)
            .fontColor($r('app.color.ui_primary_red'))
            .margin({ top: 8, left: 16 })
            .width('100%')
        }

        // 登录按钮
        Button('登 录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .backgroundColor($r('app.color.ui_primary_red'))
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24 })
          .onClick(() => {
            this.login();
          })

        // 注册和忘记密码
        Row() {
          Text('没有账号，注册')
            .fontSize(14)
            .fontColor($r('app.color.ui_text_hint'))
            .onClick(() => {
              // TODO: 跳转注册页
            })

          Text('忘记密码')
            .fontSize(14)
            .fontColor($r('app.color.ui_text_hint'))
            .margin({ left: 'auto' })
            .onClick(() => {
              // TODO: 跳转重置密码页
            })
        }
        .width('100%')
        .margin({ top: 20 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('90%')
      .margin({ top: 40 })

      // Loading弹窗
      LoadingDialog({ isVisible: this.isLoading, message: '登录中...' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
