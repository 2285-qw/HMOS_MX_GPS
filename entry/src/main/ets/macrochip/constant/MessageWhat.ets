export class MessageWhat {
  public static MESSAGE_HORIZONTAL_CALIBRATION: number = 60000; //水平校准
  public static MESSAGE_GUIDE_CALIBRATION: number = 60001; //指南校准
  public static MESSAGE_LOCATION: number = 60002; //手机位置信息
  public static MESSAGE_PLANE_LOCATION: number = 60003; //飞机位置信息
  public static MESSAGE_PHONE_ROTATION_ANGLE: number = 60004; //手机旋转角度
  public static MESSAGE_PHOTOS: number = 60005; //拍照
  public static MESSAGE_WAYPOINT: number = 60006; //航点数据
  /* 网格选择 辅助线 */
  public static MESSAGE_AUXILIARY_CROSS: number = 60007;
  public static MESSAGE_AUXILIARY_WELL: number = 60008;
  public static MESSAGE_AUXILIARY_PLUS_SIGN: number = 60009;
  public static MESSAGE_UNIT: number = 60009; //单位切换
  public static MESSAGE_ZOOM: number = 60010; //变焦
}