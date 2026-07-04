/**
 * 收货地址
 * 对应 Android 项目中的 AddressBean.java
 */
export interface AddressBean {
  id: number;
  isDefault: boolean;
  receiverName: string; // 收货人
  receiverAddress: string; // 具体地址
  receiverPhone: string; // 手机号
}
