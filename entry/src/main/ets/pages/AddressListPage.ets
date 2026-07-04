import { AddressService } from '../service/AddressService';
import { Constants } from '../common/Constants';
import { AddressBean } from '../model/AddressBean';
import { router } from '@kit.ArkUI';

/**
 * 收货地址列表页
 * 对应 Android 项目中的 AddressActivity.java
 */
@Entry
@Component
export struct AddressListPage {
  @State addressList: AddressBean[] = [];
  @State userId: number = 1;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    this.loadAddresses();
  }

  async loadAddresses() {
    try {
      this.addressList = await AddressService.getAddressList({ userId: this.userId, isDefault: true });
    } catch (e) {
      console.error('加载地址列表失败');
    }
  }

  async deleteAddress(address: AddressBean) {
    try {
      await AddressService.deleteAddress(this.userId, address.id);
      console.info('删除成功');
      this.loadAddresses();
    } catch (e) {
      console.info('删除失败');
    }
  }

  selectAddress(address: AddressBean) {
    AppStorage.setOrCreate('selectedAddress', JSON.stringify(address));
    router.back();
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('<')
          .fontSize(24)
          .fontColor($r('app.color.ui_text_dark'))
          .onClick(() => {
            router.back();
          })
        Text('收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 地址列表
      List() {
        ForEach(this.addressList, (address: AddressBean) => {
          ListItem() {
            Row() {
              Column() {
                Row() {
                  Text(address.receiverName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text(address.receiverPhone)
                    .fontSize(14)
                    .fontColor($r('app.color.ui_text_hint'))
                    .margin({ left: 12 })
                  if (address.isDefault) {
                    Text('默认')
                      .fontSize(11)
                      .fontColor($r('app.color.ui_primary_red'))
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .border({ width: 1, color: $r('app.color.ui_primary_red') })
                      .borderRadius(2)
                      .margin({ left: 8 })
                  }
                }
                Text(address.receiverAddress)
                  .fontSize(14)
                  .fontColor($r('app.color.ui_text_hint'))
                  .margin({ top: 4 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text('删除')
                .fontSize(12)
                .fontColor($r('app.color.ui_text_light'))
                .onClick(() => {
                  this.deleteAddress(address);
                })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ bottom: 1 })
          }
          .onClick(() => {
            this.selectAddress(address);
          })
        })
      }
      .layoutWeight(1)

      // 添加地址按钮
      Button('新增收货地址')
        .type(ButtonType.Capsule)
        .width('90%')
        .height(44)
        .backgroundColor($r('app.color.ui_primary_red'))
        .fontColor(Color.White)
        .fontSize(16)
        .margin({ top: 12, bottom: 16 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddressEditPage' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.ui_search_bg'))
  }
}
