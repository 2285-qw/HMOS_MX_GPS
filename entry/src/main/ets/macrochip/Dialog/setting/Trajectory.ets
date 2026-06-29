import { RouteHelper } from "../../utils/RouteHelper"

/**
 * 设置页面组件
 */
@Entry
@Component
export struct Trajectory {
  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text('总飞行时间').fontColor('#ffb0b1b6').fontSize(12)
          Text('0.0min').fontColor('#ffffffff').fontSize(12)
        }.layoutWeight(1)

        Column({ space: 2 }) {
          Text('总飞行距离').fontColor('#ffb0b1b6').fontSize(12)
          Text('0.0m').fontColor('#ffffffff').fontSize(12)
        }.layoutWeight(1)

        Column({ space: 2 }) {
          Text('总飞行次数').fontColor('#ffb0b1b6').fontSize(12)
          Text('0').fontColor('#ffffffff').fontSize(12)
        }.layoutWeight(1)

      }

      Line().width('90%').height(1).backgroundColor('#ffffff').margin({ top: 5 })

      Row() {
        Text('足迹').fontColor('#ffffffff').fontSize(14).layoutWeight(1)
        Text('到访0个地区').fontColor('#ffb0b1b6').fontSize(12).layoutWeight(1)
        Text('最高海拔').fontColor('#ffffffff').fontSize(14).layoutWeight(1)
        Text('0.0m').fontColor('#ffffffff').fontSize(12).layoutWeight(1)
      }.margin({ top: 20 }).width('80%')

      Row() {
        Text('最长里程').fontColor('#ffffffff').fontSize(14).layoutWeight(1)
        Text('0.0m').fontColor('#ffffffff').fontSize(12).layoutWeight(1)
        Text('最大速度').fontColor('#ffffffff').fontSize(14).layoutWeight(1)
        Text('0.0m/s').fontColor('#ffffffff').fontSize(12).layoutWeight(1)
      }.margin({ top: 10 }).width('80%')

      Text('全部飞行记录')
        .width('80%')
        .height(30)
        .backgroundColor('#ffb0b1b6')
        .fontColor('#ffffffff')
        .margin({ top: 40 })
        .textAlign(TextAlign.Center) // 文本水平居中
        .onClick(() => {
          RouteHelper.pushUrl('pages/FlightPage');
        })

      Text('找飞机')
        .width('80%')
        .height(30)
        .backgroundColor('#ffb0b1b6')
        .fontColor('#ffffffff')
        .margin({ top: 10 })
        .textAlign(TextAlign.Center)
        .onClick(() => {
          RouteHelper.pushUrl('pages/SeekPlanePage');
        })

      Text('日志')
        .width('80%')
        .height(30)
        .backgroundColor('#ffb0b1b6')
        .fontColor('#ffffffff')
        .margin({ top: 10 })
        .textAlign(TextAlign.Center) // 文本水平居中
        .onClick(() => {
          RouteHelper.pushUrl('pages/LogListPage');
        })


    }.width('100%').height('100%').background('#ff0c0c0c')

  }
}