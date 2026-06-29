import { DatabaseManager } from '../database/DatabaseManager';
import { FlyInfo } from '../database/FlyInfo';
import { PreferencesUtil } from '../macrochip/utils/PreferencesUtil';
import { RouteHelper } from '../macrochip/utils/RouteHelper';
import { TransformationUtils } from '../utils/TransformationUtils';

@Entry
@Component
struct FlightPage {
  @State message: string = '飞行记录';
  @State flyInfo?: FlyInfo[] = undefined;
  @State unit: number = 0 //0英制mph 1公制m/s 2公制km/h

  build() {
    Column() {
      RelativeContainer() {

        Image($r('app.media.icon_back'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.CENTER)

          .margin({ left: 20 })
          .onClick(() => {
            RouteHelper.back()
          })

        Text(this.message)
          .id('FlightPageHelloWorld')
          .fontColor(Color.White)
          .fontSize(16)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .height(30)
      .width('100%')


      Row() {
        Row() {
          Image($r('app.media.img_date')).width(15).height(15)
          Text('日期').fontColor(Color.White).fontSize(10)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中
        Row() {
          Image($r('app.media.img_distance')).width(15).height(15)
          Text('距离').fontColor(Color.White).fontSize(10)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中
        Row() {
          Image($r('app.media.img_duration')).width(15).height(15)
          Text('时长').fontColor(Color.White).fontSize(10)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中
        Row() {
          Image($r('app.media.img_altitude')).width(15).height(15)
          Text('最大高度').fontColor(Color.White).fontSize(10)
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中

      }.height(30)
      .backgroundColor('#9197a3')
      .width('100%')
      .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中

      // 2. 创建 List 容器
      List({ space: 10 }) { // space 属性用于设置列表项之间的间距[reference:6]
        // 3. 使用 ForEach 循环渲染 ListItem
        ForEach(this.flyInfo, (item: FlyInfo) => {
          ListItem() {
            // 4. 创建 ListItem 内容
            Row() {
              Text(item.logDate).fontColor(Color.White).fontSize(10).layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text(this.unit==0?`${TransformationUtils.toMPH(item.maxDistance)} ft`:`${item.maxDistance} m`).fontColor(Color.White).fontSize(10).layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text(`${item.flightDuration / 60} min`).fontColor(Color.White).fontSize(10).layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text(this.unit==0?`${TransformationUtils.toMPH(item.maxAltitude)} ft`:`${item.maxAltitude} m`).fontColor(Color.White).fontSize(10).layoutWeight(1)
                .textAlign(TextAlign.Center)

            }.layoutWeight(1)
            .justifyContent(FlexAlign.Center) // 子组件在水平方向上居中

          }
        }, (item: string) => item) // 为每个列表项提供唯一键值
      }
      .width('100%')
      .height('100%') // 让 List 占满父容器，以启用滚动


    }.height('100%')
    .width('100%')
    .backgroundColor(Color.Black)

  }

  aboutToAppear(): void {
    DatabaseManager.getInstance().queryAllFlyInfos().then((flyInfo: FlyInfo[]) => {
      this.flyInfo = flyInfo
    })

    this.unit = PreferencesUtil.getData(PreferencesUtil.UNIT, 0) as number;

  }
}