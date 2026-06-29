import { DatabaseManager } from './DatabaseManager';
import { FlyInfo } from './FlyInfo';
import { FlyDetailInfo } from './FlyDetailInfo';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

const TAG = 'FlightRecordUtils';
const DOMAIN = 0x0001;

export interface FlyData {
  rockerUp: number;
  rockerDown: number;
  rockerRightRotate: number;
  rockerLeftRotate: number;
  rockerFont: number;
  rockerBack: number;
  rockerRight: number;
  rockerLeft: number;
  height: number;
  horizontalSpeed: number;
  distance: number;
  verticalSpeed: number;
  nowPlaneLon: number;
  nowPlaneLat: number;
  nowPlaneAngle: number;
}
/**
 * 数据提供者接口，用于获取当前飞行数据
 */
export interface FlyDataProvider {
  getFlyData(): FlyData;
}

export class FlightRecordUtils {
  private dataProvider: () => FlyData;
  private timerId: number | undefined;
  private detailList: FlyDetailInfo[] = [];
  private flyInfo: FlyInfo | null = null;
  private flyTime: number = 0;
  private context: Context;
  private dbManager: DatabaseManager;

  constructor(context: Context, dataProvider: () => FlyData) {
    this.context = context;
    this.dataProvider = dataProvider;
    this.dbManager = DatabaseManager.getInstance();
    // 确保数据库已初始化
    this.dbManager.init(context).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, '数据库初始化失败: %{public}s', JSON.stringify(err));
    });
  }


  public setDataProvider(dataProvider: () => FlyData){
    this.dataProvider = dataProvider;
  }
  public start(): void {
    this.flyInfo = new FlyInfo();
    this.flyInfo.droneType = 0; // 需要获取无人机型号，可从外部传入或全局设置，暂时默认0
    this.detailList = [];
    this.flyTime = Date.now();

    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }

    // 每秒记录一次
    this.timerId = setInterval(() => {
      this.recordDetail();
    }, 1000);
    hilog.info(DOMAIN, TAG, '飞行记录已开始');
  }

  private recordDetail(): void {
    if (!this.flyInfo) {
      return;
    }
    const data = this.dataProvider();
    // 构造详情对象
    const detail = new FlyDetailInfo();
    detail.detail_id = this.flyInfo.detail_id;
    detail.up = data.rockerUp;
    detail.down = data.rockerDown;
    detail.rightRotate = data.rockerRightRotate;
    detail.lefrRotate = data.rockerLeftRotate;
    detail.font = data.rockerFont;
    detail.back = data.rockerBack;
    detail.right = data.rockerRight;
    detail.left = data.rockerLeft;
    detail.h = data.height;
    detail.hs = data.horizontalSpeed;
    detail.d = data.distance;
    detail.vs = data.verticalSpeed;
    detail.lon = data.nowPlaneLon;
    detail.lat = data.nowPlaneLat;
    detail.angle = data.nowPlaneAngle;

    // 更新最大值
    if (this.flyInfo.maxAltitude < data.height) {
      this.flyInfo.maxAltitude = data.height;
    }
    if (this.flyInfo.maxDistance < data.distance) {
      this.flyInfo.maxDistance = data.distance;
    }
    if (this.flyInfo.maxSpeed < data.horizontalSpeed) {
      this.flyInfo.maxSpeed = data.horizontalSpeed;
    }

    // 设置日期
    if (!this.flyInfo.logDate) {
      const now = new Date();
      const formatter = new Intl.DateTimeFormat('zh-CN', {
        year: 'numeric', month: '2-digit', day: '2-digit',
        hour: '2-digit', minute: '2-digit', second: '2-digit',
        hour12: false
      });
      this.flyInfo.logDate = formatter.format(now);
    }

    // 获取地址（首次有效经纬度时）
    if (this.flyInfo.address === '' && data.nowPlaneLat !== 0 && data.nowPlaneLon !== 0) {
      // 逆地理编码，异步获取，这里简单模拟，暂不实现
      // 可以调用鸿蒙位置服务，但为简化，我们留空或使用默认
      // this.flyInfo.address = await this.getAddress(data.nowPlaneLat, data.nowPlaneLon);
      // 暂时不处理
    }

    this.detailList.push(detail);
  }

  public async stop(): Promise<void> {
    hilog.info(DOMAIN, TAG, '保存飞行记录');
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }

    if (this.detailList.length === 0 || !this.flyInfo) {
      // 没有数据，不保存
      this.detailList = [];
      this.flyInfo = null;
      return;
    }

    // 计算飞行时间（秒）
    const duration = Math.floor((Date.now() - this.flyTime) / 1000);
    this.flyInfo.flightDuration = duration;

    // 保存到数据库：先插入主表
    const rowId = await this.dbManager.insertFlyInfo(this.flyInfo);
    if (rowId > 0) {
      // 插入详情
      for (const detail of this.detailList) {
        await this.dbManager.insertFlyDetail(detail);
      }
      hilog.info(DOMAIN, TAG, '飞行记录保存成功，主表ID: %{public}d', rowId);
    } else {
      hilog.error(DOMAIN, TAG, '飞行记录保存失败');
    }

    // 清理
    this.detailList = [];
    this.flyInfo = null;
  }

  public cancel(): void {
    this.detailList = [];
    this.flyInfo = null;
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
    hilog.info(DOMAIN, TAG, '飞行记录已取消');
  }
}