import { router } from '@kit.ArkUI';
import { CategoryService } from '../service/CategoryService';
import { Constants } from '../common/Constants';
import { CategoryBean } from '../model/CategoryBean';
import { SubCategoryBean } from '../model/SubCategoryBean';
import { ThirdCategoryBean } from '../model/ThirdCategoryBean';

/**
 * 分类Tab组件
 * 对应 Android 项目中的 CategoryFragment.java
 */
@Component
export struct CategoryComponent {
  @State topCategories: CategoryBean[] = [];
  @State subCategories: SubCategoryBean[] = [];
  @State selectedTopIndex: number = 0;
  @State isLoading: boolean = true;
  @State isSubLoading: boolean = false;
  @State searchKeyword: string = '';
  private isDestroyed: boolean = false;

  aboutToAppear() {
    this.loadTopCategory();
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async loadTopCategory() {
    this.isLoading = true;
    try {
      const categories = await CategoryService.getTopCategory();
      if (!this.isDestroyed) {
        this.topCategories = categories;
        if (categories.length > 0) {
          this.loadSubCategory(categories[0].id);
        }
      }
    } catch (e) {
      console.error('加载分类失败');
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  async loadSubCategory(parentId: number) {
    this.isSubLoading = true;
    try {
      const subCategories = await CategoryService.getSubCategory(parentId);
      if (!this.isDestroyed) {
        this.subCategories = subCategories;
      }
    } catch (e) {
      console.error('加载子分类失败');
    } finally {
      if (!this.isDestroyed) {
        this.isSubLoading = false;
      }
    }
  }

  build() {
    Column() {
      // 顶部搜索栏 - 与Android一致
      Row() {
        // 扫码图标
        Image($r('app.media.scan'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .margin({ right: 5 })

        // 搜索框
        Row() {
          Image($r('app.media.icon_search'))
            .width(24)
            .height('100%')
            .objectFit(ImageFit.Contain)

          TextInput({ placeholder: '搜索商品', text: this.searchKeyword })
            .type(InputType.Normal)
            .layoutWeight(1)
            .height('100%')
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              if (this.searchKeyword.trim().length > 0) {
                router.pushUrl({
                  url: 'pages/ProductListPage',
                  params: { keyword: this.searchKeyword.trim() }
                });
              }
            })
        }
        .layoutWeight(1)
        .height(36)
        .borderRadius(18)
        .backgroundColor($r('app.color.ui_search_bg'))
        .padding({ left: 12, right: 12 })

        // 消息图标
        Image($r('app.media.message'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .margin({ left: 5 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)

      // 主体内容区域
      Row() {
        // 左侧一级分类
        List() {
          ForEach(this.topCategories, (category: CategoryBean, index: number) => {
            ListItem() {
              Text(category.name)
                .fontSize(14)
                .fontColor(this.selectedTopIndex === index ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_dark'))
                .textAlign(TextAlign.Center)
                .width('100%')
                .height(50)
                .backgroundColor(this.selectedTopIndex === index ? '#FFFFFF' : $r('app.color.ui_sub_bg'))
                .border({ width: { left: this.selectedTopIndex === index ? 3 : 0 }, color: $r('app.color.ui_primary_red') })
            }
            .onClick(() => {
              if (this.selectedTopIndex !== index) {
                this.selectedTopIndex = index;
                this.loadSubCategory(category.id);
              }
            })
          })
        }
        .width(80)
        .height('100%')
        .backgroundColor($r('app.color.ui_sub_bg'))

        // 右侧二级分类
        if (this.isSubLoading) {
          Column() {
            LoadingProgress()
              .width(30)
              .height(30)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Color.White)
        } else {
          Scroll() {
            Column() {
              // 分类广告图
              if (this.topCategories.length > 0 &&
                  this.topCategories[this.selectedTopIndex] &&
                  this.topCategories[this.selectedTopIndex].bannerUrl &&
                  this.topCategories[this.selectedTopIndex].bannerUrl.length > 0) {
                Image(this.topCategories[this.selectedTopIndex].bannerUrl.startsWith('http')
                  ? this.topCategories[this.selectedTopIndex].bannerUrl
                  : (Constants.DOMAIN + this.topCategories[this.selectedTopIndex].bannerUrl))
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(4)
                  .margin({ left: 8, right: 8, top: 8 })
              }

              ForEach(this.subCategories, (sub: SubCategoryBean) => {
                Column() {
                  Text(sub.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.ui_text_dark'))
                    .margin({ left: 16, top: 16, bottom: 8 })

                  if (sub.thirdCategory && sub.thirdCategory.length > 0) {
                    Grid() {
                      ForEach(sub.thirdCategory, (third: ThirdCategoryBean) => {
                        GridItem() {
                          Column() {
                            if (third.bannerUrl && third.bannerUrl.length > 0) {
                              Image(third.bannerUrl.startsWith('http') ? third.bannerUrl : (Constants.DOMAIN + third.bannerUrl))
                                .width(50)
                                .height(50)
                                .objectFit(ImageFit.Cover)
                                .borderRadius(4)
                            }
                            Text(third.name)
                              .fontSize(12)
                              .fontColor($r('app.color.ui_text_hint'))
                              .margin({ top: 4 })
                              .maxLines(2)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                          .width('100%')
                          .padding(8)
                        }
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/ProductListPage',
                            params: { keyword: third.name, categoryId: third.id }
                          });
                        })
                      })
                    }
                    .columnsTemplate('1fr 1fr 1fr')
                    .columnsGap(8)
                    .rowsGap(8)
                    .width('100%')
                    .padding({ left: 16, right: 16 })
                  }
                }
              })
            }
          }
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.White)
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_page_bg'))
  }
}
