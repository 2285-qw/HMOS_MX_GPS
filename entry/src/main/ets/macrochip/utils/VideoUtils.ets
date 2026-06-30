//视频录像管理类管理类
import fs from '@ohos.file.fs';
import NapiBuffer, { VideoFrame } from 'libentry.so';
import { PlayInfo, Resolution } from '../../model/PlayInfo';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

export class VideoUtils {
  public static file: fs.File | null = null; //录像文件

  public static StreamRecording() {
    const name = VideoUtils.getName();
    const targetPath = `${getContext().filesDir}/Video/${name}.mp4`;
    VideoUtils.file = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    let fd = VideoUtils.file.fd;
    console.info("开始录像");
    NapiBuffer.SetRecordingType(0, PlayInfo.frameRate, 0)
    NapiBuffer.StreamRecording(fd, Resolution.V_1280);
  }


  public static StreamTCLRecording(speed: number) {
    const name = VideoUtils.getName();
    const targetPath = `${getContext().filesDir}/Video/${name}.mp4`;
    VideoUtils.file = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    let fd = VideoUtils.file.fd;
    console.info("开始录像");
    NapiBuffer.SetRecordingType(1, PlayInfo.frameRate, speed)
    NapiBuffer.StreamRecording(fd, Resolution.V_1280);
  }

  public static getName(): string {
    const now = new Date();
    const timestampName = `${now.getFullYear()}${(now.getMonth() + 1).toString()
      .padStart(2, '0')}${now.getDate()}_${now.getHours()}${(now.getMinutes()).toString()
      .padStart(2, '0')}${now.getSeconds()}`;
    const name = 'video_' + timestampName;
    return name;
  }

  //停止录像并保存
  public static StopRecording() {
    NapiBuffer.StopRecording();
    if (VideoUtils.file != null) {
      VideoUtils.saveVideoToGallery(VideoUtils.file.path)
      console.log("视频保存路径", VideoUtils.file.path)
    }
    NapiBuffer.SetRecordingType(0, PlayInfo.chipType, 0)
  }

  //可成功保存沙盒路径文件到相册
  public static async saveVideoToGallery(fileFd: string) {
    const context = getContext() as common.UIAbilityContext;
    let photoAccessHelperObj = photoAccessHelper.getPhotoAccessHelper(context);
    // 1. 创建媒体资源变更请求
    let assetChangeRequest =
      photoAccessHelper.MediaAssetChangeRequest.createAssetRequest(context, photoAccessHelper.PhotoType.VIDEO, "mp4");
    // 2. 添加视频资源到请求中
    let file = fs.openSync(fileFd, fs.OpenMode.READ_ONLY);
    assetChangeRequest.addResource(photoAccessHelper.ResourceType.VIDEO_RESOURCE, fileFd);
    fs.closeSync(file);
    // 3. 应用变更，将视频保存到图库
    await photoAccessHelperObj.applyChanges(assetChangeRequest);
    console.info('视频已成功保存到图库！');
  }
}