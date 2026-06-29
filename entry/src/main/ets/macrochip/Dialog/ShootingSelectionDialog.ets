import { SlideUnLockView } from "../components/SlideUnLockView";
import { ShootingSelectionParams, ShootingType } from "./DialogDataType/ShootingSelectionParams";


@Builder
export function buildShootingSelectionDialog(params: ShootingSelectionParams) {
  Column({ space: 4 }) {
    Column() {
      Image($r('app.media.ic_camera_mode_photo')).objectFit(ImageFit.ScaleDown).width(30).height(30)
      Text('拍照').fontColor(Color.White).fontSize(8).textAlign(TextAlign.Center) // 🔑 关键：让文字在Text组件内水平居中
    }
    .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
    .onClick(() => {
      if (params.onItemClick) {
        params.onItemClick(ShootingType.PHOTO)
      }
      params.uiContext?.getPromptAction().closeCustomDialog(params.dialogId)

    })

    Column() {
      Image($r('app.media.ic_camera_mode_video')).objectFit(ImageFit.ScaleDown).width(30).height(30)
      Text('录像').fontColor(Color.White).fontSize(8).textAlign(TextAlign.Center) // 🔑 关键：让文字在Text组件内水平居中
    }
    .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
    .onClick(() => {
      if (params.onItemClick) {
        params.onItemClick(ShootingType.RECORD)
      }
      params.uiContext?.getPromptAction().closeCustomDialog(params.dialogId)
    })

    Column() {
      Image($r('app.media.ic_camera_mode_time_lapse_photography')).objectFit(ImageFit.ScaleDown).width(30).height(30)
      Text('延时摄像')
        .fontColor(Color.White)
        .fontSize(8)
        .textAlign(TextAlign.Center) // 🔑 关键：让文字在Text组件内水平居中
    }
    .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
    .onClick(() => {
      if (params.onItemClick) {
        params.onItemClick(ShootingType.DELAY)
      }
      params.uiContext?.getPromptAction().closeCustomDialog(params.dialogId)
    })

    Column() {
      Image($r('app.media.ic_camera_mode_all_picture')).objectFit(ImageFit.ScaleDown).width(30).height(30)
      Text('全景拍摄')
        .fontColor(Color.White)
        .fontSize(8)

        .textAlign(TextAlign.Center) // 🔑 关键：让文字在Text组件内水平居中
    }
    .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
    .onClick(() => {
      if (params.onItemClick) {
        params.onItemClick(ShootingType.PANORAMA)
      }
      params.uiContext?.getPromptAction().closeCustomDialog(params.dialogId)
    })

  }
  .borderRadius(5)
  .backgroundColor('#a03f3a39')
  .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
  .outlineRadius(20)
  .padding(8)

}