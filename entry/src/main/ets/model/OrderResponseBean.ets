/**
 * 下单返回结果
 * 对应 Android 项目中的 OrderResponseBean.java
 */
export interface OrderResponseBean {
  errorType: number; // 0成功 1没库存 2系统失败
  buyTime: string;
  freight: number;
  totalPrice: number;
  id: number | null;
  oid: string;
  orderNum: string;
  pname: string;
  payWay: number; // 0在线支付 1货到付款
  tn: string;
  allPrice: number;
}
