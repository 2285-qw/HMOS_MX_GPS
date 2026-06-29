// VSollbar.ets
import image from '@ohos.multimedia.image';

@Component
export struct VSollbar {
  @Prop thumbColor: string | number = '#FF5722';
  @Prop thumbSize: number = 15;
  @Prop max: number = 10;
  @Prop @Watch('onImageChanged') thumbImage?: Resource;
  @Prop @Watch('onImageChanged') backgroundImage_?: Resource;
  onProgressChanged?: (position: number, direction: number) => void;

  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private progress: number = 0;
  private center: number = 0;
  private scale_: number = 0;
  private direction_: number = 0;
  private touchStartY: number = 0;
  private isRunning: boolean = false;
  private timerId?: number;

  private thumbPixelMap?: image.PixelMap;
  private backgroundPixelMap?: image.PixelMap;
  private isImageLoading: boolean = false;
  private context?: Context;

  static readonly NONE = 0;
  static readonly UP = 1;
  static readonly DOWN = 2;

  // ==================== 图片加载（增强版） ====================
  private async loadImages() {
    if (this.isImageLoading) return;
    if (!this.context) {
      console.warn('VSollbar: context not ready');
      return;
    }
    this.isImageLoading = true;

    try {
      // 加载背景图片
      if (this.backgroundImage_) {
        try {
          // 1. 获取资源数据
          const buffer = await this.context.resourceManager.getMediaContent(this.backgroundImage_);
          console.info(`VSollbar: background buffer length = ${buffer.length}`);
          if (!buffer || buffer.length === 0) {
            throw new Error('Buffer is empty');
          }

          // 2. 转换为 ArrayBuffer（确保兼容）
          const arrayBuffer = buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength);
          const source = image.createImageSource(arrayBuffer);
          if (!source) {
            throw new Error('createImageSource returned undefined');
          }

          // 3. 创建 PixelMap
          this.backgroundPixelMap = await source.createPixelMap();
          console.info('VSollbar: background PixelMap created successfully');
        } catch (err) {
          console.error('VSollbar: background load failed', JSON.stringify(err));
          this.backgroundPixelMap = undefined;
        }
      } else {
        this.backgroundPixelMap = undefined;
      }

      // 加载滑块图片（同理）
      if (this.thumbImage) {
        try {
          const buffer = await this.context.resourceManager.getMediaContent(this.thumbImage);
          console.info(`VSollbar: thumb buffer length = ${buffer.length}`);
          if (!buffer || buffer.length === 0) {
            throw new Error('Buffer is empty');
          }
          const arrayBuffer = buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength);
          const source = image.createImageSource(arrayBuffer);
          if (!source) {
            throw new Error('createImageSource returned undefined');
          }
          this.thumbPixelMap = await source.createPixelMap();
          console.info('VSollbar: thumb PixelMap created successfully');
        } catch (err) {
          console.error('VSollbar: thumb load failed', JSON.stringify(err));
          this.thumbPixelMap = undefined;
        }
      } else {
        this.thumbPixelMap = undefined;
      }

      // 重绘
      this.draw();
    } catch (err) {
      console.error('VSollbar: loadImages error', JSON.stringify(err));
    } finally {
      this.isImageLoading = false;
    }
  }

  private onImageChanged(propName: string) {
    this.loadImages();
  }

  // ==================== 尺寸变化 ====================
  private handleAreaChange(newArea: Area): void {
    this.canvasWidth = newArea.width as number;
    this.canvasHeight = (newArea.height as number) - 20;
    if (this.canvasHeight <= 0) return;

    const thumbHeight = this.thumbSize;
    this.scale_ = (this.canvasHeight - thumbHeight) / this.max;
    this.center = (this.canvasHeight - thumbHeight) / 2;
    this.progress = this.center;
    this.draw();
  }

  // ==================== 绘制核心 ====================
  private draw(): void {
    const ctx = this.canvasCtx;
    if (!ctx) return;
    if (this.canvasWidth <= 0 || this.canvasHeight <= 0) return;

    const w = this.canvasWidth;
    const h = this.canvasHeight;

    ctx.clearRect(0, 0, w, h + 20);

    // 绘制背景
    if (this.backgroundPixelMap) {
      ctx.drawImage(this.backgroundPixelMap, 0, 0, w, h);
    } else if (this.backgroundImage_) {
      // 设置了图片但加载失败，显示占位
      ctx.fillStyle = '#e0e0e0';
      ctx.fillRect(0, 0, w, h);
      ctx.fillStyle = '#999';
      ctx.font = '12px';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('背景加载失败', w / 2, h / 2);
    } else {
      // 默认灰色背景
      ctx.fillStyle = '#e8e8e8';
      ctx.fillRect(0, 0, w, h);
    }

    // 轨道参考线
    const cx = w / 2;
    const radius = this.thumbSize / 2;
    /*ctx.strokeStyle = '#cccccc';
    ctx.lineWidth = 1;
    ctx.setLineDash([3, 5]);
    ctx.beginPath();
    ctx.moveTo(cx, radius + 5);
    ctx.lineTo(cx, h - radius - 5);
    ctx.stroke();
    ctx.setLineDash([]);*/

    // 滑块位置
    const cy = this.progress + radius;

    // 绘制滑块
    if (this.thumbPixelMap) {
      const left = cx - 40 / 2;
      const top = cy - this.thumbSize / 2;
      ctx.drawImage(this.thumbPixelMap, left, top, 40, 15);
    } else {
      // 纯色圆形
      ctx.shadowColor = 'rgba(0,0,0,0.3)';
      ctx.shadowBlur = 6;
      ctx.shadowOffsetX = 2;
      ctx.shadowOffsetY = 2;

      ctx.fillStyle = typeof this.thumbColor === 'string' ? this.thumbColor : '#FF5722';
      ctx.beginPath();
      ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
      ctx.fill();

      ctx.shadowColor = 'transparent';
      ctx.strokeStyle = '#333333';
      ctx.lineWidth = 1.5;
      ctx.stroke();

      // 高光
      ctx.fillStyle = 'rgba(255,255,255,0.35)';
      ctx.beginPath();
      ctx.arc(cx - radius * 0.3, cy - radius * 0.3, radius * 0.3, 0, 2 * Math.PI);
      ctx.fill();

      // 中心点
      ctx.fillStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.arc(cx, cy, 4, 0, 2 * Math.PI);
      ctx.fill();
    }
  }

  // ==================== 定时器 ====================
  private startTimer(): void {
    this.stopTimer();
    this.isRunning = true;
    this.timerId = setInterval(() => {
      if (this.isRunning && this.onProgressChanged) {
        const position = Math.round(this.progress / this.scale_);
        this.onProgressChanged(position, this.direction_);
      }
    }, 10);
  }

  private stopTimer(): void {
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
    this.isRunning = false;
  }

  // ==================== 触摸事件 ====================
  private onTouchEvent(event: TouchEvent): void {
    if (event.touches.length === 0) return;
    const touch = event.touches[0];
    const currentY = touch.y;

    switch (event.type) {
      case TouchType.Down:
        this.touchStartY = currentY;
        this.isRunning = true;
        this.startTimer();
        break;

      case TouchType.Move: {
        const diff = currentY - this.touchStartY;
        if (Math.abs(diff) < 20) break;

        const thumbHeight = this.thumbSize;
        const maxProgress = this.canvasHeight - 20;

        if (diff > 0) {
          this.direction_ = VSollbar.DOWN;
          this.progress += this.scale_;
          if (this.progress > maxProgress) this.progress = maxProgress;
        } else {
          this.direction_ = VSollbar.UP;
          this.progress -= this.scale_;
          if (this.progress < 20) this.progress = 10;
        }

        if (this.progress < 0) this.progress = 0;
        if (this.progress > maxProgress) this.progress = maxProgress;

        this.draw();
        break;
      }

      case TouchType.Up:
      case TouchType.Cancel:
        this.direction_ = VSollbar.NONE;
        this.progress = this.center;
        this.draw();

        if (this.onProgressChanged) {
          this.onProgressChanged(0, this.direction_);
        }

        this.isRunning = false;
        this.stopTimer();
        break;
    }

    event.stopPropagation();
  }

  // ==================== 生命周期 ====================
  aboutToAppear() {
    this.context = getContext(this);
    this.loadImages();
  }

  aboutToDisappear() {
    this.stopTimer();
    this.thumbPixelMap = undefined;
    this.backgroundPixelMap = undefined;
  }

  // ==================== 构建 ====================
  build() {
    Column() {
      Canvas(this.canvasCtx)
        .width('100%')
        .height('100%')
        .onAreaChange((_, newArea) => this.handleAreaChange(newArea))
        .onTouch((event) => this.onTouchEvent(event))
        .onReady(() => {
          if (this.canvasWidth > 0 && this.canvasHeight > 0) {
            this.draw();
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}