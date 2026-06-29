import { LanGuangObserver } from '../macrochip/Drone/observer/LanGuangObserver';
import EntryAbility from '../entryability/EntryAbility';
import { VideoPage } from './VideoPage';
import { common } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { ProtocolManager } from '../macrochip/Drone/core/protocol/ProtocolManager';
import { Protocol } from '../macrochip/Drone/core/protocol/Protocol';
import { ModeType, PageSendData } from '../macrochip/Drone/core/protocol/PageSendData';
import { LanGuangAnalysis } from '../macrochip/FunctionalAnalysis/LanGuangAnalysis';
import { LGPlaneHyBean } from '../macrochip/mode/LGPlaneHyBean';
import { SJHyInfo9CBean } from '../macrochip/mode/SJHyInfo9CBean';
import { LGPlaneGpsBean } from '../macrochip/mode/LGPlaneGpsBean';
import { LGGetFlyLineBean } from '../macrochip/mode/LGGetFlyLineBean';
import { LGInfo3HyBean } from '../macrochip/mode/LGInfo3HyBean';
import { LGInfo3BHyBean } from '../macrochip/mode/LGInfo3BHyBean';
import { LGTestBean } from '../macrochip/mode/LGTestBean';
import { LGPlaneGpsBean2 } from '../macrochip/mode/LGPlaneGpsBean2';
import { SJHyGetSettingBean } from '../macrochip/mode/SJHyGetSettingBean';
import { HyABBean } from '../macrochip/mode/HyABBean';
import { SJHyInfo9BBean } from '../macrochip/mode/SJHyInfo9BBean';
import { SendHyControlThread } from '../macrochip/thread/SendHyControlThread';
import { App, ComponentContent, router, UIContext } from '@kit.ArkUI';
import { SlideUnLockView } from '../macrochip/components/SlideUnLockView';
import { buildText } from '../macrochip/Dialog/sliderDialog';
import { Params, ParamsBuilder, Type } from '../macrochip/Dialog/DialogDataType/Params';
import { buildLeftMore } from '../macrochip/Dialog/LeftMoreDialog';
import { MoreParams } from '../macrochip/Dialog/DialogDataType/MoreParams';
import { MoreType } from '../macrochip/More/MoreType';
import image from '@ohos.multimedia.image';

import {
  SettingType,
  RIGHT_DRAWER_PAGE_TYPES,
  getSettingTypeName,
  NEW_SETTING_TYPE_LIST,
  getSettingStringName
} from '../model/SettingType';
import { WifiUtils } from '../utils/WifiUtils';
import { ObjectUtils } from '../utils/ObjectUtils';
import { Data } from '../macrochip/Dialog/setting/Data';
import { SendSettingParamsUtils } from '../macrochip/utils/SendSettingParamsUtils';
import { SettingCalibration } from '../macrochip/Dialog/setting/SettingCalibration';
import { MessageWhat } from '../macrochip/constant/MessageWhat';
import { CalibrationDialog } from '../macrochip/Dialog/CalibrationDialog';
import { CalibrationParams } from '../macrochip/Dialog/DialogDataType/CalibrationParams';
import { FunctionHelper } from '../helper/FunctionHelper';
import { geoLocationManager } from '@kit.LocationKit';
import { LgFollowThread } from '../macrochip/thread/LgFollowThread';
import { MoreBean } from '../macrochip/More/MoreBean';
import { SendEmitterUtil } from '../utils/SendEmitterUtil';
import { CompassView } from '../components/CompassView';
import { MapPage } from './MapPage';
import NapiBuffer, { VideoFrame } from 'libentry.so';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { PlayInfo, Resolution } from '../model/PlayInfo';
import { Mode, ShootButton } from '../macrochip/view/ShootButton';
import { buildShootingSelectionDialog } from '../macrochip/Dialog/ShootingSelectionDialog';
import { ShootingSelectionParams, ShootingType } from '../macrochip/Dialog/DialogDataType/ShootingSelectionParams';
import { Utils } from '../macrochip/utils/Utils';
import { RouteHelper } from '../macrochip/utils/RouteHelper';
import { PageNewSendData } from '../macrochip/Drone/core/protocol/PageNewSendData';
import { map } from '@kit.MapKit';
import { LGFlyLineBean } from '../macrochip/mode/LGFlyLineBean';
import { AnimType, SlideAnimParams, SlideAnimParamsBuilder } from '../macrochip/Dialog/DialogDataType/SlideAnimParams';
import { buildSlideAnim } from '../macrochip/Dialog/SlideAnimDialog';
import { TFConsumer } from '../macrochip/utils/TFConsumer';
import { SwitchType } from '../model/SwitchType';
import { Trajectory } from '../macrochip/Dialog/setting/Trajectory';
import { MoreView } from '../macrochip/Dialog/setting/MoreView';
import { ConnectConfig } from '../utils/ConnectConfig';
import { ImageSettingDialog } from '../macrochip/Dialog/ImageSettingDialog';
import { ImageSettingData, ImageSettingParams } from '../macrochip/Dialog/DialogDataType/ImageSettingParams';
import { MyDataProvider } from '../database/MyDataProvider';
import { FlightRecordUtils } from '../database/FlightRecordUtils';
import { PreferencesUtil } from '../macrochip/utils/PreferencesUtil';
import { VSollbar } from '../macrochip/view/VSollbar';


@Entry
@Component
struct LanGuangPage {
  //修改ui变量
  @State drone_power_level: Resource = $r('app.media.ic_plane_v'); //飞机电量
  @State rc_power_level: Resource = $r('app.media.ic_remote_control_0'); //遥控器电量
  @State wif_level: Resource = $r('app.media.ic_level');
  @State gps_level: Resource = $r('app.media.ic_gps_0'); //gps数量等级
  @State geomagnetism: Resource = $r('app.media.ic_magnetic_red') //地磁资源
  @State top_title: string = ''; //头部显示文本
  @State currentMode: Mode = Mode.PHOTO; //拍照模式
  @State shutMode: ShootingType = ShootingType.NO; //拍照选择样式
  @State isRecording: boolean = false; //是否录像中
  @State TF_S?: string = ''; //tf卡状态
  // 右侧弹窗：是否显示、当前选中的类型（用类型驱动右侧页面，确保点击左侧能切换）
  @State showRightDrawer: boolean = false;
  @State rightDrawerSelectedType: SettingType = SettingType.DATA;
  @State isExpanded: boolean = false; //层级显示
  @State isMap: boolean = false; //是否显示地图
  textTimerController: TextTimerController = new TextTimerController() //计时器控件
  @State format: string = 'mm:ss.SS'
  @State isDeleteWaypoint: Visibility = Visibility.None; //删除航点两个view显示状态
  //参数变量
  private lastBatPer: number = 101; //飞机电量
  private showDefaultMessage: boolean = true;
  private currentMsg: string = '';
  private abilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private sendHyControlThread?: SendHyControlThread; //控制线程
  // 在组件或Ability中获取UIContext
  private uiContext: UIContext = this.getUIContext(); // 组件内使用
  private router = this.uiContext.getRouter(); // 获取绑定当前上下文的Router对象
  private dialogId?: ComponentContent<object> = undefined; //校准弹窗id
  private DialogType: number = 0;
  private callback?: Callback<geoLocationManager.Location>;
  private lgFollowThread?: LgFollowThread;
  private data?: MoreParams; //左侧列表数据
  private imageSettingData?: ImageSettingParams; //图像调节列表
  private isRecord: boolean = false; //是否录制中
  private file: fs.File | null = null; //录像文件
  @State flyHeight: number = -1; //高度
  @State horizontalSpeed: number = -1 // /** 水平速度（米/秒） */
  @State distance: number = -1 //距离
  @State verticalSpeed: number = -1 // /** 垂直虚度（米/秒） */
  @State nowPlaneAngle: number = 0 // 飞机转向角
  @State nowPlaneLon: number = 0 // 现在飞机的经度(gps84)
  @State nowPlaneLat: number = 0 // 现在飞机的纬度(gps84)
  @State drone_p_t: string = '0.0V' //飞机电量
  @State remote_control_p_t: string = '0.0V' //遥控器电量
  @State gpsValue: number = 0 //Gps数量
  @State speed: number = 0 //速度档
  @State isCross: boolean = ConnectConfig.IS_CROSS;
  @State isPlusSign: boolean = ConnectConfig.IS_PLUS_SIGN;
  @State isWell: boolean = ConnectConfig.IS_WELL;
  @State isGoHome: boolean = false; // 是否返航中
  @State isFlying: boolean = false //是否飞行中
  @State provider: MyDataProvider = new MyDataProvider();
  @State unit: number = 0 //0英制mph 1公制m/s 2公制km/h
  private flightRecorder?: FlightRecordUtils;
  @State isVSollbar: boolean = false; //是否打开角度调节
  @State isZoom: boolean = false; //是否打开变焦
  @State zoomValue: number = 1;
  private zoomMiValue: number = 1;
  private zoomMaxValue: number = 5;

  build() {
    Stack() {
      RelativeContainer() {
        MapPage({
          isDeleteWaypoint: this.isDeleteWaypoint
        })
          .zIndex(this.isExpanded ? 2 : 3)
          .width(this.isExpanded ? '100%' : 160)
          .height(this.isExpanded ? '100%' : 80)
          .alignRules({
            // 垂直居中
            bottom: {
              anchor: '__container__',
              align: VerticalAlign.Bottom
            }
          })
          .visibility((this.isExpanded || this.isMap) ? Visibility.Visible : Visibility.None)
          .margin({ left: this.isExpanded ? 0 : 30, bottom: this.isExpanded ? 0 : 10 })
        VideoPage()
          .zIndex(this.isExpanded ? 3 : 2)
          .width(!this.isExpanded ? '100%' : 160)
          .height(!this.isExpanded ? '100%' : 80)
          .alignRules({
            // 垂直居中
            bottom: {
              anchor: '__container__',
              align: VerticalAlign.Bottom
            }
          })
          .margin({ left: !this.isExpanded ? 0 : 30, bottom: !this.isExpanded ? 0 : 10 })
          .visibility((!this.isExpanded || this.isMap) ? Visibility.Visible : Visibility.None);
      }

      RelativeContainer() {

        Image($r('app.media.ic_guide_cross'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .visibility(this.isCross ? Visibility.Visible : Visibility.None)
        Image($r('app.media.ic_guide_well'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .visibility(this.isWell ? Visibility.Visible : Visibility.None)
        Image($r('app.media.ic_guide_plus_sign'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
          .visibility(this.isPlusSign ? Visibility.Visible : Visibility.None)

        //头部栏
        Row() {
          Row() {
            //$r('app.media.ic_back')
            Image(null)
              .width(30)
              .height(30)
              .margin({ left: 20 })
              .objectFit(ImageFit.ScaleDown)
              .onClick(() => {
                // 关闭当前页面并返回上一页
                this.router.back(); // 组件内使用
              })
            Text('N/A').fontColor('#ffffffff').fontWeight(FontWeight.Bold).fontSize(18).margin({ left: 20 })
            Text(this.top_title)
              .borderRadius(15)
              .backgroundColor('#ff131212')
              .margin({ left: 20 })
              .fontColor('#ffffffff')

          }.width('30%')
          .height('100%')

          Row() {

            //速度档
            Text(this.getSpeedText()).fontColor('#ffffffff')
              .fontSize(12)
              .margin({ right: 10 })
            //地磁
            Image(this.geomagnetism)
              .width(25)
              .height(25)
              .objectFit(ImageFit.Fill)
              .margin({ right: 10 })

            //wifi信号
            /*    Image($r('app.media.ic_control_hd')).width(30).height(30).margin({ left: 10 }).objectFit(ImageFit.ScaleDown)
                Image(this.wif_level).width(25).height(25).margin({ right: 10 }).objectFit(ImageFit.ScaleDown)*/


            //飞机电量
            Image(this.drone_power_level)
              .width(25)
              .height(25)
              .objectFit(ImageFit.ScaleDown)
            Text(this.drone_p_t).fontColor('#ffffffff')
              .fontSize(12)
              .margin({ right: 10 })


            //遥控器电量
            Image(this.rc_power_level)
              .width(25)
              .height(25)
              .objectFit(ImageFit.ScaleDown)
            Text(this.remote_control_p_t).fontColor('#ffffffff')
              .fontSize(12)
              .margin({ right: 10 })

            //飞机Gps信号
            Image(this.gps_level)
              .width(50)
              .height(25)
              .objectFit(ImageFit.ScaleDown)
            Text(this.gpsValue + "").fontColor('#ffffffff')
              .fontSize(12)
              .margin({ right: 10, left: 5 })

            //右上角三个点按钮
            Image($r('app.media.icon_more'))
              .width(46)
              .height(10)
              .margin({ right: 10 })
              .objectFit(ImageFit.ScaleDown)
              .onClick(() => {
                this.showRightDrawer = true;
                this.rightDrawerSelectedType =
                  RIGHT_DRAWER_PAGE_TYPES.length > 0 ? RIGHT_DRAWER_PAGE_TYPES[0] : SettingType.DATA;
              })


          }.width('70%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.End)

        }
        .backgroundImage($r('app.media.top_bg'))
        .backgroundImageSize(ImageSize.Cover) // 关键: 等比缩放, 填满整个容器
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height('12%')

        //Tf卡
        Row() {
          Image($r('app.media.ic_sd_hint'))
            .width(15)
            .height(15)
            .objectFit(ImageFit.Fill)
            .margin({ right: 8, left: 5 })
          Text(this.TF_S).fontColor(Color.White).fontSize(12)
        }
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .backgroundColor('#60000000')
        .height(20)
        .borderRadius(10) // 设置圆角半径为 8vp[reference:3][reference:4]
        .padding({ right: 10 })
        .margin({ top: 60, right: 20 })

        //左侧按钮
        Column() {
          Image(this.isFlying ? $r('app.media.ic_to_land_off') : $r('app.media.ic_to_fly_off'))
            .width(30)
            .height(30)
            .margin({})
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {

              if (this.isFlying) {
                //降落
                let wrappedBuilder = wrapBuilder<[Params]>(buildText)

                let data: Params = new ParamsBuilder().setTitle("飞机确认下降")
                  .setText("请确保飞行器降落位置安全，避免落入水中或者建筑物顶部，防止飞行器丢失")
                  .setSlideText('向右滑动下降>')
                  .setUiContext(this.uiContext)
                  .setTitleImg($r('app.media.ic_unlock_land'))
                  .setOnSuccess((type: Type) => {
                    if (type == Type.SLIDE) {
                      //降落
                      this.sendHyControlThread?.setToLandValue(1);
                      setTimeout(() => {
                        this.sendHyControlThread?.setToLandValue(0);
                      }, 1000);
                    }

                  })
                  .build()
                const customContent = new ComponentContent(
                  this.uiContext, // 传入UIContext
                  wrappedBuilder, // @Builder函数
                  data
                );
                data.dialogId = customContent;
                this.uiContext.getPromptAction().openCustomDialog(customContent, {
                  alignment: DialogAlignment.Center
                })
              } else {
                //起飞
                // 打开弹窗（非模态，不抢占焦点）
                let wrappedBuilder = wrapBuilder<[Params]>(buildText)

                let data: Params = new ParamsBuilder().setTitle("请确认是否自动起飞")
                  .setText("请确保飞行器处于水平地面，请勿在狭窄空间人群中或者建筑物旁起飞，手切勿触碰螺旋桨")
                  .setSlideText('向右滑动起飞>')
                  .setUiContext(this.uiContext)
                  .setOnSuccess((type: Type) => {
                    if (type == Type.SLIDE) {
                      //起飞
                      console.log('解锁成功，执行起飞操作！类型：', type);
                      // 这里可以添加解锁后的具体逻辑，比如执行起飞操作
                      //解锁
                      this.onPressUnlock()

                      //起飞
                      setTimeout(() => {
                        this.sendHyControlThread?.setToLandValue(0);
                        this.sendHyControlThread?.setToFlyValue(1);
                      }, 200);

                      setTimeout(() => {
                        this.sendHyControlThread?.setToFlyValue(0);
                      }, 1000);
                    }

                  })
                  .build()
                const customContent = new ComponentContent(
                  this.uiContext, // 传入UIContext
                  wrappedBuilder, // @Builder函数
                  data
                );
                data.dialogId = customContent;
                this.uiContext.getPromptAction().openCustomDialog(customContent, {
                  alignment: DialogAlignment.Center
                })
              }


            })
          Image(this.isGoHome ? $r('app.media.ic_go_home_on') : $r('app.media.ic_to_land_off'))
            .width(30)
            .height(30)
            .margin({ top: 20 })
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {

              if (this.isGoHome) {
                //取消返航
                this.sendHyControlThread?.setCancelValue(1);
                setTimeout(() => {
                  this.sendHyControlThread?.setCancelValue(0);
                }, 1000);
              } else {
                //返航
                let wrappedBuilder = wrapBuilder<[Params]>(buildText)
                let data: Params = new ParamsBuilder().setTitle("请确认是否自动返航")
                  .setTitleImg($r('app.media.ic_unlock_back'))
                  .setUiContext(this.getUIContext())
                  .setText("请确保飞行器降落位置安全，避免落入水中或者建筑物顶部，防止飞行器丢失")
                  .setOnSuccess((type: Type) => {
                    if (type == Type.SLIDE) {
                      //返航
                      this.sendHyControlThread?.setGoHome(1);
                      setTimeout(() => {
                        this.sendHyControlThread?.setGoHome(0);
                      }, 1000);
                    } else {

                    }

                  })
                  .build()
                const customContent = new ComponentContent(
                  this.uiContext, // 传入UIContext
                  wrappedBuilder, // @Builder函数
                  data
                );
                data.dialogId = customContent;
                this.uiContext.getPromptAction().openCustomDialog(customContent, {
                  alignment: DialogAlignment.Center
                })
              }


            })
          Image($r('app.media.icon_function'))
            .width(30)
            .height(30)
            .margin({ top: 20 })
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              //左侧更多弹窗
              this.leftMoreDialog();
            })
        }.margin({ left: 30 }).justifyContent(FlexAlign.Center).alignRules({
          // 垂直居中
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          }
        })

        //左侧底部指北针
        CompassView()
          .margin({ left: 30 })
          .alignRules({
            // 垂直居中
            bottom: {
              anchor: '__container__',
              align: VerticalAlign.Bottom
            }
          }).visibility(this.isMap ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            this.isMap = true
          })

        //地图图传切换按钮
        Row() {
          Image($r('app.media.ic_show_angle_view'))
            .width(30)
            .height(30)
            .onClick(() => {
              this.isMap = false
            })
        }
        .visibility(!this.isMap ? Visibility.None : Visibility.Visible)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Top)
        .width(160)
        .height(80)
        .alignRules({
          // 垂直居中
          bottom: {
            anchor: '__container__',
            align: VerticalAlign.Bottom
          }
        })
        .margin({ left: 30, bottom: 10 })
        .onClick(() => {
          if (this.isMap) {
            this.isExpanded = !this.isExpanded;
            this.isDeleteWaypoint = Visibility.None
          } else {
            this.isMap = true
          }
        });

        //右侧拍照录像部分控件
        Column({ space: 10 }) {
          Image(this.getCameraMode()).width(30).height(30).objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.ShootingMoreDialog()
            })
          //拍照录像按钮
          ShootButton({
            mode: this.currentMode,
            isRecording: this.isRecording
          }).onClick(() => {
            if (this.currentMode === Mode.PHOTO) {
              console.info("拍照");
              // 在这里调用拍照逻辑
              // Utils.sendEvent(ProtocolManager.getInstance().getProtocol(), MessageWhat.MESSAGE_PHOTOS)
              SendEmitterUtil.sendEvent(MessageWhat.MESSAGE_PHOTOS)
            } else if (this.currentMode === Mode.RECORD) {
              // 录像模式：点击开始/停止录像
              this.isRecording = !this.isRecording;
              // 保存到沙箱目录

              if (this.isRecording) {
                const now = new Date();
                const timestampName = `${now.getFullYear()}${(now.getMonth() + 1).toString()
                  .padStart(2, '0')}${now.getDate()}_${now.getHours()}${(now.getMinutes()).toString()
                  .padStart(2, '0')}${now.getSeconds()}`;
                const name = 'video_' + timestampName;
                const targetPath = `${getContext().filesDir}/Video/${name}.mp4`;
                this.file = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
                let fd = this.file.fd;
                console.info("开始录像");
                this.textTimerController.start()
                this.isRecord = true;
                NapiBuffer.StreamRecording(fd, Resolution.V_1280);
              } else {
                console.info("停止录像");
                this.isRecord = false;
                NapiBuffer.StopRecording();
                this.textTimerController.pause()
                this.textTimerController.reset()
                if (this.file != null) {
                  this.saveVideoToGallery(this.file.path)
                  console.log("视频保存路径", this.file.path)
                }
              }
            } else if (this.currentMode === Mode.SCALE) {
              // 延时模式：点击开始/停止
              this.isRecording = !this.isRecording;
              if (this.isRecording) {
                console.info("开始延时摄影");
              } else {
                console.info("停止延时摄影");
              }
            }
          })

          //计时器
          TextTimer({
            isCountDown: false,
            count: 0,
            controller: this.textTimerController
          })
            .visibility(this.isRecording ? Visibility.Visible : Visibility.None)
            .format(this.format)
            .fontColor(Color.Black)
            .fontSize(8)
            .onTimer((utc: number, elapsedTime: number) => {
              console.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime)
            })

          //进入相册
          Image($r('app.media.icon_album')).width(30).height(30).objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              // this.ShootingMoreDialog()
              RouteHelper.pushUrl('pages/MediaAlbum')
            })

          //画面调节
          Image($r('app.media.ic_camera_popup')).width(30).height(30).objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.settingImageDialog()
            })

        }
        .zIndex(4)
        .alignRules({
          // 垂直居中
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .justifyContent(FlexAlign.Center)
        .margin({ right: 10, top: 30 })
        .height('80%')
        .width(60)

        Row({ space: 20 }) {
          Text(`D ${this.flyHeight == -1 ? 'N/A' : this.flyHeight}${(this.unit != 0 ? 'm' : 'ft')} `)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(700)
          Text(`H ${this.distance == -1 ? 'N/A' : this.distance}${(this.unit != 0 ? 'm' : 'ft')} `)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(700)
          Text(`DS ${this.horizontalSpeed == -1 ? 'N/A' : this.horizontalSpeed}${(this.unit != 0 ? 'm' : 'mph')} `)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(700)
          Text(`VS ${this.verticalSpeed == -1 ? 'N/A' : this.verticalSpeed}${(this.unit != 0 ? 'm' : 'mph')} `)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(700)

        }.alignRules({
          // 垂直居中
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        }).margin({ bottom: 20 })


        // 角度调节
        if (this.isVSollbar) {
          VSollbar({
            max: 10, // 最大刻度值
            thumbColor: '#FF5722', // 滑块颜色
            backgroundImage_: $r('app.media.ic_vseekbar_bg'),
            thumbImage: $r('app.media.ic_vseekbar_ball'),
            thumbSize: 15, // 滑块大小 (vp)
            onProgressChanged: (pos, dir) => {
              if (dir === VSollbar.UP) {
                // 向上转动云台，速度由 pos 决定
                this.sendHyControlThread?.setPtzV(1);
              } else if (dir === VSollbar.DOWN) {
                // 向下转动云台
                this.sendHyControlThread?.setPtzV(2);
              } else {
                // 停止转动 (dir === VSollbar.NONE)
                this.sendHyControlThread?.setPtzV(0);
              }

              // 在这里处理云台控制逻辑，例如发送 UDP 命令
              console.info(`位置: ${pos}, 方向: ${dir}`);
            }
          })
            .width(40)        // 设置宽度（建议较窄）
            .height(240)      // 设置高度（建议较长）
            .backgroundColor(Color.Transparent)
            .borderRadius(10)
            .margin({ right: 80 })
            .alignRules({
              // 垂直居中
              right: { anchor: '__container__', align: HorizontalAlign.End },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
        }


        if (this.isZoom) {
          Column() {
            Image($r('app.media.img_ptz_up')).width(30).height(30).objectFit(ImageFit.CENTER).onClick(() => {
              if (this.zoomValue >= this.zoomMaxValue) {
                this.zoomValue = this.zoomMaxValue
              } else {
                this.zoomValue = this.zoomValue + 1
              }
              SendEmitterUtil.sendEventNumber(MessageWhat.MESSAGE_ZOOM, this.zoomValue)
            })
            Column() {
              Slider({
                value: this.zoomValue,
                min: this.zoomMiValue,
                max: this.zoomMaxValue,
                step: 1
              })
                .trackColor(Color.Transparent)      // 滑条背景色（未滑动部分）[reference:7]
                .selectedColor(Color.Transparent)   // 滑条已滑动部分的颜色[reference:8]
                .blockColor('#ff0baefb')      // 滑块颜色[reference:9]
                .enabled(false)
                .trackThickness(0)                      // ✅ 将轨道厚度设为 0，彻底移除轨道区域
                .height(20)  // 垂直方向，高度是滑动行程
                .width(120)      // 垂直方向，宽度是轨道粗细
                .backgroundColor(Color.Transparent)
                .margin({ top: 50 })
                .rotate({ angle: -90 }) // 通过旋转 -90 度来实现垂直效果
                .onChange((value: number) => {
                  this.zoomValue = value
                });
            }
            .height(120)
            .backgroundImage($r('app.media.ptz_seekbar'))
            .backgroundImageSize(ImageSize.Auto)
            .backgroundImagePosition(Alignment.Center) // 显式设置居中

            Image($r('app.media.img_ptz_down')).width(30).height(30).objectFit(ImageFit.CENTER).onClick(() => {
              if (this.zoomValue <= this.zoomMiValue) {
                this.zoomValue = this.zoomMiValue
              } else {
                this.zoomValue = this.zoomValue - 1
              }
              console.debug("---------", this.zoomValue)
              SendEmitterUtil.sendEventNumber(MessageWhat.MESSAGE_ZOOM, this.zoomValue)
            })

          }.margin({ right: 80 }).width(30)
          .alignRules({
            // 垂直居中
            right: { anchor: '__container__', align: HorizontalAlign.End },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })

        }


      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent) // 关键设置 //透传点击效果
      .zIndex(4);

      // 右侧弹窗：占屏约 4/5，按 RIGHT_DRAWER_PAGE_TYPES 中配置的类型显示页面（可增删类型）
      if (this.showRightDrawer) {
        Row() {
          Blank()
            .width('20%')
            .height('100%')
            .onClick(() => {
              this.showRightDrawer = false;
            })
          Column() {
            Column() {
              Scroll() {
                Row() {
                  Image($r('app.media.ic_back'))
                    .width(24)
                    .height(24)
                    .layoutWeight(1)
                    .objectFit(ImageFit.ScaleDown)
                    .onClick(() => {
                      this.showRightDrawer = false;
                    })
                  ForEach(NEW_SETTING_TYPE_LIST, (item: SettingType) => {
                    Column() {
                      Text(getSettingStringName(item))
                        .fontColor(Color.White)
                        .fontSize(16)
                        .fontWeight(700)               // 方式二：数字粗细 (400正常, 700加粗)
                        .padding({
                          top: 12,
                          bottom: 12,
                          left: 16,
                          right: 16
                        })
                      /*  .colorFilter(ObjectUtils.hexToColorMatrix(this.rightDrawerSelectedType === item ? '#ff008ff4' :
                          '#fffcfcfc'))*/
                      Line()
                        .width('60%')
                        .height(1.5)
                        .background(Color.White)
                        .margin({ left: 10, right: 10 })
                        .visibility(this.rightDrawerSelectedType === item ? Visibility.Visible : Visibility.None)
                    }
                    .layoutWeight(1)
                    .borderRadius(8)
                    .onClick(() => {
                      this.rightDrawerSelectedType = item;
                    })
                  }, (item: SettingType) => String(item))
                }.alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .scrollBar(BarState.Off)
              .backgroundColor('#00171717')

              // 右侧内容区：直接根据 rightDrawerSelectedType 分支，确保状态变化触发切换
              Column() {
                if (this.rightDrawerSelectedType === SettingType.DATA) {
                  //设置围栏
                  Data()
                } else if (this.rightDrawerSelectedType === SettingType.TRAJECTORY) {
                  //轨迹
                  Trajectory()

                } else if (this.rightDrawerSelectedType === SettingType.MORE) {
                  //更多
                  MoreView()

                }
              }
              .layoutWeight(1)
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16, top: 16 })
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('80%')
          .height('100%')
          .backgroundColor('#ff030303')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .zIndex(5)
      }


    }
    .hitTestBehavior(HitTestMode.Transparent) // 关键设置
    .width('100%')
    .height('100%')
  }

  //左侧更多弹窗
  leftMoreDialog() {
    let wrappedBuilder = wrapBuilder<[MoreParams]>(buildLeftMore)
    if (this.data == undefined) {
      this.data = new MoreParams(this.uiContext, (id: number) => {
        this.onLeftMoreOnClick(id);
      })
      this.data.getType()
    }
    if (this.data) {
      const customContent = new ComponentContent(
        this.uiContext, // 传入UIContext
        wrappedBuilder, // @Builder函数
        this.data
      );
      this.data.dialogId = customContent;
      this.uiContext.getPromptAction().openCustomDialog(customContent, {
        alignment: DialogAlignment.Center
      })
    }
  }

  getTypeId(m: MoreType): number {
    return this.data?.arrMoreBean.findIndex(item => item.getType() === m) ?? 0;
  }

  setTypeSelected(m: MoreType, b: boolean) {
    this.data?.arrMoreBean[this.getTypeId(m)].setSelected(b);
  }

  getTypeIsSelected(m: MoreType): boolean {
    return this.data?.arrMoreBean[this.getTypeId(m)].isSelected() ?? false
  }

  //左侧更多按钮点击
  onLeftMoreOnClick(id: number) {
    let type = this.data?.arrMoreBean[id].getType();

    this.uiContext.getPromptAction().closeCustomDialog(this.data?.dialogId);

    if (this.data) {

      switch (type) {
        case MoreType.ZOOM:
          this.setTypeSelected(MoreType.ZOOM, !this.getTypeIsSelected(MoreType.ZOOM));
          this.isZoom = this.getTypeIsSelected(MoreType.ZOOM)
          break
        case MoreType.PLACE:

          if (this.sendHyControlThread) {
            this.sendHyControlThread?.setPTZ_H(1)
          }
          setTimeout(() => {
            // 执行异步任务（如更新UI状态）
            this.sendHyControlThread?.setPTZ_H(0)
          }, 1000); // 1000毫秒 = 1秒

          break
        case MoreType.THERMAL_IMAGING:
          //热成想
          if (this.getTypeIsSelected(MoreType.THERMAL_IMAGING)) {
            this.setTypeSelected(MoreType.THERMAL_IMAGING, false);
            ImageSettingParams.setWb(ImageSettingParams.to100ToMax(0, 255))
            ImageSettingParams.setContrast(ImageSettingParams.to100ToMax(50, 1023))
            ImageSettingParams.setSaturation(ImageSettingParams.to100ToMax(50, 255))
            ImageSettingParams.setSharpen(ImageSettingParams.to100ToMax(50, 255))
          } else {
            this.setTypeSelected(MoreType.THERMAL_IMAGING, true);
            ImageSettingParams.setThermalImaging(1)
          }

          break
        case MoreType.LIGHT:
          //灯光
          RouteHelper.pushUrl('pages/LightPage')


          break
        case MoreType.CAMERA_ADJUST:
          this.data?.arrMoreBean[id].setSelected(!this.data?.arrMoreBean[this.getTypeId(MoreType.CAMERA_ADJUST)].isSelected());
          this.isVSollbar = this.data?.arrMoreBean[id].isSelected() ?? false

          console.debug("=============", this.data?.arrMoreBean[MoreType.CAMERA_ADJUST].isSelected(), id,
            MoreType.CAMERA_ADJUST)

          break
        case MoreType.REV:
          FunctionHelper.switchRev()
          break
        case MoreType.UNLOCK:
          this.onPressUnlock()
          break
        case MoreType.FOLLOW:

          if (this.data?.arrMoreBean[id].isSelected()) {
            //关闭跟随
            this.lgFollowThread?.stopFollowTimer();
            this.data?.arrMoreBean[id].setSelected(!this.data?.arrMoreBean[id].isSelected());
          } else {
            //开启跟随
            //Gps跟随
            let wrappedBuilder = wrapBuilder<[SlideAnimParams]>(buildSlideAnim)
            let data: SlideAnimParams = new SlideAnimParamsBuilder()
              .setAnimType(AnimType.FOLLOW_GPS)
              .setOnSuccess((type: Type) => {
                this.uiContext.getPromptAction().closeCustomDialog(data.dialogId)
                if (type == Type.SLIDE) {
                  //跟随
                  if (this.lgFollowThread == undefined) {
                    this.lgFollowThread = new LgFollowThread();
                  }
                  //开启跟随
                  this.lgFollowThread?.sendFollowData();

                  this.data?.arrMoreBean[id].setSelected(!this.data?.arrMoreBean[id].isSelected());
                  this.data?.dialogId?.update(this.data)
                }
              })
              .build()

            const customContent = new ComponentContent(
              this.uiContext, // 传入UIContext
              wrappedBuilder, // @Builder函数
              data
            );
            data.dialogId = customContent;
            this.uiContext.getPromptAction().openCustomDialog(customContent, {
              alignment: DialogAlignment.Center
            })
          }


          break
        case MoreType.POINT:
          //多点

          this.isMap = true
          this.isExpanded = true;
          this.isDeleteWaypoint = Visibility.Visible
          break
        case MoreType.AROUND:

          if (this.data?.arrMoreBean[id].isSelected()) {
            //关闭环绕
            this.sendHyControlThread?.setCancelValue(1)
            setTimeout(() => {
              // 执行异步任务（如更新UI状态）
              this.sendHyControlThread?.setCancelValue(0)
            }, 1000); // 1000毫秒 = 1秒

            this.data?.arrMoreBean[id].setSelected(!this.data?.arrMoreBean[id].isSelected());
          } else {
            //开启环绕
            let wrappedBuilder = wrapBuilder<[SlideAnimParams]>(buildSlideAnim)
            let data: SlideAnimParams = new SlideAnimParamsBuilder()
              .setAnimType(AnimType.FLY_SURROUND)
              .setOnSuccess((type: Type) => {
                this.uiContext.getPromptAction().closeCustomDialog(data.dialogId)
                if (type == Type.SLIDE) {
                  this.sendHyControlThread?.setAroundValue(1)
                  setTimeout(() => {
                    // 执行异步任务（如更新UI状态）
                    this.sendHyControlThread?.setAroundValue(0)
                  }, 1000); // 1000毫秒 = 1秒

                  this.data?.arrMoreBean[id].setSelected(!this.data?.arrMoreBean[id].isSelected());
                  this.data?.dialogId?.update(this.data)
                }
              })
              .build()
            const customContent = new ComponentContent(
              this.uiContext, // 传入UIContext
              wrappedBuilder, // @Builder函数
              data
            );
            data.dialogId = customContent;
            this.uiContext.getPromptAction().openCustomDialog(customContent, {
              alignment: DialogAlignment.Center
            })
          }
          break
        case MoreType.UNLOCK:
          this.sendHyControlThread?.setLockValue(1)
          setTimeout(() => {
            // 执行异步任务（如更新UI状态）
            this.sendHyControlThread?.setLockValue(0)
          }, 1000); // 1000毫秒 = 1秒
          break

        case MoreType.FAR_FLY:
          //一键远飞
          let wrappedBuilder = wrapBuilder<[Params]>(buildText)
          let data: Params = new ParamsBuilder().setTitle("一键远飞")
            .setText("开始后，飞行器将远离目标斜着往后退25米左右，注意后面空间，避免造成伤害!若遇紧急情况，立即用遥控器中断飞行!")
            .setOnSuccess((type: Type) => {
              if (type == Type.SLIDE) {
                this.sendHyControlThread?.setFarFly(1)
                setTimeout(() => {
                  // 执行异步任务（如更新UI状态）
                  this.sendHyControlThread?.setFarFly(0)
                }, 1000); // 1000毫秒 = 1秒
              }
              this.uiContext?.getPromptAction().closeCustomDialog(data.dialogId)
            }).build()
          const customContent = new ComponentContent(
            this.uiContext, // 传入UIContext
            wrappedBuilder, // @Builder函数
            data
          );
          data.dialogId = customContent;
          this.uiContext.getPromptAction().openCustomDialog(customContent, {
            alignment: DialogAlignment.Center
          })
          break;
        case MoreType.SKY_FLY:
          //冲天功能
          let wrappedBuilder1 = wrapBuilder<[Params]>(buildText)
          let data1: Params = new ParamsBuilder().setTitle("一键冲天")
            .setText("开始后，飞行器将自动上升15米左右，注意上方障碍物，避免造成伤害!若遇紧急情况，立即用遥控器中断飞行!")
            .setOnSuccess((type: Type) => {
              if (type == Type.SLIDE) {
                this.sendHyControlThread?.setSkyFly(1)
                setTimeout(() => {
                  // 执行异步任务（如更新UI状态）
                  this.sendHyControlThread?.setSkyFly(0)
                }, 1000); // 1000毫秒 = 1秒
              }
              this.uiContext?.getPromptAction().closeCustomDialog(data1.dialogId)
            }).build()
          const customContent1 = new ComponentContent(
            this.uiContext, // 传入UIContext
            wrappedBuilder1, // @Builder函数
            data1
          );
          data1.dialogId = customContent1;
          this.uiContext.getPromptAction().openCustomDialog(customContent1, {
            alignment: DialogAlignment.Center
          })

          break;
        case MoreType.SPIRAL_FLY:
          //螺旋功能
          let wrappedBuilder2 = wrapBuilder<[Params]>(buildText)
          let data2: Params = new ParamsBuilder().setTitle("一键螺旋")
            .setText("开始后，飞行器将自动螺旋上升(最大半径15米左右)，注意周围环境，避免造成伤害!若遇紧急情况，立即用遥控器中断飞行!")
            .setOnSuccess((type: Type) => {
              if (type == Type.SLIDE) {
                this.sendHyControlThread?.setSpiralFly(1)
                setTimeout(() => {
                  // 执行异步任务（如更新UI状态）
                  this.sendHyControlThread?.setSpiralFly(0)
                }, 1000); // 1000毫秒 = 1秒
              }
              this.uiContext?.getPromptAction().closeCustomDialog(data2.dialogId)
            }).build()
          const customContent2 = new ComponentContent(
            this.uiContext, // 传入UIContext
            wrappedBuilder2, // @Builder函数
            data2
          );
          data2.dialogId = customContent2;
          this.uiContext.getPromptAction().openCustomDialog(customContent2, {
            alignment: DialogAlignment.Center
          })
          break;
        case MoreType.FIND_DRONE:
          RouteHelper.pushUrl('pages/SeekPlanePage');

          break


      }
    }
  }

  onPressUnlock() {
    //解锁
    this.sendHyControlThread?.setLockValue(1)
    setTimeout(() => {
      this.sendHyControlThread?.setLockValue(0)
    }, 1000);
  }

  onPageShow(): void {
    // 持续订阅
    emitter.on({ eventId: Protocol.LAN_GUANG }, (eventData: emitter.GenericEventData<PageSendData>) => {
      // console.log("收到蓝光功能字信息:", JSON.stringify(eventData));
      if (eventData.data?.modeType == ModeType.FlightControl) {
        //飞控数据
        this.onData(eventData.data)
      }
    });

    //订阅页面数据和底层数据区分开
    emitter.on({ eventId: ModeType.Page }, (eventData: emitter.GenericEventData<PageNewSendData<Object>>) => {
      //  console.log("页数数据信息:", JSON.stringify(eventData));
      //页面数据
      this.onNewMessage(eventData.data)

    });


    this.sendHyControlThread = new SendHyControlThread();
    this.sendHyControlThread.start();

    //开始定位
    this.GetLocation();

    //每五秒一次读取sd卡状态
    TFConsumer.start();

    // 2. 创建飞行记录工具，传入数据提供者
    // 参数：上下文、数据提供者、无人机型号（比如 1 代表某款机型）
    // this.provider.getFlyData.bind(this.provider),// 绑定 this
    this.flightRecorder = new FlightRecordUtils(
      getContext(this),
      () => ({
        rockerUp: this.provider.rockerUp,
        rockerDown: this.provider.rockerDown,
        rockerRightRotate: this.provider.rockerRightRotate,
        rockerLeftRotate: this.provider.rockerLeftRotate,
        rockerFont: this.provider.rockerFont,
        rockerBack: this.provider.rockerBack,
        rockerRight: this.provider.rockerRight,
        rockerLeft: this.provider.rockerLeft,
        height: this.flyHeight,
        horizontalSpeed: this.horizontalSpeed,
        distance: this.distance,
        verticalSpeed: this.verticalSpeed,
        nowPlaneLon: this.nowPlaneLon,
        nowPlaneLat: this.nowPlaneLat,
        nowPlaneAngle: this.nowPlaneAngle
      }),
    );

    this.unit = PreferencesUtil.getData(PreferencesUtil.UNIT, 0) as number;


  }

  //监听位置变化
  GetLocation() {
    // 1. 定义持续定位请求参数
    let request: geoLocationManager.ContinuousLocationRequest = {
      'interval': 1, // 上报间隔（秒）
      'locationScenario': geoLocationManager.UserActivityScenario.TRANSPORT // 场景类型
    };

    // 2. 注册位置变化监听
    this.callback = (location: geoLocationManager.Location): void => {

      //跟随
      if (this.lgFollowThread != undefined) {
        this.lgFollowThread.setLocation(location)
      }
      //传递发送位置信息
      SendEmitterUtil.sendEventLocation(MessageWhat.MESSAGE_LOCATION, location)
    };
    geoLocationManager.on('locationChange', request, this.callback);

  }

  //校准弹窗
  setCalibrationDialog(type: number) {
    if (this.dialogId == undefined) {
      this.DialogType = type;
      let wrappedBuilder = wrapBuilder<[CalibrationParams]>(CalibrationDialog)
      let data = new CalibrationParams()
      if (type == 1) {
        //水平校准
        data.setLevelType()
      } else if (type == 2) {
        //罗盘水平校准
        data.setCompassLevelType()
      } else if (type == 3) {
        //罗盘水平校准
        data.setCompassVerticalType()
      }
      const customContent = new ComponentContent(
        this.uiContext, // 传入UIContext
        wrappedBuilder, // @Builder函数
        data
      );
      this.dialogId = customContent;
      data.dialogId = customContent;
      this.uiContext.getPromptAction().openCustomDialog(customContent, {
        alignment: DialogAlignment.Center
      })
    }
  }

  disCalibrationDialog() {
    if (this.dialogId != undefined) {
      this.uiContext?.getPromptAction().closeCustomDialog(this.dialogId)
      this.dialogId = undefined
    }
  }

  //拍照模式弹窗
  ShootingMoreDialog() {
    let wrappedBuilder = wrapBuilder<[ShootingSelectionParams]>(buildShootingSelectionDialog)
    let data = new ShootingSelectionParams(this.uiContext)
    data.setonItemClick((arrMoreBean: ShootingType) => {
      this.shutMode = arrMoreBean
    })
    data.arrMoreBean = this.shutMode
    const customContent = new ComponentContent(
      this.uiContext, // 传入UIContext
      wrappedBuilder, // @Builder函数
      data
    );
    data.dialogId = customContent;
    this.uiContext.getPromptAction().openCustomDialog(customContent, {
      alignment: DialogAlignment.CenterEnd,
      offset: { dx: -80, dy: 0 } // 向左偏移 10vp，避免完全贴边
    })
  }

  //设置图像弹窗
  settingImageDialog() {
    let wrappedBuilder = wrapBuilder<[ImageSettingParams]>(ImageSettingDialog)
    if (this.imageSettingData === undefined) {
      this.imageSettingData = new ImageSettingParams(this.uiContext)
      this.imageSettingData.setonItemClick((num: number, imageSettingData: ImageSettingData) => {

        this.imageSettingData?.dialogId?.update(this.imageSettingData)
      })
    }
    const customContent = new ComponentContent(
      this.uiContext, // 传入UIContext
      wrappedBuilder, // @Builder函数
      this.imageSettingData
    );
    this.imageSettingData.dialogId = customContent;
    this.uiContext.getPromptAction().openCustomDialog(customContent, {
      alignment: DialogAlignment.TopEnd,
      offset: { dx: -80, dy: 60 } // 向左偏移 10vp，避免完全贴边
    })
  }

  aboutToDisappear(): void {
    //取消订阅
    emitter.off(Protocol.LAN_GUANG)
    //取消订阅
    emitter.off(ModeType.Page)
    this.sendHyControlThread?.cancel();
    // 3. 结束时取消定位监听
    geoLocationManager.off('locationChange', this.callback);
  }

  private sendNotice(id: number, data?: Uint8Array) {
    // 1. 创建事件对象
    const innerEvent: emitter.InnerEvent = {
      eventId: id, // 事件ID，需与接收方保持一致
      priority: emitter.EventPriority.HIGH  // 优先级控制
    };

    // 2. 创建要发送的数据
    const eventData: emitter.EventData = {
      data: { data: data }
    };

    // 3. 发送事件
    emitter.emit(innerEvent, eventData);
    //console.log("事件发送成功");
  }

  //飞控数据处理
  onData(pageSendData: PageSendData) {
    if (!pageSendData.data) {
      return
    }
    const data = pageSendData.data;
    switch (pageSendData.type) {
      case LanGuangObserver.TYPE_DRONE_STATUS:
        // 解析无人机状态数据为LGPlaneHyBean
        const lgPlaneHyBean: LGPlaneHyBean = LanGuangAnalysis.getInstance().parseDroneStatus(data);
        console.log(`无人机状态数据: ${JSON.stringify(lgPlaneHyBean)}`);
        const gpsValue = lgPlaneHyBean.GpsNum;

        if (gpsValue >= 20) {
          this.gps_level = $r('app.media.ic_gps_5')
        } else if (gpsValue >= 15) {
          this.gps_level = $r('app.media.ic_gps_4')
        } else if (gpsValue >= 10) {
          this.gps_level = $r('app.media.ic_gps_3')
        } else if (gpsValue >= 5) {
          this.gps_level = $r('app.media.ic_gps_2')
        } else {
          this.gps_level = $r('app.media.ic_gps_1')
        }
        this.gpsValue = gpsValue;
        //校准处理
        if (lgPlaneHyBean.InsCalib == 0) {
          //水平校准
          this.setCalibrationDialog(1)
        } else {
          if (this.DialogType == 1) {
            this.disCalibrationDialog()
          }
        }
        // TODO: 2019/10/28 指南校准
        if (lgPlaneHyBean.MagXYCalib == 0) {
          //罗盘水平校准
          this.setCalibrationDialog(2)
        } else {
          if (this.DialogType == 2) {
            this.disCalibrationDialog()
          }

        }
        if (lgPlaneHyBean.MagZCalib == 0) {
          //罗盘垂直校准
          this.setCalibrationDialog(3)
        } else {
          if (this.DialogType == 3) {
            this.disCalibrationDialog()
          }
        }
        //速度档
        this.speed = lgPlaneHyBean.RcFastMode


        /*---------文字提示----------*/
        // 默认显示
        if (this.showDefaultMessage) {
          if (lgPlaneHyBean.modeGps == 1) {
            this.currentMsg = 'GPS模式';
            //isGpsMode = true;
          } else {
            this.currentMsg = '姿态模式';
            // isGpsMode = false;
          }
        }
        this.top_title = this.currentMsg


        if (this.lastBatPer > lgPlaneHyBean.BatVal || lgPlaneHyBean.BatVal - this.lastBatPer >= 10) {
          if (lgPlaneHyBean.BatVal >= 75) {
            this.drone_power_level = $r('app.media.ic_plane_v_3'); //飞机电量
          } else if (lgPlaneHyBean.BatVal >= 50) {
            this.drone_power_level = $r('app.media.ic_plane_v_2'); //飞机电量
          } else if (lgPlaneHyBean.BatVal >= 25) {
            console.log(`SJHyInfo9CBean:===`, '-------------------');
            this.drone_power_level = $r('app.media.ic_plane_v_1'); //飞机电量
          } else if (lgPlaneHyBean.BatVal >= 0) {
            this.drone_power_level = $r('app.media.ic_plane_v_0'); //飞机电量
          }
        }

        this.lastBatPer = lgPlaneHyBean.BatVal;


        /*---------是否飞行中状态处理---------*/
        if (!this.isFlying && lgPlaneHyBean.Armed == 2) { //起飞

          this.flightRecorder?.start();

        } else if (this.isFlying && lgPlaneHyBean.Armed != 2) { //降落

          this.flightRecorder?.stop();

        }


        this.isGoHome = lgPlaneHyBean.FlyMode == 1;
        this.isFlying = lgPlaneHyBean.Armed == 2
        this.nowPlaneAngle = lgPlaneHyBean.AttitudeYaw / 100;
        if (this.nowPlaneAngle < 0) {
          this.nowPlaneAngle += 360;
        }


        break
      case LanGuangObserver.TYPE_GPS_INFO_9C:
        const sjHyInfo9CBean: SJHyInfo9CBean = LanGuangAnalysis.getInstance().parseSJHyInfo9C(data)


        //地磁数据
        if (sjHyInfo9CBean.MagInterference < 200) {
          this.geomagnetism = $r('app.media.ic_magnetic_green')
        } else if (sjHyInfo9CBean.MagInterference >= 200 && sjHyInfo9CBean.MagInterference < 900) {
          this.geomagnetism = $r('app.media.ic_magnetic_yellow')
        } else {
          this.geomagnetism = $r('app.media.ic_magnetic_red')
        }

        //遥控器电量
        if (sjHyInfo9CBean.RmoteVol < 25) {
          this.rc_power_level = $r('app.media.ic_remote_control_1')
        } else if (sjHyInfo9CBean.RmoteVol < 50) {
          this.rc_power_level = $r('app.media.ic_remote_control_2')
        } else if (sjHyInfo9CBean.RmoteVol < 75) {
          this.rc_power_level = $r('app.media.ic_remote_control_3')
        } else {
          this.rc_power_level = $r('app.media.ic_remote_control_4')
        }
        this.remote_control_p_t = sjHyInfo9CBean.BatVal / 100 + "V"
        this.drone_p_t = sjHyInfo9CBean.RmoteVol + '%'

        console.log(`SJHyInfo9CBean: ${JSON.stringify(sjHyInfo9CBean)}`, data.length);
        break
      case LanGuangObserver.TYPE_GPS_INFO_8C:
        const droneGPS: LGPlaneGpsBean = LanGuangAnalysis.getInstance().parseLGPlaneGps(data)
        break
      case LanGuangObserver.TYPE_POINT_INFO:
        const FlyLine: LGGetFlyLineBean = LanGuangAnalysis.getInstance().parsePointNumRespond(data)
        break
      case LanGuangObserver.TYPE_REAL_TIME_INFO_8E:
        const LGInfo3HyBean: LGInfo3HyBean = LanGuangAnalysis.getInstance().parseLGInfo3Hy(data)
        break
      case LanGuangObserver.TYPE_REAL_TIME_INFO_8F:
        const LGInfo3BHyBean: LGInfo3BHyBean = LanGuangAnalysis.getInstance().parseLGInfo3BHy(data)

        break
      case LanGuangObserver.TYPE_TEST_INFO_8D:
        const LGTestBean1: LGTestBean = LanGuangAnalysis.getInstance().parseLGTest(data)
        break
      case LanGuangObserver.TYPE_GPS_INFO_9D:
        const lgPlaneGpsBean2: LGPlaneGpsBean2 = LanGuangAnalysis.getInstance().parseLGPlaneGps2(data)
        this.nowPlaneLon = lgPlaneGpsBean2.AirplaneLon / 10000000;
        this.nowPlaneLat = lgPlaneGpsBean2.AirplaneLat / 10000000;
        this.distance = lgPlaneGpsBean2.Distance;
        this.flyHeight = lgPlaneGpsBean2.Altitude - 100;
        this.horizontalSpeed = lgPlaneGpsBean2.Speed / 10;
        this.verticalSpeed = lgPlaneGpsBean2.Velocity / 10;
        break
      case LanGuangObserver.TYPE_SETTING_INFO_9A:
        const SJHyGetSettingBean: SJHyGetSettingBean = LanGuangAnalysis.getInstance().parseSJHyGetSetting(data)
        SendSettingParamsUtils.getInstance().sendsaveSuccess()
        //设置围栏成功
        console.log(`设置围栏成功9a`)
        this.sendNotice(Data.setting)
        break
      case LanGuangObserver.TYPE_SETTING_INFO_AB:
        const HyABBean: HyABBean = LanGuangAnalysis.getInstance().parseHyAB(data)
        SendSettingParamsUtils.getInstance().sendsaveSuccess()
        this.sendNotice(Data.setting)
        //设置围栏成功
        console.log(`设置围栏成功ab`)
        console.log(`设置围栏成功ab: ${JSON.stringify(HyABBean)}`);
        break
      case LanGuangObserver.TYPE_SETTING_INFO_9B:
        const SJHyInfo9BBean: SJHyInfo9BBean = LanGuangAnalysis.getInstance().parseSJHyInfo9B(data)
        break

    }

  }

  onNewMessage(pageSendData?: PageNewSendData<Object>) {
    switch (pageSendData?.type) {
      case MessageWhat.MESSAGE_UNIT:
        this.unit = PreferencesUtil.getData(PreferencesUtil.UNIT, 0) as number;
        break
      case MessageWhat.MESSAGE_HORIZONTAL_CALIBRATION:
        //水平校准
        this.sendHyControlThread?.setLevelCor(1)
        // 延迟1秒后执行（非阻塞主线程）
        setTimeout(() => {
          // 执行异步任务（如更新UI状态）
          this.sendHyControlThread?.setLevelCor(0)
        }, 1000); // 1000毫秒 = 1秒
        break
      case MessageWhat.MESSAGE_GUIDE_CALIBRATION:
        //指南校准
        this.sendHyControlThread?.setMagCor(1)
        // 延迟1秒后执行（非阻塞主线程）
        setTimeout(() => {
          // 执行异步任务（如更新UI状态）
          this.sendHyControlThread?.setMagCor(0)
        }, 1000); // 1000毫秒 = 1秒
        break
      case MessageWhat.MESSAGE_WAYPOINT:
        //航点数据
        //  pageSendData.addedMarkers?
        // 打开弹窗（非模态，不抢占焦点）

        let wrappedBuilder = wrapBuilder<[Params]>(buildText)
        let data: Params = new ParamsBuilder().setTitle("请确认是否航点飞行")
          .setText("请确保航点位置安全，避免飞行器撞击建筑物，防止飞行器丢失")
          .setTitleImg($r('app.media.ic_unlock_point'))
          .setOnSuccess((type: Type) => {
            this.uiContext.getPromptAction().closeCustomDialog(data.dialogId)
            if (type == Type.SLIDE) {
              let addedMarkers: map.Marker[] = pageSendData.value as map.Marker[]; // 存储已添加的标记点
              this.sendPointData(addedMarkers);
            }
          })
          .build()

        const customContent = new ComponentContent(
          this.uiContext, // 传入UIContext
          wrappedBuilder, // @Builder函数
          data
        );
        data.dialogId = customContent;
        this.uiContext.getPromptAction().openCustomDialog(customContent, {
          alignment: DialogAlignment.Center
        })
        break
      case SwitchType.NOTIFY_TF_EXIST_CARD:
        // 有tf卡
        this.TF_S = '有tf卡'
        ConnectConfig.TF_CARD_REMAIN_SPACE

        if (PlayInfo.sdRemainSpace != 0 || PlayInfo.sdTotalSpace != 0) {
          let remainSpace: number = PlayInfo.sdRemainSpace / 1024;
          let totalSpace = PlayInfo.sdTotalSpace / 1024;
          // sdStreamTv.setText(String.format(Locale.getDefault(), "%.2fG/%.2fG", remainSpace, totalSpace));
          this.TF_S = `${remainSpace.toFixed(2)} / ${totalSpace.toFixed(2)}`
        }

        break
      case SwitchType.NOTIFY_TF_NO_CARD:
        // 没有tf卡
        this.TF_S = '检测不到SD卡'
        break
      case SwitchType.NOTIFY_TF_FORMAT_BEGIN:
        // 开始格式化
        this.TF_S = '正在格式化SD卡'
        break
      case SwitchType.NOTIFY_TF_FORMAT_FINISHED:
        // 格式化完成
        this.TF_S = '格式化成功'
        break
      case SwitchType.NOTIFY_TF_FORMAT_FAIL:
        // 格式化失败
        this.TF_S = '格式化失败'
        break
      case SwitchType.NOTIFY_TF_NEED_PLUG:
        // tf 需要重新插拔卡
        this.TF_S = 'SD卡需重新插拔'
        break
      case SwitchType.NOTIFY_TF_FORMAT:
        // tf卡需要格式化
        this.TF_S = 'SD卡需要格式化'
        break
      case MessageWhat.MESSAGE_AUXILIARY_CROSS:
        //交叉线
        this.isCross = ConnectConfig.IS_CROSS

        break
      case MessageWhat.MESSAGE_AUXILIARY_WELL:
        //网格线
        this.isWell = ConnectConfig.IS_WELL
        break
      case MessageWhat.MESSAGE_AUXILIARY_PLUS_SIGN:
        //+线
        this.isPlusSign = ConnectConfig.IS_PLUS_SIGN
        break

    }
  }

  //发送航点数据
  async sendPointData(addedMarkers: map.Marker[]) {
    for (let i = 0; i < addedMarkers.length; i++) {
      // 构建固定头部 16 字节数组
      let data = new Uint8Array(16);
      data[0] = 0x68;
      data[1] = 0x04;
      data[2] = 0x0c;

      // 填充航点参数
      let bean = new LGFlyLineBean();
      bean.PointGpsLon = Math.floor(addedMarkers[i].getPosition().longitude * 10000000);
      bean.PointGpsLat = Math.floor(addedMarkers[i].getPosition().latitude * 10000000);
      bean.PointNum = i;
      bean.PointAltitude = Math.floor(this.flyHeight * 10);
      bean.PointSpeed = 4;
      bean.PointTime = 0;
      // 调用转换函数，假设返回 Uint8Array
      let newData = LanGuangAnalysis.getInstance().convertFlyLine(bean);
      // 将转换后的数据复制到 data 的索引 3 开始的位置
      data.set(newData, 3);

      // 计算校验和（异或）
      let xor: number = data[1];
      for (let j = 2; j <= 14; j++) {
        xor ^= data[j];
      }
      data[15] = xor;

      // 发送 TCP 命令
      EntryAbility.getInstance().sendUDPCmd(data);
      // 等待 50ms
      await sleep(50);
    }
  }

  //可成功保存沙盒路径文件到相册
  async saveVideoToGallery(fileFd: string) {
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

  // 拆出来的方法
  getSpeedText(): string {
    let speed = '普通档'
    if (this.speed === 1) {
      speed = '普通档'
    } else if (this.speed === 2) {
      speed = '高速档'
    }
    if (this.speed === 3) {
      speed = '运动档'
    }
    return speed;
  }

  getCameraMode(): Resource {
    let mode = $r('app.media.ic_control_camera_mode');
    if (this.shutMode === ShootingType.PHOTO) {
      mode = $r('app.media.ic_camera_mode_photo')
    } else if (this.shutMode === ShootingType.RECORD) {
      mode = $r('app.media.ic_camera_mode_video')
    } else if (this.shutMode === ShootingType.DELAY) {
      mode = $r('app.media.ic_camera_mode_time_lapse_photography')
    } else if (this.shutMode === ShootingType.PANORAMA) {
      mode = $r('app.media.ic_camera_mode_all_picture')
    }
    return mode
  }
}


/**
 * 延时函数（毫秒）
 */
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
