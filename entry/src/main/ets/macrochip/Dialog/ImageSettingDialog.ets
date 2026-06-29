import { ImageSettingData, ImageSettingParams } from "./DialogDataType/ImageSettingParams";


@Builder
export function ImageSettingDialog(params: ImageSettingParams) {
  Column() {
    Text('重置所有参数')
      .fontColor(Color.White)
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })
      .backgroundColor('#909497')
      .fontSize(12)
      .onClick(() => {
        params.WB = 0
        params.CT = 50
        params.ST = 50
        params.SP = 50
        params.dialogId?.update(params)
        ImageSettingParams.setWb(ImageSettingParams.to100ToMax(0, 255))
        ImageSettingParams.setContrast(ImageSettingParams.to100ToMax(50, 1023))
        ImageSettingParams.setSaturation(ImageSettingParams.to100ToMax(50, 255))
        ImageSettingParams.setSharpen(ImageSettingParams.to100ToMax(50, 255))
      })
    Row() {
      Text('白平衡').fontColor(Color.White).constraintSize({ minWidth: 70 }).fontSize(10)
      Slider({
        value: params.WB,
        min: params.minP,
        max: params.maxP,
        step: 1
      })
        .height(30)
        .padding(0)
        //.enabled(!this.data.isBeginnerMode)
        .width(180)
        .trackColor('#909497')
        .selectedColor('#ffffff')
        .onChange((value: number) => {
          params.WB = value;
          if (params.onItemClick) {
            params.onItemClick(value, ImageSettingData.WB)
          }
          ImageSettingParams.setWb(ImageSettingParams.to100ToMax(value, 255))

        })
      Text('' + params.WB)
        .fontColor(Color.White)
        .constraintSize({ minWidth: 30 })
        .fontSize(10)
        .textAlign(TextAlign.Center)
    }

    Row() {
      Text('对比度').fontColor(Color.White).constraintSize({ minWidth: 70 }).fontSize(10)
      Slider({
        value: params.CT,
        min: params.minP,
        max: params.maxP,
        step: 1
      })
        .height(30)
        //.enabled(!this.data.isBeginnerMode)
        .width(180)
        .trackColor('#909497')
        .selectedColor('#ffffff')
        .onChange((value: number) => {
          params.CT = value;
          if (params.onItemClick) {
            params.onItemClick(value, ImageSettingData.CT)
          }
          ImageSettingParams.setContrast(ImageSettingParams.to100ToMax(value, 1023))
        })
      Text('' + params.CT)
        .fontColor(Color.White)
        .constraintSize({ minWidth: 30 })
        .fontSize(10)
        .textAlign(TextAlign.Center)
    }

    Row() {
      Text('饱和度').fontColor(Color.White).constraintSize({ minWidth: 70 }).fontSize(10)
      Slider({
        value: params.ST,
        min: params.minP,
        max: params.maxP,
        step: 1
      })
        .height(30)
        //.enabled(!this.data.isBeginnerMode)
        .width(180)
        .trackColor('#909497')
        .selectedColor('#ffffff')
        .onChange((value: number) => {
          params.ST = value;
          if (params.onItemClick) {
            params.onItemClick(value, ImageSettingData.ST)
          }
          ImageSettingParams.setSaturation(ImageSettingParams.to100ToMax(value, 255))
        })
      Text('' + params.ST)
        .fontColor(Color.White)
        .constraintSize({ minWidth: 30 })
        .fontSize(10)
        .textAlign(TextAlign.Center)
    }

    Row() {
      Text('锐度').fontColor(Color.White).constraintSize({ minWidth: 70 }).fontSize(10)
      Slider({
        value: params.SP,
        min: params.minP,
        max: params.maxP,
        step: 1
      })
        .height(30)
        //.enabled(!this.data.isBeginnerMode)
        .width(180)
        .trackColor('#909497')
        .selectedColor('#ffffff')
        .onChange((value: number) => {
          params.SP = value;
          if (params.onItemClick) {
            params.onItemClick(value, ImageSettingData.SP)
          }
          ImageSettingParams.setSharpen(ImageSettingParams.to100ToMax(value, 255))
        })
      Text('' + params.SP)
        .fontColor(Color.White)
        .constraintSize({ minWidth: 30 })
        .fontSize(10)
        .textAlign(TextAlign.Center)
    }

  }
  .width(296)
  .borderRadius(5)
  .backgroundColor('#90181818')
  .alignItems(HorizontalAlign.Center) // 内部图片和文字居中
  .outlineRadius(20)
  .padding(8)
}