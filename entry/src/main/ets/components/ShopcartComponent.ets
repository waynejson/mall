import { router } from '@kit.ArkUI';
import { ShopCarService } from '../service/ShopCarService';
import { AddressService } from '../service/AddressService';
import { Constants } from '../common/Constants';
import { ShopCarInfoBean } from '../model/ShopCarInfoBean';

/**
 * 购物车Tab组件
 * 对应 Android 项目中的 ShopcartFragment.java
 */
@Component
export struct ShopcartComponent {
  @State cartList: ShopCarInfoBean[] = [];
  @State selectAll: boolean = false;
  @State totalPrice: number = 0;
  @State selectedCount: number = 0;
  @State userId: number = 1;
  @State isLoading: boolean = true;
  @State isCheckingOut: boolean = false;
  private isDestroyed: boolean = false;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    this.loadCartData();
  }

  aboutToDisappear() {
    this.isDestroyed = true;
  }

  async loadCartData() {
    this.isLoading = true;
    try {
      const list = await ShopCarService.getShopCarList(this.userId);
      if (!this.isDestroyed && list) {
        this.cartList = list;
        this.updateSummary();
      }
    } catch (e) {
      console.error('加载购物车失败');
    } finally {
      if (!this.isDestroyed) {
        this.isLoading = false;
      }
    }
  }

  updateSummary() {
    let total = 0;
    let count = 0;
    for (const item of this.cartList) {
      if (item.isChecked) {
        total += item.pprice * item.buyCount;
        count++;
      }
    }
    this.totalPrice = total;
    this.selectedCount = count;
    this.selectAll = count === this.cartList.length && this.cartList.length > 0;
  }

  toggleSelectAll(isOn: boolean) {
    this.selectAll = isOn;
    for (let i = 0; i < this.cartList.length; i++) {
      this.cartList[i].isChecked = isOn;
    }
    this.updateSummary();
  }

  toggleItem(index: number) {
    this.cartList[index].isChecked = !this.cartList[index].isChecked;
    this.updateSummary();
  }

  async deleteItem(index: number) {
    const item = this.cartList[index];
    try {
      await ShopCarService.deleteShopCar(this.userId, item.id);
      if (!this.isDestroyed) {
        this.cartList.splice(index, 1);
        this.updateSummary();
      }
    } catch (e) {
      console.error('删除失败');
    }
  }

  async checkout() {
    if (this.selectedCount === 0 || this.isCheckingOut) {
      console.info('请选择商品');
      return;
    }
    const selectedItems: ShopCarInfoBean[] = [];
    for (const item of this.cartList) {
      if (item.isChecked && item.buyCount > 0) {
        selectedItems.push(item);
      }
    }
    if (selectedItems.length === 0) {
      console.info('没有可结算的商品');
      return;
    }
    this.isCheckingOut = true;
    // 获取地址
    try {
      const addressList = await AddressService.getAddressList({ userId: this.userId, isDefault: true });
      if (!this.isDestroyed) {
        router.pushUrl({
          url: 'pages/OrderConfirmPage',
          params: {
            addressInfo: JSON.stringify(addressList),
            productInfo: JSON.stringify(selectedItems)
          }
        });
      }
    } catch (e) {
      console.error('获取地址失败');
    } finally {
      this.isCheckingOut = false;
    }
  }

  build() {
    Column() {
      // 标题
      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.bot_text_color_normal'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .height(48)
        .backgroundColor(Color.White)

      Divider().color($r('app.color.ui_divider')).strokeWidth(1)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.ui_text_light'))
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cartList.length === 0) {
        Column() {
          Image($r('app.media.data_null'))
            .width(150)
            .height(150)
            .objectFit(ImageFit.Contain)
          Text('购物车是空的')
            .fontSize(16)
            .fontColor($r('app.color.ui_text_light'))
            .margin({ top: 16 })
          Button('去逛逛')
            .type(ButtonType.Capsule)
            .backgroundColor($r('app.color.ui_primary_red'))
            .fontColor(Color.White)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.cartList, (item: ShopCarInfoBean, index: number) => {
            ListItem() {
              Row() {
                // 选中框 - 使用Toggle组件
                Toggle({ type: ToggleType.Checkbox, isOn: item.isChecked })
                  .selectedColor($r('app.color.ui_primary_red'))
                  .width(24)
                  .height(24)
                  .onChange((isOn: boolean) => {
                    this.cartList[index].isChecked = isOn;
                    this.updateSummary();
                  })

                // 商品图片
                Image(item.pimageUrl.startsWith('http') ? item.pimageUrl : (Constants.DOMAIN + item.pimageUrl))
                  .width(100)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                  .margin({ left: 10 })

                // 商品信息
                Column() {
                  Text(item.pname)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_dark'))
                    .fontWeight(FontWeight.Bold)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  if (item.pversion && item.pversion.length > 0) {
                    Text('规格：' + item.pversion)
                      .fontSize(13)
                      .fontColor($r('app.color.ui_text_secondary'))
                      .margin({ top: 4 })
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }

                  Text(item.pname)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_secondary'))
                    .margin({ top: 4 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Row() {
                    Text('¥' + item.pprice)
                      .fontSize(20)
                      .fontColor($r('app.color.ui_primary_red'))
                      .fontWeight(FontWeight.Bold)

                    // 数量选择器
                    Row() {
                      Text('-')
                        .fontSize(20)
                        .fontColor($r('app.color.ui_text_dark'))
                        .width(36)
                        .height(36)
                        .textAlign(TextAlign.Center)
                        .backgroundColor($r('app.color.ui_search_bg'))
                        .borderRadius({ topLeft: 4, bottomLeft: 4 })
                        .onClick(() => {
                          if (item.buyCount > 1) {
                            this.cartList[index].buyCount--;
                            this.updateSummary();
                          }
                        })

                      Text(item.buyCount.toString())
                        .fontSize(14)
                        .fontColor($r('app.color.ui_text_dark'))
                        .width(44)
                        .height(36)
                        .textAlign(TextAlign.Center)
                        .backgroundColor($r('app.color.ui_search_bg'))

                      Text('+')
                        .fontSize(20)
                        .fontColor($r('app.color.ui_text_dark'))
                        .width(36)
                        .height(36)
                        .textAlign(TextAlign.Center)
                        .backgroundColor($r('app.color.ui_search_bg'))
                        .borderRadius({ topRight: 4, bottomRight: 4 })
                        .onClick(() => {
                          this.cartList[index].buyCount++;
                          this.updateSummary();
                        })
                    }
                    .margin({ left: 12 })
                    .border({ width: 1, color: $r('app.color.ui_divider'), radius: 4 })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .layoutWeight(1)
                .margin({ left: 10 })
                .alignItems(HorizontalAlign.Start)

                // 删除按钮
                Column() {
                  Text('删除')
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_dark'))
                }
                .width(46)
                .height(46)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .border({ width: 1, color: $r('app.color.ui_primary_red'), radius: 23 })
                .margin({ left: 8 })
                .onClick(() => {
                  this.deleteItem(index);
                })
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .backgroundColor(Color.White)
              .margin({ bottom: 8 })
              .borderRadius(8)
            }
          })
        }
        .layoutWeight(1)
        .padding(8)

        // 底部结算栏
        Row() {
          // 全选
          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: this.selectAll })
              .selectedColor($r('app.color.ui_primary_red'))
              .width(22)
              .height(22)
              .onChange((isOn: boolean) => {
                this.toggleSelectAll(isOn);
              })
            Text('全选')
              .fontSize(14)
              .fontColor($r('app.color.ui_text_secondary'))
              .margin({ left: 4 })
          }
          .onClick(() => {
            this.toggleSelectAll(!this.selectAll);
          })

          // 合计金额
          Column() {
            Text('合计')
              .fontSize(12)
              .fontColor($r('app.color.ui_text_secondary'))
            Text('¥' + this.totalPrice.toFixed(2))
              .fontSize(28)
              .fontColor($r('app.color.ui_primary_red'))
              .fontWeight(FontWeight.Bold)
          }
          .margin({ left: 16 })

          // 结算按钮
          Button(this.isCheckingOut ? '结算中...' : '去结算(' + this.selectedCount + ')')
            .type(ButtonType.Capsule)
            .backgroundColor($r('app.color.ui_primary_red'))
            .fontColor(Color.White)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .height('100%')
            .layoutWeight(1)
            .margin({ left: 16 })
            .enabled(!this.isCheckingOut)
            .onClick(() => {
              this.checkout();
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { top: 0.5 }, color: $r('app.color.ui_border_min') })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_page_bg'))
  }
}
