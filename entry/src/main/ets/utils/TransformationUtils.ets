// TransformationUtils.ets
import { util } from '@kit.ArkTS';

/**
 * 数据转换工具类
 * 提供字节数组与基本类型之间的转换、单位换算、字符串编码等
 */
export class TransformationUtils {
  /** 英尺/米转换系数（1米 = 3.281英尺） */
  public static FT_UNIT: number = 3.281;

  /**
   * 将大端序的2字节数组转换为 short（有符号）
   * @param b 长度为2的字节数组（大端序：高字节在前）
   * @returns short值（-32768 ~ 32767）
   */
  public static byte2Short(b: Uint8Array): number {
    if (b.length < 2) return 0;
    // 将两个字节组合为有符号short：高字节 << 8 | 低字节
    const value = (b[0] << 8) | (b[1] & 0xFF);
    // 若最高位为1，则转成负数（符号扩展）
    return value > 0x7FFF ? value - 0x10000 : value;
  }

  /**
   * 将字符串转换为 ASCII 字节数组（非ASCII字符替换为 '?'）
   * @param str 输入字符串
   * @returns ASCII 字节数组（Uint8Array）
   */
  public static stringToAsciiByteArray(str: string): Uint8Array {
    if (!str || str.length === 0) {
      return new Uint8Array(0);
    }
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      const code = str.charCodeAt(i);
      // ASCII 范围 0-127，否则替换为 63（'?'）
      bytes[i] = code <= 127 ? code : 63;
    }
    return bytes;
  }

  /**
   * 将字符串按 UTF-8 编码转换为字节数组
   * @param b 输入字符串
   * @returns UTF-8 编码的字节数组
   */
  public static string2Byte(b: string): Uint8Array {
    const encoder = new util.TextEncoder();
    return encoder.encode(b);
  }

  /**
   * 将小端序的2字节数组转换为 short
   * @param b 长度为2的字节数组（小端序：低字节在前）
   * @returns short值
   */
  public static byte2Short2(b: Uint8Array): number {
    if (b.length < 2) return 0;
    const value = (b[1] << 8) | (b[0] & 0xFF);
    return value > 0x7FFF ? value - 0x10000 : value;
  }

  /**
   * 将小端序的2字节数组转换为浮点数（除以10取绝对值）
   * @param data 长度为2的字节数组（小端序）
   * @returns float值（绝对值）
   */
  public static byte2ToFloat(data: Uint8Array): number {
    const shortValue = TransformationUtils.byte2Short2(data);
    const floatValue = shortValue / 10;
    return Math.abs(floatValue);
  }

  /**
   * 将 short 转换为小端序的2字节数组
   * @param number short值
   * @returns 小端序字节数组（低字节在前）
   */
  public static shortToByte(number: number): Uint8Array {
    const bytes = new Uint8Array(2);
    bytes[0] = number & 0xFF;
    bytes[1] = (number >> 8) & 0xFF;
    return bytes;
  }

  /**
   * 保留一位小数（四舍五入），返回字符串
   * @param number 浮点数
   * @returns 格式化后的字符串（例如 3.1）
   */
  public static showFloat(number: number): string {
    const rounded = Math.round(number * 10) / 10;
    return rounded.toString();
  }

  /**
   * 按指定格式保留一位小数
   * @param format 格式化字符串（例如 "%.1f"）
   * @param number 浮点数
   * @returns 格式化后的字符串
   */
  public static showFloatWithFormat(format: string, number: number): string {
    const value = TransformationUtils.showFloat(number);
    // 简单替换 %f 或 %.1f 等，实际上可用 util.format，但为保持简单直接返回
    // 因为 ArkTS 没有直接对应 Java 的 String.format，使用 replace 简单处理
    return format.replace('%f', value).replace('%.1f', value);
  }

  /**
   * 将 m/s 转换为 MPH（英里/小时）
   * @param f 速度值（m/s）
   * @returns MPH 值
   */
  public static toMPH(f: number): number {
    return f * TransformationUtils.FT_UNIT;
  }

  /**
   * 将 m/s 转换为 km/h（千米/小时）
   * @param f 速度值（m/s）
   * @returns km/h 值
   */
  public static toKMH(f: number): number {
    return f / 1000 * 3600;
  }

  /**
   * 将 int 转换为小端序的4字节数组
   * @param val int值
   * @returns 小端序字节数组（低字节在前）
   */
  public static intToBytes(val: number): Uint8Array {
    const bytes = new Uint8Array(4);
    bytes[0] = val & 0xFF;
    bytes[1] = (val >> 8) & 0xFF;
    bytes[2] = (val >> 16) & 0xFF;
    bytes[3] = (val >> 24) & 0xFF;
    return bytes;
  }

  /**
   * 将 short 转换为小端序的2字节数组
   * @param val short值
   * @returns 小端序字节数组（低字节在前）
   */
  public static shortToBytes(val: number): Uint8Array {
    const bytes = new Uint8Array(2);
    bytes[0] = val & 0xFF;
    bytes[1] = (val >> 8) & 0xFF;
    return bytes;
  }

  /**
   * 将字节数组按 ASCII 解码为字符串，并去除首尾空白
   * @param byteArray ASCII 字节数组
   * @returns 解码后的字符串
   */
  public static byteArrayToAsciiStringFast(byteArray: Uint8Array): string {
    if (!byteArray || byteArray.length === 0) {
      return '';
    }
    // 手动构建 ASCII 字符串
    let result = '';
    for (let i = 0; i < byteArray.length; i++) {
      const code = byteArray[i];
      // 只处理可打印 ASCII 字符（32-126），其余跳过或替换
      if (code >= 32 && code <= 126) {
        result += String.fromCharCode(code);
      } else if (code === 0) {
        // 空字符通常作为终止，此处忽略
        continue;
      } else {
        // 非打印字符替换为空格？保持原样，但通常 trim 会处理
        result += String.fromCharCode(code);
      }
    }
    return result.trim();
  }

  /**
   * 将小端序的字节数组转换为 int
   * 注意：输入字节数组应为小端序（低字节在前）
   * @param b 字节数组（长度至少为4，若不足则按0补齐）
   * @returns int值
   */
  public static bytesToInt(b: Uint8Array): number {
    let result = 0;
    // 从最后一个字节开始，依次左移8位
    for (let i = b.length - 1; i >= 0; i--) {
      result = (result << 8) | (b[i] & 0xFF);
    }
    return result;
  }

  /**
   * 判断字节数组是否全为0
   * @param data 字节数组
   * @returns 如果所有字节均为0则返回 true，否则 false
   */
  public static isEmpty(data: Uint8Array): boolean {
    if (!data) return true;
    for (const byte of data) {
      if (byte !== 0) {
        return false;
      }
    }
    return true;
  }
}