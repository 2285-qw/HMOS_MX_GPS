import { emitter } from "@kit.BasicServicesKit";
import { ModeType, PageSendData } from "../Drone/core/protocol/PageSendData";
import { ProtocolManager } from "../Drone/core/protocol/ProtocolManager";
import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class Utils {
  //页面之间的数据通信
  public static sendEvent(id: number, type: number, data?: Uint8Array) {
    // 1. 创建事件对象
    const innerEvent: emitter.InnerEvent = {
      eventId: id, // 事件ID，需与接收方保持一致
      priority: emitter.EventPriority.HIGH  // 优先级控制
    };
    let pageSendData: PageSendData = new PageSendData(ModeType.Page, type, data);
    // 2. 创建要发送的数据
    const eventData: emitter.EventData = {
      data: pageSendData
    };

    // 3. 发送事件
    emitter.emit(innerEvent, eventData);
    //console.log("事件发送成功");
  }


  private static lastVibrateTime: number = 0;

  //震动
  public static setVibration() {
    const now = Date.now();
    if (now - Utils.lastVibrateTime < 80) {
      // 距离上次震动不足 80ms，忽略此次请求
      console.info('震动请求被防抖拦截');
      return;
    }
    Utils.lastVibrateTime = now;
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 25, // 震动时长，单位毫秒
      }, {
        id: 0,
        usage: 'alarm',
      }, (error: BusinessError) => {
        if (error) {
          console.error(`震动失败: ${error.message}`);
        } else {
          console.info('震动成功');
        }
      });
    } catch (err) {
      console.error(`发生未知错误: ${err}`);
    }
  }
}