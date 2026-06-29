import { SlideUnLockView } from "../components/SlideUnLockView";
import { MoreBean } from "../More/MoreBean";
import { MoreParams } from "./DialogDataType/MoreParams";
import { MoreType } from "../More/MoreType";
import { Params, Type } from "./DialogDataType/Params";
import { ObjectUtils } from "../../utils/ObjectUtils";


@Builder
export function buildLeftMore(params: MoreParams) {
  Column() {
    List() {
      ForEach(params.arrMoreBean, (item: MoreBean, index: number) => {
        ListItem() {
          Column({ space: 4 }) {
            Image(item.getIcon())
              .width(30)
              .height(30)
              .colorFilter(item.isSelected() ? ObjectUtils.hexToColorMatrix('#ff008ff4') : undefined)
              .objectFit(ImageFit.CENTER)
            Text(item.getText())
              .fontSize(10)
              .fontColor(item.isSelected() ? '#ff008ff4' : '#faffffff')

          }.margin(5).onClick(() => {
            // onItemClick(item.getType());
            if (params.onItemClick) {
              params.onItemClick(index);
            }
          })
        }
      }, (item: MoreBean) => item.id)
    }
    .lanes(6) // 设置每行最大列数
    .alignListItem(ListItemAlign.Center) // 居中对齐
  }
  .borderRadius(10)
  .backgroundColor('#7c0f0f11')
  .outlineRadius(20)
  .padding({
    left: 10,
    right: 10,
    top: 10,
    bottom: 10
  })
  .width(320)
}