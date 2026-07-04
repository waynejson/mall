/**
 * 商品详情顶部Tab栏
 * 对应 Android 项目中的 TopBar.java
 */
@Component
export struct TopBar {
  @Prop currentIndex: number = 0;
  onTabChange: (index: number) => void = () => {};

  private tabs: string[] = ['商品', '详情', '评价'];

  build() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(16)
            .fontColor(this.currentIndex === index ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_dark'))
            .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
          Divider()
            .strokeWidth(2)
            .color(this.currentIndex === index ? $r('app.color.ui_primary_red') : 'transparent')
            .width('60%')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .height(44)
        .onClick(() => {
          this.onTabChange(index);
        })
      })
    }
    .width('100%')
    .height(44)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 0.5 }, color: $r('app.color.ui_border_min') })
  }
}
