import EntryAbility from "../../../entryability/EntryAbility";
import { BaseParams } from "./BaseParams";


export class ImageSettingParams extends BaseParams {
  onItemClick?: (num: number, imageSettingData: ImageSettingData) => void
  WB: number = 0 //白平衡
  CT: number = 50 //对比度
  ST: number = 50 //饱和度
  SP: number = 50 //锐度
  minP = 0;
  maxP = 100

  constructor(uiContext?: UIContext) {
    super();
    this.uiContext = uiContext;
  }

  setonItemClick(onItemClick?: (num: number, imageSettingData: ImageSettingData) => void) {
    this.onItemClick = onItemClick
  }


  public static setWb(wbattr_value: number): void {
    const bytes = new Uint8Array(7);
    bytes[0] = 0xff;
    bytes[1] = 83;
    bytes[2] = 84;
    bytes[3] = 116;
    bytes[4] = 1;
    bytes[5] = (wbattr_value >> 8) & 0xff;
    bytes[6] = wbattr_value & 0xff;
    EntryAbility.getInstance().sendUDPCmd(bytes);
  }

  public static setContrast(DRCAttr_value: number): void {
    const bytes = new Uint8Array(7);
    bytes[0] = 0xff;
    bytes[1] = 83;
    bytes[2] = 84;
    bytes[3] = 112;
    bytes[4] = 1;
    bytes[5] = (DRCAttr_value >> 8) & 0xff;
    bytes[6] = DRCAttr_value & 0xff;
    EntryAbility.getInstance().sendUDPCmd(bytes);
  }

  public static setSaturation(saturation: number): void {
    const bytes = new Uint8Array(6);
    bytes[0] = 0xff;
    bytes[1] = 83;
    bytes[2] = 84;
    bytes[3] = 114;
    bytes[4] = 1;
    bytes[5] = saturation & 0xff; // 因为只放一个字节，所以直接取低8位
    EntryAbility.getInstance().sendUDPCmd(bytes);
  }

  public static setSharpen(sharpen: number): void {
    const bytes = new Uint8Array(7);
    bytes[0] = 0xff;
    bytes[1] = 83;
    bytes[2] = 84;
    bytes[3] = 113;
    bytes[4] = 1;
    bytes[5] = (sharpen >> 8) & 0xff;
    bytes[6] = sharpen & 0xff;
    EntryAbility.getInstance().sendUDPCmd(bytes);
  }

  public static setThermalImaging(type: number) {
    const bytes = new Uint8Array(5);
    bytes[0] = 0xff;
    bytes[1] = 83;
    bytes[2] = 84;
    bytes[3] = 115;
    bytes[4] =type & 0xff;
    EntryAbility.getInstance().sendUDPCmd(bytes);
  }

  public static to100ToMax(original: number, max: number): number {
    const clamped = Math.max(0, Math.min(original, 100));
    const ratio = clamped / 100.0;
    return Math.round(ratio * max);
  }
}


export enum ImageSettingData {
  WB, //白平衡
  CT, //对比度
  ST, //饱和度
  SP //锐度
}