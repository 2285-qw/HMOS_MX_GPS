import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { FlyDetailInfo } from './FlyDetailInfo';
import { FlyInfo } from './FlyInfo';

// DatabaseManager.ets
export class DatabaseManager {
  private static instance: DatabaseManager;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  // 初始化数据库，创建表
  public async init(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: 'FlyRecords.db',
        securityLevel: relationalStore.SecurityLevel.S1,
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      console.info('数据库初始化成功');
    } catch (err) {
      console.error('数据库初始化失败:', JSON.stringify(err));
    }
  }

  // 创建两张表
  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;

    // 1. fly_info 表
    const sqlFlyInfo = `
      CREATE TABLE IF NOT EXISTS fly_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        droneType INTEGER,
        address TEXT,
        maxSpeed REAL,
        maxDistance REAL,
        maxAltitude REAL,
        flightDuration INTEGER,
        detail_id TEXT UNIQUE,
        logDate TEXT
      )
    `;

    // 2. fly_detail_info 表
    const sqlFlyDetail = `
      CREATE TABLE IF NOT EXISTS fly_detail_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detail_id TEXT,
        left INTEGER,
        right INTEGER,
        font INTEGER,
        back INTEGER,
        up INTEGER,
        down INTEGER,
        rightRotate INTEGER,
        lefrRotate INTEGER,
        h REAL,
        hs REAL,
        d REAL,
        vs REAL,
        lon REAL,
        lat REAL,
        angle INTEGER,
        FOREIGN KEY (detail_id) REFERENCES fly_info(detail_id) ON DELETE CASCADE
      )
    `;

    await this.rdbStore.executeSql(sqlFlyInfo);
    await this.rdbStore.executeSql(sqlFlyDetail);
    console.info('表创建成功');
  }

  // 获取 RdbStore 实例（供外部直接操作）
  public getStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }


  // 插入主记录，并同时插入关联的详情列表
  public async insertFlyInfo(flyInfo: FlyInfo): Promise<number> {
    if (!this.rdbStore) return -1;

    // 1. 插入主表
    const valueBucket: ValuesBucket = {
      'droneType': flyInfo.droneType,
      'address': flyInfo.address,
      'maxSpeed': flyInfo.maxSpeed,
      'maxDistance': flyInfo.maxDistance,
      'maxAltitude': flyInfo.maxAltitude,
      'flightDuration': flyInfo.flightDuration,
      'detail_id': flyInfo.detail_id,
      'logDate': flyInfo.logDate,
    };
    const rowId = await this.rdbStore.insert('fly_info', valueBucket);
    if (rowId === -1) {
      console.error('插入主表失败');
      return -1;
    }

    // 2. 插入详情列表（如果有）
    if (flyInfo.detailList && flyInfo.detailList.length > 0) {
      for (const detail of flyInfo.detailList) {
        detail.detail_id = flyInfo.detail_id; // 确保外键一致
        await this.insertFlyDetail(detail);
      }
    }
    return rowId;
  }

  public  async insertFlyDetail(detail: FlyDetailInfo): Promise<number> {
    if (!this.rdbStore) return -1;
    const valueBucket: ValuesBucket = {
      'detail_id': detail.detail_id,
      'left': detail.left,
      'right': detail.right,
      'font': detail.font,
      'back': detail.back,
      'up': detail.up,
      'down': detail.down,
      'rightRotate': detail.rightRotate,
      'lefrRotate': detail.lefrRotate,
      'h': detail.h,
      'hs': detail.hs,
      'd': detail.d,
      'vs': detail.vs,
      'lon': detail.lon,
      'lat': detail.lat,
      'angle': detail.angle,
    };
    return await this.rdbStore.insert('fly_detail_info', valueBucket);
  }
  // 查询所有主记录，并填充每个记录的 detailList
  public async queryAllFlyInfos(): Promise<FlyInfo[]> {
    if (!this.rdbStore) return [];

    const predicates = new relationalStore.RdbPredicates('fly_info');
    const resultSet = await this.rdbStore.query(predicates);
    const flyInfos: FlyInfo[] = [];

    while (resultSet.goToNextRow()) {
      const fly = new FlyInfo();
      fly.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      fly.droneType = resultSet.getLong(resultSet.getColumnIndex('droneType'));
      fly.address = resultSet.getString(resultSet.getColumnIndex('address'));
      fly.maxSpeed = resultSet.getDouble(resultSet.getColumnIndex('maxSpeed'));
      fly.maxDistance = resultSet.getDouble(resultSet.getColumnIndex('maxDistance'));
      fly.maxAltitude = resultSet.getDouble(resultSet.getColumnIndex('maxAltitude'));
      fly.flightDuration = resultSet.getLong(resultSet.getColumnIndex('flightDuration'));
      fly.detail_id = resultSet.getString(resultSet.getColumnIndex('detail_id'));
      fly.logDate = resultSet.getString(resultSet.getColumnIndex('logDate'));

      // 查询该记录对应的详情列表
      const detailPredicates = new relationalStore.RdbPredicates('fly_detail_info');
      detailPredicates.equalTo('detail_id', fly.detail_id);
      const detailResultSet = await this.rdbStore.query(detailPredicates);
      const details: FlyDetailInfo[] = [];
      while (detailResultSet.goToNextRow()) {
        const detail = new FlyDetailInfo();
        detail.id = detailResultSet.getLong(detailResultSet.getColumnIndex('id'));
        detail.detail_id = detailResultSet.getString(detailResultSet.getColumnIndex('detail_id'));
        detail.left = detailResultSet.getLong(detailResultSet.getColumnIndex('left'));
        // ... 其他字段类似赋值
        details.push(detail);
      }
      detailResultSet.close();
      fly.detailList = details;
      flyInfos.push(fly);
    }
    resultSet.close();
    return flyInfos;
  }
}