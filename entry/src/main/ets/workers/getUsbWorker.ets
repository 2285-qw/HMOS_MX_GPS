// worker.ets
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { VideoStreamHandle } from '../connect/stream/VideoStreamHandle';
import fs from '@ohos.file.fs';
import promptAction from '@ohos.promptAction';
import NapiBuffer from 'libentry.so';
import taskpool from '@ohos.taskpool';
import fileIo from '@ohos.file.fs';


const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let isReading = false;
let fileDescriptor: number = -1;


// 注册onmessage回调，当Worker线程收到来自其宿主线程通过postMessage接口发送的消息时被调用，在Worker线程执行
workerPort.onmessage = (e: MessageEvents) => {
  switch (e.data.type) {
    case 'start_reading':

      fileDescriptor = e.data.fd;
      //e.data.bufferSize
      console.debug("usb读取数据", '111111111000')
      //startReading(1024*16);
      startNewReading(1024 * 16)
      break;

    case 'stop_reading':
      stopReading();
      break;
  }

}


// 开始读取数据
function startReading(bufferSize: number): void {
  if (isReading || fileDescriptor <= 0) {
    return;
  }

  isReading = true;
  console.debug("usb读取数据", '111111111000222')
  // 异步读取循环
  const readLoop = async () => {
    if (!isReading) {
      return;
    }

    try {
      const buffer = new ArrayBuffer(bufferSize);
      const bytesRead = fileIo.readSync(fileDescriptor, buffer, {
        offset: 0,
        length: bufferSize,
      });
      console.debug("usb读取数据", '1111111110333333')
      if (bytesRead > 0) {
        const data = new Uint8Array(buffer, 0, bytesRead);
        NapiBuffer.addUsbStream(data, bytesRead)
        // 发送回主线程
        //workerPort.postMessage(data);
        /*  workerPort.postMessage({
            type: 'TOAST',
            text:'startReading读取到数据'
          })*/
      }
      console.error('usb读取数据', '正在读取');
      // 继续读取
      setTimeout(readLoop, 5);

    } catch (error) {
      workerPort.postMessage({
        type: 'TOAST',
        text: 'usb读取数据' + error
      })
      console.error('usb读取数据', 'Worker读取错误');
      console.error('usb读取数据:', JSON.stringify(error));
      isReading = false;
    }
  };

  readLoop();
}


// 假设已有导入：import fileIo from '@ohos.file.fs';
// 外部变量声明（假设在文件顶部已定义）：
// let isReading: boolean = false;
// let fileDescriptor: number = -1;
// const workerPort: WorkerPort = ...;
// const NapiBuffer: { addUsbStream(data: Uint8Array, length: number): void } = ...;

// 定义错误类型接口（放在函数外部或文件顶部）
interface ErrorWithCode {
  code?: string;
}

function startNewReading(bufferSize: number): void {
  if (isReading || fileDescriptor <= 0) {
    return;
  }
  isReading = true;
  const buffer = new ArrayBuffer(bufferSize);
  try {
    // 将 fileIo.read 转换为 Promise
    const readAsync = (): Promise<number> => {
      return new Promise((resolve, reject) => {
        const callback = (err: Error | null, bytesRead: number): void => {
          if (err) {
            reject(err);
          } else {
            resolve(bytesRead);
          }
        };
        fileIo.read(
          fileDescriptor,
          buffer,
          {
            offset: 0,
            length: bufferSize,
          },
          callback
        );
      });
    };

    // 使用立即执行的异步函数，内部使用 while 循环
    (async () => {
      while (isReading) {
        try {
          const bytesRead = await readAsync();
          if (bytesRead > 0) {
            const data = new Uint8Array(buffer, 0, bytesRead);
            console.error("把数据放入一次循环", buffer.byteLength)
            NapiBuffer.addUsbStream(data, bytesRead);
            // 不再需要 setTimeout，直接继续循环
          } else {
            // 无数据时，主动让出控制权，避免 CPU 空转
            await new Promise<void>(resolve => setTimeout(resolve, 1));
          }
        } catch (error) {
          console.error('worker线程错误:', error, error.code);
          // 判断是否可恢复错误
          let isRecoverable = false;
          if (error && typeof error === 'object') {
            const errObj = error as ErrorWithCode;
            if (errObj.code === 'EAGAIN' || errObj.code === 'EWOULDBLOCK') {
              isRecoverable = true;
            }
          }
          if (isRecoverable) {
            // 等待后重试
            await new Promise<void>(resolve => setTimeout(resolve, 10));
            continue; // 继续循环
          } else {
            // 致命错误，停止读取
            isReading = false;
            break;
          }
        }
      }
    })(); // 立即执行
  }catch (error){
    console.error('worker线程错误:', error, error.code);
  }

}

// 停止读取
function stopReading(): void {
  isReading = false;
}

// 注册onmessageerror回调，当Worker对象接收到一条无法被序列化的消息时被调用，在Worker线程执行
workerPort.onmessageerror = () => {
  console.error('workerPort onmessageerror');
}

// 注册onerror回调，捕获Worker在执行过程中发生的异常，在Worker线程执行
workerPort.onerror = (err: ErrorEvent) => {
  console.error('workerPort onerror err is: ', err.message);
}
