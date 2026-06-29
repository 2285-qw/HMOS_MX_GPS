// FlyDetailInfo.ets
@Observed
export class FlyDetailInfo {
  id?: number;
  detail_id: string = '';   // 关联主表的 detail_id

  left: number = 0;
  right: number = 0;
  font: number = 0;
  back: number = 0;
  up: number = 0;
  down: number = 0;
  rightRotate: number = 0;
  lefrRotate: number = 0;    // 注意原Java拼写有误，但保留

  h: number = 0;   // 高度
  hs: number = 0;  // 垂直速度
  d: number = 0;   // 距离
  vs: number = 0;  // 水平速度
  lon: number = 0; // 经度
  lat: number = 0; // 纬度
  angle: number = 0;

  constructor() {
    // 可选构造函数
  }
}