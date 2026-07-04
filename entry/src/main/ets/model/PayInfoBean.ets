/**
 * 支付信息
 * 对应 Android 项目中的 PayInfoBean.java
 */
export interface PayInfoBean {
  oinfo: string;
  tn: string;
  pname: string;
  payTime: string;
  totalPrice: number | null;
}
