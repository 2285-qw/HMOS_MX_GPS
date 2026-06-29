import { FlyDetailInfo } from './FlyDetailInfo';
import { util } from '@kit.ArkTS';

/**
 * 飞行记录主表实体类（对应数据库表 fly_info）
 * 存储一次飞行的整体概要信息，与 FlyDetailInfo 构成一对多关系
 *
 * 主表记录飞行开始/结束时间、最大指标、位置等；详情表记录每秒的遥测数据
 */
@Observed
export class FlyInfo {
  // ==================== 数据库主键 ====================
  /** 自增主键（数据库自动生成），插入后由数据库赋值 */
  id?: number;

  // ==================== 基础信息 ====================
  /** 无人机型号（例如：1-精灵系列，2-御系列等，根据业务定义） */
  droneType: number = 0;

  /** 飞行所在城市/地区（通过逆地理编码获取，可为空） */
  address: string = '';

  // ==================== 飞行指标（最大值） ====================
  /** 本次飞行的最大水平速度（米/秒） */
  maxSpeed: number = 0;

  /** 本次飞行的最大水平距离（米，相对于起飞点） */
  maxDistance: number = 0;

  /** 本次飞行的最大高度（米，相对于起飞点） */
  maxAltitude: number = 0;

  /** 飞行总时长（秒），由开始和结束时间戳计算得出 */
  flightDuration: number = 0;

  // ==================== 关联与时间 ====================
  /**
   * 关联详情表的 UUID（唯一标识符）
   * 主表与详情表通过此字段建立一对多关系，同一 UUID 对应多条详情记录
   * 在构造函数中自动生成
   */
  detail_id: string = '';

  /** 飞行开始时间（格式：yyyy-MM-dd HH:mm:ss） */
  logDate: string = '';

  // ==================== 业务关联（非持久化） ====================
  /**
   * 详情列表（业务层使用，不存储在数据库中）
   * 用于在内存中装载该次飞行对应的所有详情数据
   * 查询时可手动填充此数组，方便UI展示
   */
  detailList: FlyDetailInfo[] = [];

  /**
   * 构造函数：自动生成符合 RFC 4122 标准的 UUID 作为 detail_id
   */
  constructor() {
    this.detail_id = util.generateRandomUUID(true);
  }
}