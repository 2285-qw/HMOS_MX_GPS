import { SlideUnLockView } from "../components/SlideUnLockView";
import { Params, Type } from "./DialogDataType/Params";


@Builder
export function buildTLPSpeed(params: Params) {
  Column() {

  }
  .borderRadius(15)
  .backgroundColor('#90000000')
  .outlineRadius(20)
  .padding({
    left: 30,
    right: 30,
    top: 20,
    bottom: 20
  })
  .width(320)
}