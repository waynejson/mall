import { http } from '@kit.NetworkKit';

/**
 * 网络请求工具类
 * 对应 Android 项目中的 NetworkUtil.java
 * 使用鸿蒙 @ohos.net.http 模块
 */
export class HttpUtil {
  /**
   * GET 请求
   */
  static async doGet(url: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: 15000,
        connectTimeout: 15000
      });
      if (response.responseCode === 200) {
        return response.result.toString();
      }
      throw new Error(`HTTP ${response.responseCode}: ${response.result}`);
    } catch (err) {
      console.error(`GET 请求失败: ${url}, 错误: ${JSON.stringify(err)}`);
      throw new Error(`GET 请求失败: ${url}, ${err}`);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * POST 表单请求
   */
  static async doPost(url: string, params: Record<string, string> = {}): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      // 构建表单参数
      const formBody = Object.keys(params)
        .filter(key => params[key] !== undefined && params[key] !== null)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
        .join('&');

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        extraData: formBody,
        readTimeout: 15000,
        connectTimeout: 15000
      });
      if (response.responseCode === 200) {
        return response.result.toString();
      }
      throw new Error(`HTTP ${response.responseCode}: ${response.result}`);
    } catch (err) {
      console.error(`POST 请求失败: ${url}, 错误: ${JSON.stringify(err)}`);
      throw new Error(`POST 请求失败: ${url}, ${err}`);
    } finally {
      httpRequest.destroy();
    }
  }
}
