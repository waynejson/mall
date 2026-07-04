import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';
import { AddOrderBean } from '../model/AddOrderBean';
import { OrderResponseBean } from '../model/OrderResponseBean';
import { OrderDerailsBean } from '../model/OrderDerailsBean';
import { OrderByStatusBean } from '../model/OrderByStatusBean';
import { PayInfoBean } from '../model/PayInfoBean';

interface OrderDetail {
  products: object[];
  addrId: number | string;
  payWay: number;
  userId: number | string;
}

/**
 * 订单服务
 * 对应 Android 项目中的 OrderController.java
 */
export class OrderService {
  /**
   * 创建订单
   */
  static async createOrder(info: AddOrderBean): Promise<OrderResponseBean> {
    const products: object[] = [];
    if (info.products) {
      for (const p of info.products) {
        const productObj: Record<string, string | number> = {
          'buyCount': p.buyCount,
          'type': p.type,
          'pid': p.pid
        };
        products.push(productObj);
      }
    }
    // 与 Android OrderController 一致：addrId/userId 能转整数就转
    const detail: string = JSON.stringify({
      products: products,
      addrId: OrderService.parseIntOrRaw(info.addrId),
      payWay: info.payWay,
      userId: OrderService.parseIntOrRaw(info.userId)
    } as OrderDetail);
    const params: Record<string, string> = { 'detail': detail };
    const response: string = await HttpUtil.doPost(Constants.ADD_ORDER, params);
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '下单失败');
    }
    return JSON.parse(resultToString(root.result)) as OrderResponseBean;
  }

  /**
   * 获取订单详情
   */
  static async getOrderDetails(userId: number, oid: string): Promise<OrderDerailsBean> {
    const url: string = Constants.ORDER_DETAIL + '?userId=' + userId + '&id=' + oid;
    const response: string = await HttpUtil.doPost(url, {});
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '获取订单详情失败');
    }
    return JSON.parse(resultToString(root.result)) as OrderDerailsBean;
  }

  /**
   * 能转整数就转，否则原样返回（与 Android OrderController 一致）
   */
  private static parseIntOrRaw(value: string): number | string {
    if (!value) return '';
    const parsed: number = parseInt(value);
    return isNaN(parsed) ? value : parsed;
  }

  /**
   * 按状态获取订单列表
   */
  static async getOrdersByStatus(userId: number, status: number): Promise<OrderByStatusBean[]> {
    const url: string = Constants.ORDER_LIST + '?status=' + status + '&userId=' + userId;
    const response: string = await HttpUtil.doPost(url, {});
    const parsed: RResult = JSON.parse(response) as RResult;
    if (!parsed.success) {
      throw new Error(parsed.errorMsg || '获取订单列表失败');
    }
    return JSON.parse(resultToString(parsed.result)) as OrderByStatusBean[];
  }

  /**
   * 获取全部订单（并行请求所有状态）
   */
  static async getAllOrders(userId: number): Promise<OrderByStatusBean[]> {
    const statuses: number[] = [-1, 0, 1, 2, 3];
    // 并行请求所有状态，提升性能
    const results = await Promise.allSettled(
      statuses.map((st: number) => OrderService.getOrdersByStatus(userId, st))
    );

    const byOid: Map<number, OrderByStatusBean> = new Map<number, OrderByStatusBean>();
    for (const result of results) {
      if (result.status === 'fulfilled' && result.value) {
        for (const o of result.value) {
          if (o.oid !== null) {
            byOid.set(o.oid, o);
          }
        }
      }
    }
    return Array.from(byOid.values());
  }

  /**
   * 取消订单
   */
  static async cancelOrder(userId: number, oid: number): Promise<void> {
    const url: string = Constants.CANCEL_ORDER + '?userId=' + userId + '&oid=' + oid;
    const response: string = await HttpUtil.doPost(url, {});
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '取消订单失败');
    }
  }

  /**
   * 确认收货
   */
  static async confirmOrder(userId: number, oid: number): Promise<void> {
    const url: string = Constants.CONFIRM_ORDER + '?userId=' + userId + '&oid=' + oid;
    const response: string = await HttpUtil.doPost(url, {});
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '确认收货失败');
    }
  }

  /**
   * 获取支付信息
   */
  static async getPayInfo(tn: string, userId: number): Promise<PayInfoBean> {
    const url: string = Constants.PAY_INFO + '?tn=' + tn + '&userId=' + userId;
    const response: string = await HttpUtil.doPost(url, {});
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '获取支付信息失败');
    }
    return JSON.parse(resultToString(root.result)) as PayInfoBean;
  }

  /**
   * 支付
   */
  static async pay(account: string, apwd: string, ppwd: string, tn: string, userId: number): Promise<string> {
    const params: Record<string, string> = {
      'account': account,
      'apwd': apwd,
      'ppwd': ppwd,
      'tn': tn,
      'userId': String(userId)
    };
    const response: string = await HttpUtil.doPost(Constants.PAY, params);
    const rResult: RResult = JSON.parse(response) as RResult;
    if (!rResult.success) {
      throw new Error(rResult.errorMsg || '支付失败');
    }
    return resultToString(rResult.result);
  }
}
