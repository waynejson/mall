@Component
export struct BottomBar {
  @Prop currentIndex: number = 0;
  onTabChange: (index: number) => void = () => {};

  @Builder
  tabItem(index: number, label: string, normalIcon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedIcon : normalIcon)
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index ?   $r('app.color.ui_text_dark'):$r('app.color.ui_primary_red'))
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .onClick(() => {
      this.onTabChange(index);
    })
  }

  build() {
    Row() {
      this.tabItem(0, '首页', $r('app.media.bot_bar_home'), $r('app.media.bot_bar_home_selected'))
      this.tabItem(1, '分类', $r('app.media.bot_bar_category'), $r('app.media.bot_bar_category_selected'))
      this.tabItem(2, '购物车', $r('app.media.bot_bar_shopcar'), $r('app.media.bot_bar_shopcar_selected'))
      this.tabItem(3, '我的', $r('app.media.bot_bar_mime'), $r('app.media.bot_bar_mime_selected'))
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .border({ width: { top: 0.5 }, color: $r('app.color.ui_border_min') })
  }
}
