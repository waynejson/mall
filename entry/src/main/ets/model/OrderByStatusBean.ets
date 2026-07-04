/**
 * 按状态查询的订单列表项
 * 对应 Android 项目中的 OrderByStatusBean.java
 */
export interface OrderByStatusBean {
  items: string[]; // 商品图片URL列表
  oid: number | null;
  orderNum: string;
  paid: boolean | null;
  status: number | null;
  tn: string;
  totalPrice: number | null;
}
