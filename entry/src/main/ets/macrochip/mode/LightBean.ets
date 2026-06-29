// LightBean.ets
/**
 * 灯光参数实体类
 */
@Observed
export class LightBean {
  /** 0单色，1双色，2三色，3七色 */
  lightType1: number = 0;
  /** 高4位 0静态，1跳变，2渐变，3频闪，4流水，5其他 */
  lightType2: number = 0;
  /** 灯颜色，R-红 */
  readN: number = 0;
  /** 灯颜色，G-绿 */
  greenN: number = 0;
  /** 灯颜色，B-蓝 */
  blueN: number = 0;

  constructor(lightType1?: number, lightType2?: number, readN?: number, greenN?: number, blueN?: number) {
    if (lightType1 !== undefined) this.lightType1 = lightType1;
    if (lightType2 !== undefined) this.lightType2 = lightType2;
    if (readN !== undefined) this.readN = readN;
    if (greenN !== undefined) this.greenN = greenN;
    if (blueN !== undefined) this.blueN = blueN;
  }
}