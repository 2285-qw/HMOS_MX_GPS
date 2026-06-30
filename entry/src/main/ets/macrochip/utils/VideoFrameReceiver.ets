// VideoFrameReceiver.ts
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class VideoFrameReceiver {
  private receiver: image.ImageReceiver | null = null;
  private surfaceId: string = '';
  private onFrameCallback?: (data: Uint8Array, width: number, height: number, format: number) => void;
  private isRunning: boolean = false;

  /**
   * 初始化接收器（强制使用旧版重载，保证兼容性）
   * @param width  视频宽度
   * @param height 视频高度
   * @param format 像素格式，直接传 ImageFormat 枚举值（例如 1000）
   * @param capacity 缓冲队列容量
   */
  public initialize(width: number, height: number, format: number = image.ImageFormat.YCBCR_422_SP, capacity: number = 4): void {
    if (this.receiver) {
      this.release();
    }
    const size: image.Size = { width: 1280, height: 720 };
    // 使用旧版重载：createImageReceiver(width, height, format, capacity)
    this.receiver = image.createImageReceiver(size, format, capacity);
  }

  /**
   * 获取 Surface ID（异步）
   */
  public async getSurfaceId(): Promise<string> {
    if (!this.receiver) {
      throw new Error('Receiver 未初始化，请先调用 initialize');
    }
    if (!this.surfaceId) {
      this.surfaceId = await this.receiver.getReceivingSurfaceId();
    }
    return this.surfaceId;
  }

  /**
   * 开始接收帧，注册帧到达回调
   * @param callback 每帧数据的回调，包含 NV21 格式的 Uint8Array 及宽高、格式
   */
  public startReceiving(callback: (data: Uint8Array, width: number, height: number, format: number) => void): void {
    if (!this.receiver) {
      console.error('请先调用 initialize');
      return;
    }
    this.onFrameCallback = callback;
    this.isRunning = true;

    this.receiver.on('imageArrival', () => {
      if (!this.isRunning || !this.receiver) {
        return;
      }
      this.receiver.readNextImage((err, img) => {
        if (err || !img) {
          console.error('读取帧失败:', err);
          return;
        }
        this.processImage(img);
        img.release();
      });
    });
  }

  private async processImage(img: image.Image): Promise<void> {
    try {
      const width = img.size.width;
      const height = img.size.height;
      const format = img.format; // ImageFormat 枚举值

      // 获取 YUV 分量
      const yComp = await img.getComponent(image.ComponentType.YUV_Y);
      const uComp = await img.getComponent(image.ComponentType.YUV_U);
      const vComp = await img.getComponent(image.ComponentType.YUV_V);

      const yData = new Uint8Array(yComp.byteBuffer);
      const uData = new Uint8Array(uComp.byteBuffer);
      const vData = new Uint8Array(vComp.byteBuffer);

      // 组装 NV21（Y + VU 交错）
      const nv21Size = width * height + (width * height) / 2;
      const nv21Buffer = new Uint8Array(nv21Size);
      nv21Buffer.set(yData, 0);
      let uvIndex = width * height;
      for (let i = 0; i < uData.length; i++) {
        nv21Buffer[uvIndex++] = vData[i];
        nv21Buffer[uvIndex++] = uData[i];
      }

      if (this.onFrameCallback) {
        this.onFrameCallback(nv21Buffer, width, height, format);
      }
    } catch (error) {
      console.error('处理帧出错:', error);
    }
  }

  public stopReceiving(): void {
    this.isRunning = false;
    if (this.receiver) {
      this.receiver.off('imageArrival');
    }
    this.release();
  }

  public release(): void {
    if (this.receiver) {
      this.receiver.release();
      this.receiver = null;
    }
    this.surfaceId = '';
    this.onFrameCallback = undefined;
    this.isRunning = false;
  }
}