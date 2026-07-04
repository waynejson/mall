import { AddOrderParmBean } from './AddOrderParmBean';

/**
 * 下单参数
 * 对应 Android 项目中的 AddOrderBean.java
 */
export interface AddOrderBean {
  products: AddOrderParmBean[];
  addrId: string; // 地址ID
  payWay: number; // 0在线支付 1货到付款
  userId: string;
}
