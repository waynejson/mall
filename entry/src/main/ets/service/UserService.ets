import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';

/**
 * 用户服务
 * 对应 Android 项目中的 UserController.java
 */
export class UserService {
  /**
   * 登录
   */
  static async login(name: string, pwd: string): Promise<RResult> {
    const params: Record<string, string> = {
      'username': name,
      'pwd': pwd
    };
    const response = await HttpUtil.doPost(Constants.LOGIN, params);
    console.info('登录响应内容: ' + response);
    try {
      return JSON.parse(response) as RResult;
    } catch (e) {
      console.error('JSON解析失败, 原始响应: ' + response + ', 错误: ' + JSON.stringify(e));
      return { success: false, errorMsg: '服务器返回数据格式错误', result: '' } as RResult;
    }
  }

  /**
   * 注册
   */
  static async register(name: string, pwd: string): Promise<RResult> {
    const params: Record<string, string> = {
      'username': name,
      'pwd': pwd
    };
    const response = await HttpUtil.doPost(Constants.REGISTER, params);
    console.info('注册响应内容: ' + response);
    try {
      return JSON.parse(response) as RResult;
    } catch (e) {
      console.error('JSON解析失败, 原始响应: ' + response + ', 错误: ' + JSON.stringify(e));
      return { success: false, errorMsg: '服务器返回数据格式错误', result: '' } as RResult;
    }
  }

  /**
   * 重置密码
   */
  static async resetPassword(name: string): Promise<RResult> {
    const params: Record<string, string> = {
      'username': name
    };
    const response = await HttpUtil.doPost(Constants.RESET_PASSWORD, params);
    console.info('重置密码响应内容: ' + response);
    try {
      return JSON.parse(response) as RResult;
    } catch (e) {
      console.error('JSON解析失败, 原始响应: ' + response + ', 错误: ' + JSON.stringify(e));
      return { success: false, errorMsg: '服务器返回数据格式错误', result: '' } as RResult;
    }
  }

  /**
   * 从登录结果解析用户ID
   */
  static resolveUserIdAfterLogin(ret: RResult): number {
    if (!ret) {
      return 1;
    }
    const r = ret.result;
    if (r === null || r === undefined) {
      return 1;
    }
    // result 是数字
    if (typeof r === 'number') {
      return r;
    }
    // result 是对象，直接取 id/userId/uid 字段
    if (typeof r === 'object') {
      const obj = r as Record<string, number>;
      if (obj.id !== undefined) return obj.id;
      if (obj.userId !== undefined) return obj.userId;
      if (obj.uid !== undefined) return obj.uid;
      return 1;
    }
    // result 是字符串
    const trimmed = (r as string).trim();
    if (trimmed.length === 0) {
      return 1;
    }
    const parsed = parseInt(trimmed);
    if (!isNaN(parsed)) {
      return parsed;
    }
    try {
      const o: Record<string, number> = JSON.parse(trimmed) as Record<string, number>;
      if (o) {
        if (o.userId !== undefined) return o.userId;
        if (o.id !== undefined) return o.id;
        if (o.uid !== undefined) return o.uid;
      }
    } catch (e) {
      // ignore
    }
    return 1;
  }
}
