import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import NapiBuffer from 'libentry.so';
import { ObjectUtils } from '../utils/ObjectUtils'
import promptAction from '@ohos.promptAction';
import { VideoStreamHandle } from '../connect/stream/VideoStreamHandle';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;


/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = (event: MessageEvents) => {

  switch (event.data.type) {
    case 'start_reading':
      break;
    case 'startCUsb':
      startCUsb();
      break
    case 'stopUsb':
      stopCUsb()
      break;
  }

};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessageerror = (event: MessageEvents) => {
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param event error message
 */
workerPort.onerror = (event: ErrorEvent) => {
};


let isRunning = false;

function startCUsb(): void {
  console.log("newData======————", "startCUsb");
  isRunning = true;

  const readData = () => {
    if (!isRunning) {
      return;
    }

    try {
      /*  * @param order  消息顺序。0
        * @param length 消息长度。1
        * @param msgId  消息ID。2*/
      const header: Array<number> = new Array<number>(3);
      // 解析得到数据
      let newData: Uint8Array = NapiBuffer.getUsbOneFrame(header);

      /*  if (header[2] == 0x03) {
          console.log("newData======————", "header=" + header);
          console.log("newData======————", ObjectUtils.arrayBufferToHex(newData));
        }
  */

      if (newData) {
        if (header[2] != 0x00) {
          // 发送数据到主线程，包括头部和新的数据
          workerPort.postMessage({
            type: 'usbdata',
            header: header,
            data: newData
          });
        }
        console.log("newData======————", "header=" + newData);
      }

      // 继续下一次读取，使用setTimeout避免堆栈溢出，并给其他任务执行机会
      setTimeout(readData, 0);
    } catch (error) {
      console.error('Usb读取错误:', error, error.code);
      isRunning = false;
    }
  };

  // 开始读取循环
  readData();

}

function startNewCUsb(): void {
  if (isRunning) {
    console.warn('USB 读取已启动，忽略重复调用');
    return;
  }
  console.log('newData======————', 'startCUsb');
  isRunning = true;

  // 异步循环，使用 while + await 实现非阻塞轮询
  (async () => {
    while (isRunning) {
      try {
        // 1. 准备头部缓冲区（每次复用，避免重复分配）
        const header: number[] = new Array(3);

        // 2. 同步读取一帧数据（C++ 扩展，会填充 header 并返回数据）
        const newData = NapiBuffer.getUsbOneFrame(header);

        // 3. 根据帧类型处理
        const msgId = header[2]; // 消息 ID
        if (msgId === 0x03) {
          // 特定调试日志，可考虑注释或使用条件编译
          console.log('newData======————', `header=${header}`);
          console.log('newData======————', ObjectUtils.arrayBufferToHex(newData));
        }

        // 4. 向主线程发送有效数据（仅当 msgId 非 0 且有数据）
        if (msgId !== 0x00 && newData && newData.length > 0) {
          // 发送数据到主线程
          workerPort.postMessage({
            type: 'usbdata',
            header: header,
            data: newData,
          });
        }

        // 5. 控制循环节奏
        // 如果无数据（msgId === 0x00 或 newData 为空），则让出 CPU 并等待一小段时间
        // 否则立即进入下一次循环（使用 setImmediate 或微任务）
        if (msgId === 0x00 || !newData || newData.length === 0) {
          // 无数据，等待 1ms 避免空转
          await new Promise<void>(resolve => setTimeout(resolve, 1));
        } else {
          // 有数据，尽快继续（让出当前执行栈，但延迟最小）
          await new Promise<void>(resolve => setTimeout(resolve, 0));
          // 如果环境不支持 setImmediate，可用 setTimeout(resolve, 0)
          // await new Promise<void>(resolve => setTimeout(resolve, 0));
        }
      } catch (error) {
        // 错误处理：区分可恢复错误
        console.error('USB 读取异常:', error);

        // 判断是否为可恢复错误（例如 EAGAIN）
        const isRecoverable = error?.code === 'EAGAIN' || error?.code === 'EWOULDBLOCK';
        if (isRecoverable) {
          // 等待 10ms 后重试
          await new Promise<void>(resolve => setTimeout(resolve, 10));
          // 继续循环，不停止
          continue;
        }

        // 致命错误，停止循环
        isRunning = false;
        // 通知主线程
        workerPort.postMessage({
          type: 'ERROR',
          text: `USB 读取致命错误: ${error.message || String(error)}`,
        });
        break;
      }
    }

    // 循环结束，清理状态
    console.info('USB 读取循环已退出');
  })(); // 立即执行
}

function stopCUsb(): void {
  isRunning = false;
}




