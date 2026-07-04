import { AddressService } from '../service/AddressService';
import { Constants } from '../common/Constants';
import { AddAddressBean } from '../model/AddAddressBean';
import { CityBean } from '../model/CityBean';
import { router } from '@kit.ArkUI';

/**
 * 地址编辑页（新增/编辑）
 * 对应 Android 项目中的 AddressInfoActivity.java
 */
@Entry
@Component
export struct AddressEditPage {
  @State name: string = '';
  @State phone: string = '';
  @State addressDetails: string = '';
  @State isDefault: boolean = false;
  @State userId: number = 1;

  @State provinces: CityBean[] = [];
  @State cities: CityBean[] = [];
  @State areas: CityBean[] = [];
  @State selectedProvince: string = '';
  @State selectedCity: string = '';
  @State selectedArea: string = '';
  @State selectedProvinceCode: string = '';
  @State selectedCityCode: string = '';
  @State selectedAreaCode: string = '';
  @State showProvincePicker: boolean = false;
  @State showCityPicker: boolean = false;
  @State showAreaPicker: boolean = false;
  @State provinceSelectedIndex: number = 0;
  @State citySelectedIndex: number = 0;
  @State areaSelectedIndex: number = 0;

  aboutToAppear() {
    const uid = AppStorage.get<number>(Constants.STORAGE_USER_ID);
    if (uid) {
      this.userId = uid;
    }
    this.loadProvinces();
  }

  async loadProvinces() {
    try {
      this.provinces = await AddressService.getProvince();
    } catch (e) {
      console.error('加载省份失败');
    }
  }

  async loadCities(code: string) {
    try {
      this.cities = await AddressService.getCity(code);
      this.areas = [];
      this.selectedCity = '';
      this.selectedCityCode = '';
      this.selectedArea = '';
      this.selectedAreaCode = '';
    } catch (e) {
      console.error('加载城市失败');
    }
  }

  async loadAreas(code: string) {
    try {
      this.areas = await AddressService.getArea(code);
      this.selectedArea = '';
      this.selectedAreaCode = '';
    } catch (e) {
      console.error('加载区县失败');
    }
  }

  async saveAddress() {
    if (!this.name || this.name.trim().length === 0) {
      console.info('请输入收件人姓名');
      return;
    }
    if (!this.phone || this.phone.trim().length === 0) {
      console.info('请输入手机号');
      return;
    }
    if (!this.addressDetails || this.addressDetails.trim().length === 0) {
      console.info('请输入详细地址');
      return;
    }
    const bean: AddAddressBean = {
      userId: this.userId,
      name: this.name,
      phone: this.phone,
      provinceCode: this.selectedProvinceCode,
      cityCode: this.selectedCityCode,
      distCode: this.selectedAreaCode,
      addressDetails: this.addressDetails,
      isDefault: this.isDefault
    };
    try {
      await AddressService.addAddress(bean);
      console.info('添加地址成功');
      router.back();
    } catch (e) {
      console.info('添加地址失败: ' + (e as Error).message);
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor($r('app.color.ui_text_dark'))
            .onClick(() => {
              router.back();
            })
          Text('新增收货地址')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)

        Scroll() {
          Column() {
            Row() {
              Text('收件人')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .width(70)
              TextInput({ placeholder: '请输入收件人姓名', text: this.name })
                .type(InputType.Normal)
                .layoutWeight(1)
                .height(40)
                .onChange((value: string) => {
                  this.name = value;
                })
            }
            .padding(16)
            .backgroundColor(Color.White)

            Row() {
              Text('手机号')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .width(70)
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .type(InputType.PhoneNumber)
                .layoutWeight(1)
                .height(40)
                .onChange((value: string) => {
                  this.phone = value;
                })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })

            Row() {
              Text('省份')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .width(70)
              Text(this.selectedProvince || '请选择')
                .fontSize(14)
                .fontColor(this.selectedProvince ? $r('app.color.ui_text_dark') : $r('app.color.ui_text_light'))
                .layoutWeight(1)
              Text('>')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_disable'))
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })
            .onClick(() => {
              if (this.provinces.length > 0) {
                this.showProvincePicker = true;
              }
            })

            Row() {
              Text('城市')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .width(70)
              Text(this.selectedCity || (this.selectedProvince ? '请选择' : '请先选择省份'))
                .fontSize(14)
                .fontColor(this.selectedCity ? $r('app.color.ui_text_dark') : $r('app.color.ui_text_light'))
                .layoutWeight(1)
              Text('>')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_disable'))
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })
            .onClick(() => {
              if (this.cities.length > 0) {
                this.showCityPicker = true;
              }
            })

            Row() {
              Text('区县')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .width(70)
              Text(this.selectedArea || (this.selectedCity ? '请选择' : '请先选择城市'))
                .fontSize(14)
                .fontColor(this.selectedArea ? $r('app.color.ui_text_dark') : $r('app.color.ui_text_light'))
                .layoutWeight(1)
              Text('>')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_disable'))
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })
            .onClick(() => {
              if (this.areas.length > 0) {
                this.showAreaPicker = true;
              }
            })

            Column() {
              Text('详细地址')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
                .margin({ bottom: 8 })
              TextInput({ placeholder: '请输入详细地址', text: this.addressDetails })
                .type(InputType.Normal)
                .width('100%')
                .height(80)
                .onChange((value: string) => {
                  this.addressDetails = value;
                })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })

            Row() {
              Text('设为默认地址')
                .fontSize(14)
                .fontColor($r('app.color.ui_text_dark'))
              Text(this.isDefault ? '☑' : '☐')
                .fontSize(18)
                .fontColor(this.isDefault ? $r('app.color.ui_primary_red') : $r('app.color.ui_text_light'))
                .margin({ left: 'auto' })
                .onClick(() => {
                  this.isDefault = !this.isDefault;
                })
            }
            .padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 1 })

            Button('保存')
              .type(ButtonType.Capsule)
              .width('90%')
              .height(44)
              .backgroundColor($r('app.color.ui_primary_red'))
              .fontColor(Color.White)
              .fontSize(16)
              .margin({ top: 24 })
              .onClick(() => {
                this.saveAddress();
              })
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.ui_search_bg'))

      if (this.showProvincePicker) {
        Column() {
          Column() {
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor($r('app.color.ui_text_light'))
                .onClick(() => {
                  this.showProvincePicker = false;
                })
              Text('选择省份')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('确定')
                .fontSize(16)
                .fontColor($r('app.color.ui_primary_red'))
                .onClick(() => {
                  const idx = this.provinceSelectedIndex;
                  if (idx >= 0 && idx < this.provinces.length) {
                    this.selectedProvince = this.provinces[idx].name;
                    this.selectedProvinceCode = this.provinces[idx].code;
                    this.loadCities(this.provinces[idx].code);
                  }
                  this.showProvincePicker = false;
                })
            }
            .width('100%')
            .padding(16)

            TextPicker({ range: this.provinces.map((p: CityBean) => p.name), selected: this.provinceSelectedIndex })
              .onChange((_value: string | string[], index: number | number[]) => {
                if (typeof index === 'number') {
                  this.provinceSelectedIndex = index;
                }
              })
              .height(200)
          }
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 12, topRight: 12 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.ui_overlay_bg'))
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.showProvincePicker = false;
        })
      }

      if (this.showCityPicker) {
        Column() {
          Column() {
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor($r('app.color.ui_text_light'))
                .onClick(() => {
                  this.showCityPicker = false;
                })
              Text('选择城市')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('确定')
                .fontSize(16)
                .fontColor($r('app.color.ui_primary_red'))
                .onClick(() => {
                  const idx = this.citySelectedIndex;
                  if (idx >= 0 && idx < this.cities.length) {
                    this.selectedCity = this.cities[idx].name;
                    this.selectedCityCode = this.cities[idx].code;
                    this.loadAreas(this.cities[idx].code);
                  }
                  this.showCityPicker = false;
                })
            }
            .width('100%')
            .padding(16)

            TextPicker({ range: this.cities.map((c: CityBean) => c.name), selected: this.citySelectedIndex })
              .onChange((_value: string | string[], index: number | number[]) => {
                if (typeof index === 'number') {
                  this.citySelectedIndex = index;
                }
              })
              .height(200)
          }
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 12, topRight: 12 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.ui_overlay_bg'))
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.showCityPicker = false;
        })
      }

      if (this.showAreaPicker) {
        Column() {
          Column() {
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor($r('app.color.ui_text_light'))
                .onClick(() => {
                  this.showAreaPicker = false;
                })
              Text('选择区县')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text('确定')
                .fontSize(16)
                .fontColor($r('app.color.ui_primary_red'))
                .onClick(() => {
                  const idx = this.areaSelectedIndex;
                  if (idx >= 0 && idx < this.areas.length) {
                    this.selectedArea = this.areas[idx].name;
                    this.selectedAreaCode = this.areas[idx].code;
                  }
                  this.showAreaPicker = false;
                })
            }
            .width('100%')
            .padding(16)

            TextPicker({ range: this.areas.map((a: CityBean) => a.name), selected: this.areaSelectedIndex })
              .onChange((_value: string | string[], index: number | number[]) => {
                if (typeof index === 'number') {
                  this.areaSelectedIndex = index;
                }
              })
              .height(200)
          }
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 12, topRight: 12 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.ui_overlay_bg'))
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.showAreaPicker = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
