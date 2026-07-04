/**
 * 添加地址参数
 * 对应 Android 项目中的 AddAddressBean.java
 */
export interface AddAddressBean {
  userId: number | null;
  name: string;
  phone: string;
  provinceCode: string;
  cityCode: string;
  distCode: string;
  addressDetails: string;
  isDefault: boolean | null;
}
