import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';
import { ShopCarInfoBean } from '../model/ShopCarInfoBean';
import { BuyInfoBean } from '../model/BuyInfoBean';

/**
 * 购物车服务
 * 对应 Android 项目中的 ShopCArController.java
 */
export class ShopCarService {
  /**
   * 获取购物车列表
   */
  static async getShopCarList(userId: number): Promise<ShopCarInfoBean[]> {
    const params: Record<string, string> = { 'userId': String(userId) };
    const url = Constants.SHOP_CAR + userId;
    const response = await HttpUtil.doPost(url, params);
    if (!response || response.trim().length === 0) {
      return [];
    }
    const rResult = JSON.parse(response) as RResult;
    if (!rResult || !rResult.result) {
      return [];
    }
    const result = resultToString(rResult.result);
    if (result.trim().startsWith('[')) {
      return JSON.parse(result) as ShopCarInfoBean[];
    } else {
      const one = JSON.parse(result) as ShopCarInfoBean;
      return one ? [one] : [];
    }
  }

  /**
   * 加入购物车
   */
  static async addToShopCar(info: BuyInfoBean): Promise<RResult> {
    const params: Record<string, string> = {
      'userId': String(info.userId),
      'productId': String(info.productId),
      'buyCount': String(info.buyCount)
    };
    if (info.productType && info.productType.trim().length > 0) {
      params['type'] = info.productType.trim();
    }
    const response = await HttpUtil.doPost(Constants.ADD_TO_SHOP_CAR, params);
    return JSON.parse(response) as RResult;
  }

  /**
   * 获取购物车数量
   */
  static async getShopCarNum(userId: number): Promise<string> {
    const params: Record<string, string> = { 'userId': String(userId) };
    const response = await HttpUtil.doPost(Constants.SHOP_CAR_NUM, params);
    const rResult = JSON.parse(response) as RResult;
    return resultToString(rResult.result);
  }

  /**
   * 删除购物车商品
   */
  static async deleteShopCar(userId: number, id: number): Promise<RResult> {
    const params: Record<string, string> = {
      'userId': String(userId),
      'id': String(id)
    };
    const response = await HttpUtil.doPost(Constants.DELETE_SHOP_CAR, params);
    return JSON.parse(response) as RResult;
  }
}
