import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { AddressBean } from '../model/AddressBean';
import { AddAddressBean } from '../model/AddAddressBean';
import { CityBean } from '../model/CityBean';
import { AddressRequestBean } from '../model/AddressRequestBean';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';

interface AddressListResult {
  result: AddressBean[];
}

interface CityListResult {
  result: CityBean[];
}

/**
 * 地址服务
 * 对应 Android 项目中的 AddressController.java
 */
export class AddressService {
  /**
   * 获取地址列表
   */
  static async getAddressList(req: AddressRequestBean): Promise<AddressBean[]> {
    const params: Record<string, string> = {
      'userId': String(req.userId),
      'isDefault': String(req.isDefault)
    };
    const response: string = await HttpUtil.doPost(Constants.RECEIVE_ADDRESS, params);
    const parsed: AddressListResult = JSON.parse(response) as AddressListResult;
    if (!parsed || !parsed.result) {
      return [];
    }
    return parsed.result;
  }

  /**
   * 获取省份列表
   */
  static async getProvince(): Promise<CityBean[]> {
    const response: string = await HttpUtil.doGet(Constants.PROVINCE);
    const parsed: CityListResult = JSON.parse(response) as CityListResult;
    return parsed.result;
  }

  /**
   * 获取城市列表
   */
  static async getCity(code: string): Promise<CityBean[]> {
    const response: string = await HttpUtil.doGet(Constants.CITY + code);
    const parsed: CityListResult = JSON.parse(response) as CityListResult;
    return parsed.result;
  }

  /**
   * 获取区县列表
   */
  static async getArea(code: string): Promise<CityBean[]> {
    const params: Record<string, string> = { 'fcode': code };
    const response: string = await HttpUtil.doPost(Constants.AREA, params);
    const parsed: CityListResult = JSON.parse(response) as CityListResult;
    return parsed.result;
  }

  /**
   * 添加地址
   */
  static async addAddress(bean: AddAddressBean): Promise<AddressBean> {
    const params: Record<string, string> = {
      'userId': String(bean.userId),
      'name': bean.name || '',
      'phone': bean.phone || '',
      'provinceCode': bean.provinceCode || '',
      'cityCode': bean.cityCode || '',
      'distCode': bean.distCode || '',
      'addressDetails': bean.addressDetails || '',
      'isDefault': bean.isDefault ? 'true' : 'false'
    };
    const response: string = await HttpUtil.doPost(Constants.ADD_ADDRESS, params);
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '添加地址失败');
    }
    return JSON.parse(resultToString(root.result)) as AddressBean;
  }

  /**
   * 删除地址
   */
  static async deleteAddress(userId: number, addressId: number): Promise<void> {
    const url: string = Constants.DELETE_ADDRESS + '?id=' + addressId + '&userId=' + userId;
    const response: string = await HttpUtil.doPost(url, {});
    const root: RResult = JSON.parse(response) as RResult;
    if (!root.success) {
      throw new Error(root.errorMsg || '删除地址失败');
    }
  }
}
