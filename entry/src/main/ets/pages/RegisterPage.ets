import { UserService } from '../service/UserService';
import { LoadingDialog } from '../components/LoadingDialog';
import { router } from '@kit.ArkUI';

/**
 * 注册页
 * 对应 Android 项目中的 RegActivity.java
 */
@Entry
@Component
export struct RegisterPage {
  @State userName: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  async register() {
    if (!this.userName || this.userName.trim().length === 0 ||
        !this.password || this.password.trim().length === 0) {
      console.info('请输入用户名和密码');
      return;
    }
    this.isLoading = true;
    try {
      const ret = await UserService.register(this.userName, this.password);
      this.isLoading = false;
      if (ret.success) {
        console.info('注册成功');
        router.back();
      } else {
        console.info(ret.errorMsg || '注册失败');
      }
    } catch (e) {
      this.isLoading = false;
      console.info('注册失败，请检查网络');
    }
  }

  build() {
    Stack() {
      Column() {
        // 返回按钮
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor($r('app.color.ui_text_dark'))
            .onClick(() => {
              router.back();
            })
          Text('用户注册')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding(16)

        // 用户名输入
        TextInput({ placeholder: '请输入用户名', text: this.userName })
          .type(InputType.Normal)
          .height(48)
          .width('90%')
          .margin({ top: 40, bottom: 16 })
          .onChange((value: string) => {
            this.userName = value;
          })

        // 密码输入
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .height(48)
          .width('90%')
          .margin({ bottom: 24 })
          .onChange((value: string) => {
            this.password = value;
          })

        // 注册按钮
        Button('注册')
          .type(ButtonType.Capsule)
          .width('90%')
          .height(44)
          .backgroundColor($r('app.color.ui_primary_red'))
          .fontColor(Color.White)
          .fontSize(16)
          .onClick(() => {
            this.register();
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      LoadingDialog({ isVisible: this.isLoading, message: '注册中...' })
    }
    .width('100%')
    .height('100%')
  }
}
