import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';
import { BrandBean } from '../model/BrandBean';
import { FavBean } from '../model/FavBean';
import { SecKillBean } from '../model/SecKillBean';

interface SecKillResult {
  rows: SecKillBean[];
}

interface FavResult {
  rows: FavBean[];
}

/**
 * 首页服务
 * 对应 Android 项目中的 HomeController.java
 */
export class HomeService {
  /**
   * 加载广告1（轮播图）
   */
  static async loadAd1(): Promise<BrandBean[]> {
    const response: string = await HttpUtil.doGet(Constants.BANNER_AD1);
    const rResult: RResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as BrandBean[];
  }

  /**
   * 加载广告2
   */
  static async loadAd2(): Promise<BrandBean[]> {
    const response: string = await HttpUtil.doGet(Constants.BANNER_AD2);
    const rResult: RResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as BrandBean[];
  }

  /**
   * 加载秒杀商品
   */
  static async loadSecKill(): Promise<SecKillBean[]> {
    const response: string = await HttpUtil.doGet(Constants.SECKILL);
    const rResult: RResult = JSON.parse(response) as RResult;
    const parsed: SecKillResult = JSON.parse(resultToString(rResult.result)) as SecKillResult;
    return parsed.rows;
  }

  /**
   * 加载猜你喜欢
   */
  static async loadRecommend(): Promise<FavBean[]> {
    const response: string = await HttpUtil.doGet(Constants.RECOMMEND_PRODUCT);
    const rResult: RResult = JSON.parse(response) as RResult;
    const parsed: FavResult = JSON.parse(resultToString(rResult.result)) as FavResult;
    return parsed.rows;
  }
}
