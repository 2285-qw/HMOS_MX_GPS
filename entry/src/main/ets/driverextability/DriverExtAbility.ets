// DriverExtAbility.ets
import { DriverExtensionAbility } from '@kit.DriverDevelopmentKit';
import { rpc } from '@kit.IPCKit';

const REQUEST_CODE = 99; // 与应用协商一致的请求码

class DriverExtAbility extends DriverExtensionAbility {
  // 驱动被创建时回调，适合做初始化工作
  onCreate() {
    console.info('DriverExtAbility onCreate');
    // 在这里调用 OH_Usb_Init() 等初始化USB DDK的API[reference:10]
  }

  // 驱动被销毁时回调，适合做资源回收工作
  onDestroy() {
    console.info('DriverExtAbility onDestroy');
    // 在这里调用 OH_Usb_Release() 等释放资源的API[reference:11]
  }

  // 核心方法：接收来自应用层的消息
  onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, option: rpc.MessageOption) {
    if (code === REQUEST_CODE) {
      // 1. 解析从应用层传来的数据
      let deviceId: string = data.readString(); // 示例：读取设备ID
      // 2. 执行具体的USB操作，例如读取设备描述符[reference:12]
      // let desc = OH_Usb_GetDeviceDescriptor(deviceId);
      // 3. 将操作结果返回给应用层
      reply.writeString('Driver operation successful!');
    }
    return true;
  }
}

export default DriverExtAbility;