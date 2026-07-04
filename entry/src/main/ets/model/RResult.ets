/**
 * 通用返回结果
 * 对应 Android 项目中的 RResult.java
 */
export interface RResult {
  success: boolean;
  errorMsg: string;
  result: string | object | number | null;
}

/**
 * 将 RResult.result 安全转为 JSON 字符串，供 JSON.parse 使用
 */
export function resultToString(result: string | object | number | null): string {
  if (result === null || result === undefined) {
    return '';
  }
  if (typeof result === 'string') {
    return result;
  }
  return JSON.stringify(result);
}
