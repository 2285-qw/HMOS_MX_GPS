import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';

/**
 * I420 图像保存器
 * 提供将 I420 YUV 数据保存为 JPEG/PNG 图片的功能
 */
export class I420ImageSaver {
  /**
   * 将 I420 数据保存为图片文件
   * @param i420Data I420 原始数据 (Uint8Array)
   * @param width 图像宽度（必须为偶数）
   * @param height 图像高度（必须为偶数）
   * @param filePath 保存路径（如: /data/storage/el2/base/haps/entry/files/output.jpg）
   * @param quality 图片质量 0-100，仅对 JPEG 格式有效
   * @returns Promise<void>
   * @throws 参数错误或编码/写入失败时抛出 Error
   */
  public static async saveToFile(
    i420Data: Uint8Array,
    width: number,
    height: number,
    filePath: string,
    quality: number = 90
  ): Promise<void> {
    // --- 参数校验 ---
    if (!i420Data || i420Data.length === 0) {
      throw new Error('i420Data is empty');
    }
    if (width <= 0 || height <= 0) {
      throw new Error('Invalid width or height');
    }
    if (width % 2 !== 0 || height % 2 !== 0) {
      console.warn('I420 width or height is not even, may cause incorrect UV alignment');
    }

    // --- 转换流程 ---
    const rgbaData = I420ImageSaver.i420ToRgba(i420Data, width, height);
    const pixelMap = await I420ImageSaver.createPixelMapFromRgba(rgbaData, width, height);

    try {
      await I420ImageSaver.encodeAndSave(pixelMap, filePath, quality);
    } finally {
      // 确保 PixelMap 资源被释放
      pixelMap.release();
    }
  }

  /**
   * I420 转 RGBA8888
   * @param i420Data I420 原始数据
   * @param width 宽度
   * @param height 高度
   * @returns RGBA8888 数据 (Uint8Array)
   */
  private static i420ToRgba(i420Data: Uint8Array, width: number, height: number): Uint8Array {
    const ySize = width * height;
    const uvSize = (width / 2) * (height / 2);

    // 提取三个平面
    const yPlane = i420Data.subarray(0, ySize);
    const uPlane = i420Data.subarray(ySize, ySize + uvSize);
    const vPlane = i420Data.subarray(ySize + uvSize, ySize + 2 * uvSize);

    const rgbaData = new Uint8Array(width * height * 4);

    for (let i = 0; i < height; i++) {
      for (let j = 0; j < width; j++) {
        const yIndex = i * width + j;
        const uvIndex = Math.floor(i / 2) * Math.floor(width / 2) + Math.floor(j / 2);

        const y = yPlane[yIndex] & 0xFF;
        const u = uPlane[uvIndex] & 0xFF;
        const v = vPlane[uvIndex] & 0xFF;

        // YUV 转 RGB (BT.601 标准)
        let r = y + 1.402 * (v - 128);
        let g = y - 0.344 * (u - 128) - 0.714 * (v - 128);
        let b = y + 1.772 * (u - 128);

        const idx = (i * width + j) * 4;
        rgbaData[idx] = Math.max(0, Math.min(255, Math.round(r)));     // R
        rgbaData[idx + 1] = Math.max(0, Math.min(255, Math.round(g))); // G
        rgbaData[idx + 2] = Math.max(0, Math.min(255, Math.round(b))); // B
        rgbaData[idx + 3] = 255;                                       // A (不透明)
      }
    }

    return rgbaData;
  }

  /**
   * 从 RGBA 数据创建 PixelMap
   */
  private static async createPixelMapFromRgba(
    rgbaData: Uint8Array,
    width: number,
    height: number
  ): Promise<image.PixelMap> {
    const opts: image.InitializationOptions = {
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      size: { width, height },
      alphaType: image.AlphaType.OPAQUE,          // 修正：使用 OPAQUE
      editable: true,
      scaleMode: image.ScaleMode.CENTER_CROP,
      srcPixelFormat: image.PixelMapFormat.RGBA_8888,
    };

    return await image.createPixelMap(rgbaData.buffer, opts);
  }

  /**
   * 编码 PixelMap 并保存为图片文件
   */
  private static async encodeAndSave(
    pixelMap: image.PixelMap,
    filePath: string,
    quality: number
  ): Promise<void> {
    const imagePackerApi = image.createImagePacker();

    // 根据文件扩展名选择格式
    const format = filePath.endsWith('.png') ? 'image/png' : 'image/jpeg';
    const packOpts: image.PackingOption = {
      format: format,
      quality: quality,
    };

    try {
      // 编码为 ArrayBuffer
      const data: ArrayBuffer = await imagePackerApi.packToData(pixelMap, packOpts);

      // 使用 fs 模块写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, data);
      fs.closeSync(file.fd);

      console.info(`Image saved successfully: ${filePath}`);
       I420ImageSaver.savePixelMapToPath(pixelMap,filePath)
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to pack or save image: ${err.code}, ${err.message}`);
      throw new Error(`Image save failed: ${err.message}`);
    } finally {
      imagePackerApi.release();
    }
  }

  // 保存 PixelMap 到指定路径
 static   async  savePixelMapToPath(pixelMap: image.PixelMap, filePath: string): Promise<boolean> {
    try {
      // 1. 创建 ImagePacker 实例
      const imagePackerApi = image.createImagePacker();

      // 2. 配置打包选项（可选）
      const packOptions: image.PackingOption = {
        format: 'image/jpeg', // 或 'image/png'
        quality: 100 // 质量 0-100
      };

      // 3. 将 PixelMap 打包为 ArrayBuffer
      const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, packOptions);

      // 4. 写入文件
      const file = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, data);
      await fs.close(file.fd);

      // 释放资源
      imagePackerApi.release();
      console.error('保存成功 ');
      return true;
    } catch (error) {
      console.error('保存失败: ' + JSON.stringify(error));
      return false;
    }
  }
}