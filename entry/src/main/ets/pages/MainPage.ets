import { BottomBar } from '../components/BottomBar';
import { HomeComponent } from '../components/HomeComponent';
import { CategoryComponent } from '../components/CategoryComponent';
import { ShopcartComponent } from '../components/ShopcartComponent';
import { MineComponent } from '../components/MineComponent';

/**
 * 主页面（4个Tab）
 * 对应 Android 项目中的 MainActivity.java
 * 包含底部导航栏和4个Tab页面
 */
@Entry
@Component
export struct MainPage {
  @State currentIndex: number = 0;

  build() {
    Column() {
      // 内容区域 - 根据Tab索引显示对应组件
      if (this.currentIndex === 0) {
        HomeComponent()
          .layoutWeight(1)
      } else if (this.currentIndex === 1) {
        CategoryComponent()
          .layoutWeight(1)
      } else if (this.currentIndex === 2) {
        ShopcartComponent()
          .layoutWeight(1)
      } else if (this.currentIndex === 3) {
        MineComponent()
          .layoutWeight(1)
      }

      // 底部导航栏
      BottomBar({
        currentIndex: this.currentIndex,
        onTabChange: (index: number) => {
          this.currentIndex = index;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_page_bg'))
  }
}
