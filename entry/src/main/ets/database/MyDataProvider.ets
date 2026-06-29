// MyDataProvider.ets
import { FlyData, FlyDataProvider } from "./FlightRecordUtils";


@Observed
export class MyDataProvider implements FlyDataProvider {
  // 这些变量应该由你的设备通信模块（UDP/蓝牙）实时更新
  /**
   * 飞行实时数据类（或 MyDataProvider 中的数据字段）
   * 这些值由 UDP/蓝牙等外部设备实时更新
   */

  // ==================== 摇杆数据 ====================
  /** 摇杆 - 上升（左摇杆上下） */
  public rockerUp: number = 0;
  /** 摇杆 - 下降（左摇杆上下） */
  public rockerDown: number = 0;
  /** 摇杆 - 向右旋转（左摇杆左右） */
  public rockerRightRotate: number = 0;
  /** 摇杆 - 向左旋转（左摇杆左右） */
  public rockerLeftRotate: number = 0;
  /** 摇杆 - 前进（右摇杆上下） */
  public rockerFont: number = 0;
  /** 摇杆 - 后退（右摇杆上下） */
  public rockerBack: number = 0;
  /** 摇杆 - 向右飞行（右摇杆左右） */
  public rockerRight: number = 0;
  /** 摇杆 - 向左飞行（右摇杆左右） */
  public rockerLeft: number = 0;

  // ==================== 飞行状态 ====================
  /** 当前高度（米） */
  public height: number = 0;
  /** 水平速度（米/秒） */
  public horizontalSpeed: number = 0;
  /** 飞行距离（米），通常指从起点到当前位置的直线距离 */
  public distance: number = 0;
  /** 垂直速度（米/秒），正值为上升，负值为下降 */
  public verticalSpeed: number = 0;

  // ==================== 定位与姿态 ====================
  /** 经度（度） */
  public nowPlaneLon: number = 0;
  /** 纬度（度） */
  public nowPlaneLat: number = 0;
  /** 飞机朝向角度（度），0°为正北，顺时针增加 */
  public nowPlaneAngle: number = 0;

  getFlyData(): FlyData {
    // 直接返回当前属性快照
    return {
      rockerUp: this.rockerUp,
      rockerDown: this.rockerDown,
      rockerRightRotate: this.rockerRightRotate,
      rockerLeftRotate: this.rockerLeftRotate,
      rockerFont: this.rockerFont,
      rockerBack: this.rockerBack,
      rockerRight: this.rockerRight,
      rockerLeft: this.rockerLeft,
      height: this.height,
      horizontalSpeed: this.horizontalSpeed,
      distance: this.distance,
      verticalSpeed: this.verticalSpeed,
      nowPlaneLon: this.nowPlaneLon,
      nowPlaneLat: this.nowPlaneLat,
      nowPlaneAngle: this.nowPlaneAngle
    };
  }
}