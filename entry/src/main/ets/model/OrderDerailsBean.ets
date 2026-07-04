/**
 * 订单详情地址
 */
export interface OrderDerailsAddress {
  id: number | null;
  isDefault: boolean | null;
  receiverName: string;
  receiverPhone: string;
  receiverAddress: string;
}

/**
 * 订单行商品
 */
export interface OrderDerailsItem {
  amount: number | null;
  buyCount: number;
  piconUrl: string;
  pid: number;
  pname: string;
  version: string;
}

/**
 * 订单详情
 * 对应 Android 项目中的 OrderDerailsBean.java
 */
export interface OrderDerailsBean {
  address: OrderDerailsAddress | null;
  buyTime: string;
  freight: number | null;
  items: OrderDerailsItem[] | null;
  oid: number | null;
  id: number | null;
  orderNum: string;
  paid: boolean | null;
  payWay: number | null;
  status: number | null; // -1取消 0待付款 1待发货 2待收货 3已完成
  tn: string;
  totalPrice: number | null;
}
