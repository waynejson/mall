/**
 * 支付请求参数
 * 对应 Android 项目中的 AlipayLoginRequestBean.java
 */
export interface AlipayLoginRequestBean {
  account: string; // 支付宝账号
  apwd: string; // 登录密码
  ppwd: string; // 支付密码
  tn: string; // 订单令牌
  userId: number;
}
