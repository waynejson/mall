import { UserService } from '../service/UserService';
import { LoadingDialog } from '../components/LoadingDialog';
import { router } from '@kit.ArkUI';

/**
 * 重置密码页
 * 对应 Android 项目中的 ResetActivity.java
 */
@Entry
@Component
export struct ResetPage {
  @State userName: string = '';
  @State isLoading: boolean = false;

  async reset() {
    if (!this.userName || this.userName.trim().length === 0) {
      console.info('请输入用户名');
      return;
    }
    this.isLoading = true;
    try {
      const ret = await UserService.resetPassword(this.userName);
      this.isLoading = false;
      if (ret.success) {
        console.info('重置成功');
        router.back();
      } else {
        console.info(ret.errorMsg || '重置失败');
      }
    } catch (e) {
      this.isLoading = false;
      console.info('重置失败，请检查网络');
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
          Text('重置密码')
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
          .margin({ top: 40, bottom: 24 })
          .onChange((value: string) => {
            this.userName = value;
          })

        // 重置按钮
        Button('重置密码')
          .type(ButtonType.Capsule)
          .width('90%')
          .height(44)
          .backgroundColor($r('app.color.ui_primary_red'))
          .fontColor(Color.White)
          .fontSize(16)
          .onClick(() => {
            this.reset();
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      LoadingDialog({ isVisible: this.isLoading, message: '重置中...' })
    }
    .width('100%')
    .height('100%')
  }
}
