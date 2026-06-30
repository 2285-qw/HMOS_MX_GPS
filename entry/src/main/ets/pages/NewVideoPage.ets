// VideoPage.ets
import NapiBuffer, { VideoFrame } from 'libentry.so';
import { ObjectUtils } from '../utils/ObjectUtils';
import { ConfigureInfo } from '../model/ConfigureInfo'
import { window, promptAction } from '@kit.ArkUI';
import EntryAbility from '../entryability/EntryAbility';
import { PlayInfo, StreamType } from '../model/PlayInfo';
import { ConnectionStatusListener } from '../listeners/ConnectionStatusListener';

//import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { media } from '@kit.MediaKit';
import { fileIo } from "@kit.CoreFileKit";
import { emitter } from '@kit.BasicServicesKit';
import { Protocol } from '../macrochip/Drone/core/protocol/Protocol';
import { ProtocolManager } from '../macrochip/Drone/core/protocol/ProtocolManager';
import { ModeType, PageSendData } from '../macrochip/Drone/core/protocol/PageSendData';
import { MessageWhat } from '../macrochip/constant/MessageWhat';
import { ObjectUtil } from '@pura/harmony-utils';


@Entry
@Component
export struct NewVideoPage {
  @State currentFrame: image.PixelMap | undefined = undefined;
  pixelMap?: image.PixelMap; // 声明PixelMap变量
  @State p: boolean = false;
  private cameraManager?: camera.CameraManager;
  @State ComponentSize: number = 100;
  private avRecorder?: media.AVRecorder;

  build() {
    Column() {
      Image(this.currentFrame)
        .width(1280)          // 明确指定宽高
        .height(736)
        .backgroundColor(Color.Red) // 如果屏幕出现红色方块，说明 Image 渲染了，但内容没画出来
        .objectFit(ImageFit.Contain)
    }
    .onClick(() => {
      console.debug("点击view")
      if (this.currentFrame) {
        console.debug("点击view 保存成功")
        this.saveImage((this.currentFrame))
      }

    })
  }

  aboutToAppear(): void {
    //监听连接状态开始视频流心跳
    EntryAbility.getInstance().setConnectionStatusListener(this.connectionStatusListener);
    // 持续订阅
    emitter.on({ eventId: ModeType.Page },
      (eventData: emitter.GenericEventData<PageSendData>) => {
        // console.log("收到蓝光功能字信息:", JSON.stringify(eventData));

        if (eventData.data?.modeType == ModeType.FlightControl) {
          //飞控数据
        } else if (eventData.data?.modeType == ModeType.Page) {
          //页面数据
          this.onMessage(eventData.data)
        }


      });
  }

  onPageShow(): void {

    this.setDecoder()
  }

  onMessage(pageSendData: PageSendData) {
    switch (pageSendData.type) {
      case MessageWhat.MESSAGE_PHOTOS:
        console.log("图片名称=========")
        // this.captureImage();
        break
      case MessageWhat.MESSAGE_ZOOM:
        if (pageSendData.numberData) {
          this.ComponentSize = pageSendData.numberData * 100
        }
        break
    }
  }

  aboutToDisappear(): void {
    // 5. 使用完毕后释放资源
    NapiBuffer.release()
    //取消订阅
    emitter.off(ProtocolManager.getInstance().getProtocol())
  }

  onPageHide(): void {
    //停止心跳
    this.setHeart(false);
  }

  // 保存 PixelMap 到指定路径
  async savePixelMapToPath(pixelMap: image.PixelMap, filePath: string): Promise<boolean> {
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

  private setHeart(isHeartbeat: boolean) {
    EntryAbility.getInstance().setVideoHeartbeat(isHeartbeat);
  }

  private connectionStatusListener: ConnectionStatusListener = {
    onDeviceConnection: () => {
      this.setHeart(true);

    },
    onDeviceDisconnection: () => {
      this.setHeart(false);
    }
  };

  /*  // 步骤2：执行截图
    private async captureImage(): Promise<void> {
      try {
        this.pixelMap = await image.createPixelMapFromSurface(this.surfaceId);
        this.p = true;

        this.saveImage(this.pixelMap)
        // 保存或使用pixelMap
      } catch (error) {
        console.error(`Capture failed: ${error}`);
      }
    }*/

  private async saveImage(pixelMap: image.PixelMap) {
    //当前时间戳
    const timestamp: number = Date.now(); // 或 new Date().getTime()
    const now = new Date();
    const timestampName = `${now.getFullYear()}${(now.getMonth() + 1).toString()
      .padStart(2, '0')}${now.getDate()}_${now.getHours()}${(now.getMinutes()).toString()
      .padStart(2, '0')}${now.getSeconds()}`;
    const name = 'img_' + timestampName;
    console.info('图片名称= ' + name);
    // 保存到沙箱目录
    const targetPath = `${getContext().filesDir}/Image/${name}.jpg`;

    let helper = photoAccessHelper.getPhotoAccessHelper(getContext(this));
    let options: photoAccessHelper.CreateOptions = {
      title: name, // 文件名（不带扩展名）
    };
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpeg', options);


    try {
      //保存图片到系统相册
      this.savePixelMapToPath(pixelMap, uri)
      //保存图片到沙箱路径
      this.savePixelMapToPath(pixelMap, targetPath)
      // console.info('图片已保存至: ' + targetPath);
    } catch (err) {
      // console.error('保存失败: ' + JSON.stringify(err));
    }
  }

  setDecoder() {
    const isH264 = [StreamType.H264, StreamType.H264_VGA, StreamType.YUV].includes(PlayInfo.streamType);
    let state = isH264 ? 'video/avc' : 'video/hevc';
    console.log(`初始化解码类型${isH264 ? 'h264' : 'h265'}`);
    //state = 'video/hevc';
    // state = 'video/avc';
    // 1. 初始化解码器
    const success = NapiBuffer.initialize(state, 1280, 720);
    if (!success) {
      console.error('解码器初始化失败');
      return;
    }

    //开始心跳
    this.setHeart(true);

    NapiBuffer.start();
    // const i = NapiBuffer.setSurface(BigInt(surfaceId));


    // console.error(`绑定ui: ${i}`);
    setInterval(() => {
      let frame = NapiBuffer.getDecodedFrame();
      if (frame) {
        // 处理帧数据
        let opts: image.InitializationOptions = {
          // size 是必填项，必须明确宽高
          size: {
            width: 1280,
            height: 736,
          },
          // pixelFormat 使用 PixelMapFormat 枚举
          pixelFormat: image.PixelMapFormat.NV12,
          // editable 根据需求设置
          editable: false,
          // alphaType 对于不透明的 YUV 数据，通常设置为 OPAQUE
          alphaType: image.AlphaType.OPAQUE
        };
        let data = frame.data; // 例如绘制到 Canvas

        try {
          // console.debug("data======",ObjectUtils.arrayBufferToHex(data))
          let pixelMap = image.createPixelMapSync(data.buffer, opts);
          this.saveImage(pixelMap)
          this.currentFrame = pixelMap;
          this.splitI420(data,frame.width, frame.height)
          console.debug('PixelMap 创建成功', frame.width, frame.height, data.byteLength);
        } catch (err) {
          console.error('创建 PixelMap 失败：' + err.message);
        }
        console.debug("上层获取到一帧数据")
      }
    }, 33); // ~30fps
  }

  splitI420(data: Uint8Array, width: number, height: number) {
    const ySize = width * height;
    const uvSize = (width * height) / 4;

    // 使用 slice 方法提取三个部分，这会创建新的 Uint8Array
    const Y = data.slice(0, ySize);
    const U = data.slice(ySize, ySize + uvSize);
    const V = data.slice(ySize + uvSize, ySize + 2 * uvSize);
    // 使用方式
    this.printUint8ArrayPreview(Y, 'Y分量');
    this.printUint8ArrayPreview(U, 'U分量');
    this.printUint8ArrayPreview(V, 'V分量');

  }

  printUint8ArrayPreview(arr: Uint8Array, name: string) {
    if (!arr || arr.length === 0) {
      console.log(`${name}: 数据为空或长度为 0`);
      return;
    }
    // 取前20个字节和后20个字节
    const head = Array.from(arr.slice(0, 20)).map(b => b.toString(16).padStart(2, '0')).join(' ');
    const tail = Array.from(arr.slice(-20)).map(b => b.toString(16).padStart(2, '0')).join(' ');

    console.log(`${name} 长度: ${arr.length}`);
    console.log(`${name} 前20字节: ${head}`);
    console.log(`${name} 后20字节: ${tail}`);
  }
}