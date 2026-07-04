/**
 * 加载弹窗组件
 * 对应 Android 项目中的 LoadingDialog.java
 */
@Component
export struct LoadingDialog {
  @Prop isVisible: boolean = false;
  @Prop message: string = '加载中...';
  @State currentFrame: number = 1;
  private timerId: number = -1;

  aboutToAppear() {
    this.startAnimation();
  }

  aboutToDisappear() {
    this.stopAnimation();
  }

  startAnimation() {
    this.timerId = setInterval(() => {
      this.currentFrame = (this.currentFrame % 12) + 1;
    }, 100);
  }

  stopAnimation() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    if (this.isVisible) {
      Column() {
        Column() {
          Image($r('app.media.loading_progressbar' + this.currentFrame))
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
          Text(this.message)
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 12 })
        }
        .padding(24)
        .borderRadius(12)
        .backgroundColor($r('app.color.ui_dialog_bg'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .position({ x: 0, y: 0 })
    }
  }
}
