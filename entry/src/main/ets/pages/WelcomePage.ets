import EntryAbility from '../entryability/EntryAbility';
import { AnalysisListener } from '../listeners/AnalysisListener';
import util from '@ohos.util';
import { WifiCommandHelper } from '../helper/WifiCommandHelper';
import NapiBuffer from 'libentry.so';
import { MimeType } from '../utils/VideoUtil'
import { fileIo as fs } from '@kit.CoreFileKit'; // 标准写法
import ability from '@ohos.ability.ability';
import taskpool from '@ohos.taskpool';
import { window, promptAction } from '@kit.ArkUI';

import resourceManager from '@ohos.resourceManager';
import router from '@ohos.router';
import commonEventManager from '@ohos.commonEventManager';
import prompt from '@ohos.prompt';

import Ability from '@ohos.app.ability.Ability';
import { PlayInfo } from '../model/PlayInfo';
import { PermissionRequestUtil } from '../utils/PermissionRequestUtil';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { dataSharePredicates } from '@kit.ArkData';
import picker from '@kit.MediaLibraryKit';
import { geoLocationManager } from '@kit.LocationKit';
import { RouteHelper } from '../macrochip/utils/RouteHelper';


// 定义函数类型
type SendUdpMessageFunc = (data: string) => void;


/*class ConcreteAnalysisListener implements AnalysisListener {
  // 持有WelcomePage实例，用于访问@State变量
  private page: WelcomePage;

  // 构造函数接收页面实例
  constructor(page: WelcomePage) {
    this.page = page;
  }

  // 实现接口的回调方法：接收数据并更新页面
  data(type: number, data: Uint8Array): void {
    if (type == 1) {
      const uint8: Uint8Array = new Uint8Array([data[4], data[5]]);
      //this.page.displayData=new util.TextDecoder().decode(uint8)
    }
    console.log(`处理数据类型：${type}，数据长度：${data.length}+数据${data[4]}+数据${data[5]}`);

    // 2. 更新页面的响应式状态（触发UI刷新）

  }
}*/

@Entry
struct WelcomePage {
  @State displayData: string = "等待数据";
  @State dataLength: number = 0;
  @StorageLink('udpMessage') udpMessage: string | null = null; // 监听UDP消息
  private sendUdp: SendUdpMessageFunc = AppStorage.Get('sendUdpMessage') as SendUdpMessageFunc; // 获取发送方法
  @State message: string = 'Hello World';
  @State currentIndex: number = 0;

  /*  private listener: AnalysisListener = {
      data:(type: number, data: Uint8Array)=> {
        // 实现逻辑
      }

    } ;*/

  aboutToAppear() {
    console.log('WelcomePage：开始渲染'); // 看DevEco Studio的Logcat是否输出
  }

  aboutToDisappear() {

  }

  onPageShow(): void {
    window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => {
      data.setWindowLayoutFullScreen(true) // 进入沉浸式
    });
    /*   window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => {
         data.setPreferredOrientation(window.Orientation.PORTRAIT); // 强制竖屏
       });*/
    this.getPlayInfo();
  }

  // 页面隐藏时恢复横屏
  onPageHide(): void {
    /* window.getLastWindow(this.getUIContext().getHostContext(), (err, data) => {
       try {
         data.setPreferredOrientation(window.Orientation.LANDSCAPE); // 恢复横屏
       } catch (e) {
       }

     });*/


  }

  build() {
    RelativeContainer() {
      RelativeContainer() {
        Image($r('app.media.img_welcome_bg'))
          .gesture(
            LongPressGesture({ repeat: true })
              .onAction((event: GestureEvent) => {
                // 长按触发（持续触发）
                RouteHelper.pushUrl('pages/LogExportPage');
                console.log("长按中...");
              })
              .onActionEnd(() => {
                // 长按结束

                console.log("长按结束");
              })
          ).onClick(() => {

          /*    router.pushUrl({
                url: 'pages/LogExportPage'  // 目标页路径
              }, router.RouterMode.Standard, (err) => { // Standard模式可省略
                if (err) {
                  console.error(`跳转失败: ${err.message}`);
                }
              });*/
        }).gesture(
          LongPressGesture({ duration: 400 })
            .onAction(() => {
              // 自定义处理，可空实现以拦截系统长按
              /*  router.pushUrl({
                  url: 'pages/LogListPage'  // 目标页路径
                }, router.RouterMode.Standard, (err) => { // Standard模式可省略
                  if (err) {
                    console.error(`跳转失败: ${err.message}`);
                  }
                });*/
              RouteHelper.pushUrl('pages/LogListPage');

            })
        )

        Stack() {
          Column({ space: 5 }) {
            // 背景图（底层）
            Image($r("app.media.ic_we_control")) // 引用本地图片资源
              .width(30)
              .height(30)
              .objectFit(ImageFit.Auto) // 图片缩放模式
            // 文本（顶层）
            Text('控制')
              .fontSize(18)
              .fontWeight(500)
              .fontColor('#FFFFFF')
          }
          .alignItems(HorizontalAlign.Center)
        }.alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        }).margin({ bottom: 30, right: 20 })
        .onClick(() => {
          if (!geoLocationManager.isLocationEnabled()) {
            const atManager = abilityAccessCtrl.createAtManager();
            atManager.requestGlobalSwitch(getContext(), abilityAccessCtrl.SwitchType.LOCATION)
              .then((enabled: boolean) => {
                if (enabled) {
                  // 用户已开启位置服务，执行定位操作
                } else {
                  // 用户拒绝开启，提示手动设置
                  promptAction.showToast({ message: '请开启手机定位', duration: 2000 });
                }
              })
              .catch((err: BusinessError) => {
                console.error(`Failed to request location switch: ${err.message}`);
              });
            return
          }

          //申请权限
          const permissionResults = PermissionRequestUtil.checkAndRequestPermissions(['ohos.permission.WRITE_MEDIA',
            'ohos.permission.READ_MEDIA', 'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'],
            getContext(this) as Context).then()
          // 假设 getPermissionStatusList 是返回目标 Promise 的方法
          permissionResults.then((result: Array<[Permissions, abilityAccessCtrl.GrantStatus]>) => {

            let isR = true;

            // 遍历结果数组
            result.forEach((permission, grantStatus) => {
              if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
                isR = false;
              }
              console.info(`权限名: ${permission}, 授权状态: ${grantStatus}`);
            });

            if (isR) {
              //跳转到控制页面
              //有权限跳转页面
             RouteHelper.pushUrl('pages/LanGuangPage');
              //RouteHelper.pushUrl('pages/NewVideoPage');

            } else {
              //没有权限
              promptAction.showToast({
                message: '请同意对应权限',
                duration: 2000, // 显示时长（毫秒）
                bottom: '50vp'   // 距屏幕底部距离
              });

            }

          }).catch((err: BusinessError) => {
            console.error(`查询失败, 错误码: ${err.code}, 错误信息: ${err.message}`);
          });


          /* router.pushUrl({
             url: 'pages/UsbMonitorComponent'  // 目标页路径
           }, router.RouterMode.Standard, (err) => {  // Standard模式可省略
             if (err) console.error(`跳转失败: ${err.message}`);
           });*/

          /*   router.pushUrl({
             url: 'pages/Index'  // 目标页路径
           }, router.RouterMode.Standard, (err) => {  // Standard模式可省略
             if (err) console.error(`跳转失败: ${err.message}`);
           });*/


        })

        Text(`firmware ver：${this.displayData}`).alignRules({}).margin({ top: 20, left: 20 }).fontColor(Color.White)


      }.width('100%')
      .height('100%')

    }
    .height('100%')
    .width('100%')
  }

  public readHexFile(): Uint8Array | null {
    try {
      // 获取resourceManager对象
      const context = getContext(this);
      const resourceMgr = context.resourceManager;

      // 获取rawfile目录下的文件描述符
      let fileDescriptor: Uint8Array = resourceMgr.getRawFileContentSync('1111.logbin');

      return fileDescriptor;
    } catch (error) {
      console.error('Failed to read hex file: ' + error);
    }
    return null;
  }

  private getPlayInfo() {
    // 获取主线程任务分发器（UI线程）
    // 定义周期性任务

    // 每1000ms（1秒）执行一次
    const intervalId = setInterval(() => {
      this.setfirVersion();
    }, 1000, 20);

    // 取消定时任务
    // clearInterval(intervalId);

  }

  private setfirVersion() {
    this.displayData = PlayInfo.firmwareVer;
    //console.log('获取版本号: ' + PlayInfo.firmwareVer);
  }
}