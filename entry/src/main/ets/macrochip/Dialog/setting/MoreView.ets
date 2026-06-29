import { RouteHelper } from "../../utils/RouteHelper"
import App from "@system.app";
import { Utils } from "../../utils/Utils";
import { SendEmitterUtil } from "../../../utils/SendEmitterUtil";
import { MessageWhat } from "../../constant/MessageWhat";
import { ConnectConfig } from "../../../utils/ConnectConfig";
import { PreferencesUtil } from "../../utils/PreferencesUtil";

/**
 * 设置页面组件
 */
@Entry
@Component
export struct MoreView {
  @State unit: number = 0 //0英制mph 1公制m/s 2公制km/h
  @State DisplayRoute: boolean = true; //显示航线
  @State DisplayInformation: boolean = true; //显示提示信息
  @State VoicePrompt: boolean = true; //语音提示
  @State isCross: boolean = ConnectConfig.IS_CROSS;
  @State isPlusSign: boolean = ConnectConfig.IS_PLUS_SIGN;
  @State isWell: boolean = ConnectConfig.IS_WELL;

  build() {
    Column() {
      Row() {
        Text('单位').fontSize(14).fontColor('#ffffff').width(150)
        Text('英制(MPH)')
          .fontSize(14)
          .fontColor(this.unit === 0 ? $r('app.color.main_brand_color') : $r('app.color.white'))
          .padding({ left: 8, right: 8 })
          .border({ width: 1, color: this.unit === 0 ? $r('app.color.main_brand_color') : $r('app.color.white') })
          .onClick(() => {
            this.unit = 0
            PreferencesUtil.saveData(PreferencesUtil.UNIT, this.unit);
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_UNIT)
          })
        Text('公制(m/s)')
          .fontSize(14)
          .fontColor(this.unit === 1 ? $r('app.color.main_brand_color') : $r('app.color.white'))
          .padding({ left: 8, right: 8 })
          .border({ width: 1, color: this.unit === 1 ? $r('app.color.main_brand_color') : $r('app.color.white') })
          .margin({ left: 15 })
          .onClick(() => {
            this.unit = 1
            PreferencesUtil.saveData(PreferencesUtil.UNIT, this.unit);
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_UNIT)
          })
        Text('公制(km/s)')
          .fontSize(14)
          .fontColor(this.unit === 2 ? $r('app.color.main_brand_color') : $r('app.color.white'))
          .padding({ left: 8, right: 8 })
          .border({ width: 1, color: this.unit === 2 ? $r('app.color.main_brand_color') : $r('app.color.white') })
          .margin({ left: 15 })
          .onClick(() => {
            this.unit = 2
            PreferencesUtil.saveData(PreferencesUtil.UNIT, this.unit);
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_UNIT)
          })

      }

      Row() {
        Text('显示航线').fontSize(14).fontColor('#ffffff').width(150)

        // 1. 创建 Toggle 组件，并绑定状态
        Toggle({ type: ToggleType.Switch, isOn: this.DisplayRoute })
          .selectedColor('#59B3F9')   // 设置选中时的背景色
          .switchPointColor('#FFFFFF') // 设置滑块颜色
          .onChange((isOn: boolean) => { // 2. 监听状态变化
            this.DisplayRoute = isOn;
            console.log(`Switch is now: ${isOn ? 'ON' : 'OFF'}`);
            // 在这里执行相应的业务逻辑，比如开启/关闭某个功能
          })
      }.margin({ top: 15 })

      Row() {
        Text('显示提示信息').fontSize(14).fontColor('#ffffff').width(150)

        // 1. 创建 Toggle 组件，并绑定状态
        Toggle({ type: ToggleType.Switch, isOn: this.DisplayInformation })
          .selectedColor('#59B3F9')   // 设置选中时的背景色
          .switchPointColor('#FFFFFF') // 设置滑块颜色
          .onChange((isOn: boolean) => { // 2. 监听状态变化
            this.DisplayInformation = isOn;
            console.log(`Switch is now: ${isOn ? 'ON' : 'OFF'}`);
            // 在这里执行相应的业务逻辑，比如开启/关闭某个功能
          })
      }.margin({ top: 15 })

      Row() {
        Text('语言提示').fontSize(14).fontColor('#ffffff').width(150)
        // 1. 创建 Toggle 组件，并绑定状态
        Toggle({ type: ToggleType.Switch, isOn: this.VoicePrompt })
          .selectedColor('#59B3F9')   // 设置选中时的背景色
          .switchPointColor('#FFFFFF') // 设置滑块颜色
          .onChange((isOn: boolean) => { // 2. 监听状态变化
            this.VoicePrompt = isOn;
            console.log(`Switch is now: ${isOn ? 'ON' : 'OFF'}`);
            // 在这里执行相应的业务逻辑，比如开启/关闭某个功能
          })
      }.margin({ top: 15 })


      Row() {
        Text('辅助线').fontSize(14).fontColor('#ffffff').width(150)
        Image(this.isCross ? $r('app.media.ic_cross_press') : $r('app.media.ic_cross'))
          .width(80)
          .height(60)
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.isCross = !this.isCross
            ConnectConfig.IS_CROSS = this.isCross
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_AUXILIARY_CROSS)
          })
        Image(this.isWell ? $r('app.media.ic_well_press') : $r('app.media.ic_well'))
          .width(80)
          .height(60)
          .objectFit(ImageFit.Fill)
          .margin({ left: 10 })
          .onClick(() => {
            this.isWell = !this.isWell
            ConnectConfig.IS_WELL = this.isWell
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_AUXILIARY_WELL)
          })
        Image(this.isPlusSign ? $r('app.media.ic_plus_sign_press') : $r('app.media.ic_plus_sign'))
          .width(80)
          .height(60)
          .objectFit(ImageFit.Fill)
          .margin({ left: 10 })
          .onClick(() => {
            this.isPlusSign = !this.isPlusSign
            ConnectConfig.IS_PLUS_SIGN = this.isPlusSign
            SendEmitterUtil.sendEventObject(MessageWhat.MESSAGE_AUXILIARY_PLUS_SIGN)
          })

      }.margin({ top: 20 })

    }
    .width('100%')
    .height('100%')
    .background('#ff080808')
    .alignItems(HorizontalAlign.Start) // 设置交叉轴（水平）对齐方式为靠左
    .padding({ left: 10 })

  }

  aboutToAppear(): void {
    this.unit = PreferencesUtil.getData(PreferencesUtil.UNIT, 0) as number;
  }
}