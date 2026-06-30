import { SlideUnLockView } from "../components/SlideUnLockView";
import { Params, Type } from "./DialogDataType/Params";
import { TLPSpeedParams } from "./DialogDataType/TLPSpeedParams";
import { util } from "@kit.ArkTS";
import { Utils } from "../utils/Utils";


@Builder
export function TLPSpeedDialog(tLPSpeedParams: TLPSpeedParams) {

  Column() {
    // 第一行：左侧“4X”、中间当前值、右侧“50X”
    Row() {
      Text('4X')
        .fontSize(12)
        .fontColor(Color.White)
        .width(40) // 固定宽度占位，保持左右对称
        .textAlign(TextAlign.Start)

      Text(`${tLPSpeedParams.speed}X`)
        .fontSize(16)
        .margin({ bottom: 8 }) // 与 Slider 的间距
        .fontColor($r('app.color.main_brand_color')) // 对应 colorAccent
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('50X')
        .fontSize(12)
        .fontColor(Color.White)
        .width(40)
        .textAlign(TextAlign.End)
    }
    .width(200)


    // 第二行：滑动条
    Stack() {
      Image($r('app.media.img_tlp_seekbar_bg'))
        .width('90%')
        .height('20%')
        .objectFit(ImageFit.Fill) // 填满
      Slider({
        value: tLPSpeedParams.speed,
        min: tLPSpeedParams.minValue,
        max: tLPSpeedParams.maxValue,
        step: 1
      })
        .width(200) // 固定宽度，与原 SeekBar 一致
        .height(20) // 适当高度
        .clip(true)  // 裁剪溢出内容
        .trackColor(Color.Transparent) // 背景轨道颜色（可自定义）
        // .backgroundImage($r('app.media.img_tlp_seekbar_bg'))
        .backgroundImagePosition(Alignment.Center)
        .backgroundImageSize(ImageSize.Contain)
        .backgroundImagePosition({ x: 0, y: 0 })   // 向左偏移5px，使左右均匀内收
        .selectedColor(Color.Transparent) // 已选颜色
        //.blockColor('#FFFFFF') // 滑块颜色（若无自定义图片）
        .blockStyle({
          type: SliderBlockType.IMAGE,
          image: $r('app.media.img_tlp_seekbar_thumb')
        })
        .blockSize({ width: 10, height: 20 })
        //.blockImage($r('app.media.img_tlp_seekbar_thumb'))
        .onChange((value: number) => {
          tLPSpeedParams.speed = value;
          tLPSpeedParams.dialogId?.update(tLPSpeedParams)
          if (tLPSpeedParams.onSpeedClick) {
            tLPSpeedParams.onSpeedClick(value)
          }
          Utils.setVibration()
        })

    }.width(200)
    .height(20).margin({ bottom: 10, top: -8 }) // 与确认按钮的间距


    // 第三行：确认按钮
    Button('确认') // 或直接写 '确认'
      .width('100%')
      .height(30)
      .backgroundColor('#ff212121') // 自定义按钮背景，可替换为 draw_tlp_confirm_bg 的样式
      .borderRadius(4)
      .fontColor(Color.White)
      .fontSize(14)
      .onClick(() => {
        // 确认逻辑
        console.info('确认，当前值：' + tLPSpeedParams.speed);
        tLPSpeedParams.uiContext?.getPromptAction().closeCustomDialog(tLPSpeedParams.dialogId)
      })
  }
  .width(250) // wrap_content
  .height('auto')
  .padding({ top: 16 })
  .backgroundColor('#702d2d2d') // 假设背景色，对应 draw_camera_mode_bg
  .borderRadius(8) // 若背景有圆角
  .alignItems(HorizontalAlign.Center) // 子组件水平居中
}