// WheelView.ets

@Component
export struct WheelView {
  @Prop items: string[] = [];
  @Link selectedIndex: number;
  @Prop loop: boolean = true;
  @Prop textSize: number = 22;
  @Prop outerTextColor: string = '#D0D3D3';
  @Prop centerTextColor: string = '#05FBFB';
  @Prop dividerColor: string = '#000000';
  @Prop lineSpacing: number = 2.0;
  @Prop visibleItems: number = 7;
  @Prop label?: string;
  @Prop isCenterLabel: boolean = true;
  @Prop gravity: string = 'center';
  @Prop reverse: boolean = false;   // 设为 true 反转滚动方向
  onSelected?: (index: number) => void;

  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private containerWidth: number = 0;
  private containerHeight: number = 0;

  private totalScrollY: number = 0;
  private itemHeight: number = 0;
  private maxTextWidth: number = 0;
  private maxTextHeight: number = 0;
  private initPosition: number = 0;
  private selectedItem: number = 0;

  private isTouching: boolean = false;
  private startY: number = 0;
  private startScrollY: number = 0;
  private velocity: number = 0;
  private lastMoveTime: number = 0;
  private lastMoveY: number = 0;
  private animatorId: number | undefined;

  private static readonly DEFAULT_VISIBLE_ITEMS = 7;
  private static readonly SCALE_CONTENT = 0.7;

  aboutToAppear() {
    if (this.visibleItems % 2 === 0) this.visibleItems = WheelView.DEFAULT_VISIBLE_ITEMS;
    if (this.selectedIndex < 0) this.selectedIndex = 0;
    if (this.selectedIndex >= this.items.length) this.selectedIndex = this.items.length - 1;
    this.initPosition = this.selectedIndex;
    this.selectedItem = this.selectedIndex;
  }

  aboutToDisappear() {
    this.stopAnimator();
  }

  private handleAreaChange(newArea: Area): void {
    this.containerWidth = Number(newArea.width) || 0;
    this.containerHeight = Number(newArea.height) || 0;
    if (this.containerWidth <= 0 || this.containerHeight <= 0) return;
    this.remeasure();
    this.draw();
  }

  private remeasure() {
    if (!this.items || this.items.length === 0) return;
    this.measureTextWidthHeight();
    this.itemHeight = this.lineSpacing * this.maxTextHeight;
  }

  private measureTextWidthHeight() {
    const ctx = this.canvasCtx;
    if (!ctx) return;
    ctx.font = this.textSize + 'px sans-serif';
    this.maxTextWidth = 0;
    for (const item of this.items) {
      const metrics = ctx.measureText(item || '');
      if (metrics.width > this.maxTextWidth) this.maxTextWidth = metrics.width;
    }
    const hm = ctx.measureText('中');
    this.maxTextHeight = hm.actualBoundingBoxAscent + hm.actualBoundingBoxDescent || this.textSize * 1.2;
    if (this.maxTextWidth === 0) this.maxTextWidth = this.textSize * 3;
  }

  private draw() {
    const ctx = this.canvasCtx;
    if (!ctx) return;
    if (this.containerWidth <= 0 || this.containerHeight <= 0) return;
    if (!this.items || this.items.length === 0) {
      ctx.clearRect(0, 0, this.containerWidth, this.containerHeight);
      return;
    }

    const w = this.containerWidth;
    const h = this.containerHeight;
    ctx.clearRect(0, 0, w, h);

    const half = Math.floor(this.visibleItems / 2);
    const totalHeight = this.itemHeight * (this.visibleItems - 1);
    const startOffset = (h - totalHeight) / 2;

    const change = Math.floor(this.totalScrollY / this.itemHeight);
    let preIndex = this.initPosition + change;
    if (this.loop) {
      preIndex = ((preIndex % this.items.length) + this.items.length) % this.items.length;
    } else {
      if (preIndex < 0) preIndex = 0;
      if (preIndex >= this.items.length) preIndex = this.items.length - 1;
    }

    const itemOffset = this.totalScrollY % this.itemHeight;

    if (this.dividerColor !== 'transparent' && this.dividerColor !== '#00000000') {
      ctx.strokeStyle = this.dividerColor;
      ctx.lineWidth = 1;
      const centerY = h / 2;
      const lineY1 = centerY - this.itemHeight / 2;
      const lineY2 = centerY + this.itemHeight / 2;
      ctx.beginPath();
      ctx.moveTo(0, lineY1);
      ctx.lineTo(w, lineY1);
      ctx.moveTo(0, lineY2);
      ctx.lineTo(w, lineY2);
      ctx.stroke();
    }

    for (let i = -half; i <= half; i++) {
      let index = preIndex + i;
      if (this.loop) {
        index = ((index % this.items.length) + this.items.length) % this.items.length;
      }
      let content = '';
      if (index >= 0 && index < this.items.length) {
        content = this.items[index];
      }
      if (!content) continue;

      const offsetY = i * this.itemHeight - itemOffset;
      const centerY = h / 2 + offsetY;
      const isCenter = (i === 0 && Math.abs(itemOffset) < this.itemHeight / 2);

      ctx.save();
      ctx.translate(0, centerY);

      let displayText = content;
      if (!this.isCenterLabel && this.label) {
        displayText = content + this.label;
      }

      const progress = Math.abs(offsetY) / (half * this.itemHeight);
      const fontSizeScale = 1 - progress * 0.3;
      const fontSize = this.textSize * (isCenter ? 1.1 : fontSizeScale);
      ctx.font = fontSize + 'px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      const scaleY = isCenter ? 1 : 1 - progress * (1 - WheelView.SCALE_CONTENT);
      if (!isCenter) {
        ctx.scale(1, scaleY);
      }

      if (isCenter) {
        ctx.fillStyle = this.centerTextColor;
        ctx.globalAlpha = 1;
        this.selectedItem = this.loop ? ((preIndex % this.items.length) + this.items.length) % this.items.length : Math.max(0, Math.min(preIndex, this.items.length - 1));
      } else {
        ctx.fillStyle = this.outerTextColor;
        ctx.globalAlpha = 1 - progress * 0.7;
        const skewX = (offsetY > 0 ? -1 : 1) * 0.3 * progress;
        ctx.transform(1, 0, skewX, 1, 0, 0);
      }

      ctx.fillText(displayText, w / 2, 0);
      ctx.restore();
    }

    if (this.label && this.isCenterLabel) {
      ctx.fillStyle = this.centerTextColor;
      ctx.font = this.textSize + 'px sans-serif';
      ctx.textAlign = 'right';
      ctx.textBaseline = 'middle';
      ctx.fillText(this.label, w - 10, h / 2);
    }

    if (this.selectedItem !== this.selectedIndex) {
      this.selectedIndex = this.selectedItem;
      if (this.onSelected) this.onSelected(this.selectedIndex);
    }
  }

  private handleTouch(event: TouchEvent): void {
    if (!this.items || this.items.length === 0) return;
    const touch = event.touches[0];
    if (!touch) return;

    switch (event.type) {
      case TouchType.Down:
        this.stopAnimator();
        this.isTouching = true;
        this.startY = touch.y;
        this.startScrollY = this.totalScrollY;
        this.lastMoveY = touch.y;
        this.lastMoveTime = Date.now();
        this.velocity = 0;
        break;

      case TouchType.Move:
        if (!this.isTouching) break;
        let dy = touch.y - this.lastMoveY;
        if (this.reverse) dy = -dy;      // 反转方向
        this.totalScrollY += dy;
        this.lastMoveY = touch.y;
        this.lastMoveTime = Date.now();
        if (!this.loop) {
          const maxScroll = (this.items.length - 1) * this.itemHeight;
          if (this.totalScrollY < 0) this.totalScrollY = 0;
          if (this.totalScrollY > maxScroll) this.totalScrollY = maxScroll;
        }
        this.draw();
        break;

      case TouchType.Up:
      case TouchType.Cancel:
        this.isTouching = false;
        const now = Date.now();
        const timeDiff = now - this.lastMoveTime;
        let velocity = 0;
        if (timeDiff > 0 && timeDiff < 100) {
          velocity = (touch.y - this.lastMoveY) / timeDiff;
        }
        if (this.reverse) velocity = -velocity;   // 反转惯性
        if (Math.abs(velocity) > 0.1) {
          this.fling(velocity);
        } else {
          this.smoothScrollToNearest();
        }
        break;
    }
    event.stopPropagation();
  }

  private fling(velocity: number) {
    const duration = Math.min(Math.abs(velocity) * 200, 1000);
    const targetScroll = this.totalScrollY + velocity * duration * 0.5;
    this.animateScrollTo(targetScroll, duration);
  }

  private smoothScrollToNearest() {
    const remainder = this.totalScrollY % this.itemHeight;
    let targetOffset = 0;
    if (remainder > this.itemHeight / 2) {
      targetOffset = this.itemHeight - remainder;
    } else {
      targetOffset = -remainder;
    }
    const targetScroll = this.totalScrollY + targetOffset;
    if (!this.loop) {
      const maxScroll = (this.items.length - 1) * this.itemHeight;
      if (targetScroll < 0) {
        this.totalScrollY = 0;
        this.draw();
        return;
      }
      if (targetScroll > maxScroll) {
        this.totalScrollY = maxScroll;
        this.draw();
        return;
      }
    }
    this.animateScrollTo(targetScroll, 200);
  }

  private animateScrollTo(target: number, duration: number) {
    this.stopAnimator();
    const start = this.totalScrollY;
    const diff = target - start;
    if (Math.abs(diff) < 0.5) {
      this.totalScrollY = target;
      this.draw();
      return;
    }
    const startTime = Date.now();
    const id = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const ease = 1 - Math.pow(1 - progress, 3);
      this.totalScrollY = start + diff * ease;
      if (!this.loop) {
        const maxScroll = (this.items.length - 1) * this.itemHeight;
        if (this.totalScrollY < 0) this.totalScrollY = 0;
        if (this.totalScrollY > maxScroll) this.totalScrollY = maxScroll;
      }
      this.draw();
      if (progress >= 1) {
        clearInterval(id);
        this.totalScrollY = target;
        const rem = this.totalScrollY % this.itemHeight;
        if (rem !== 0) {
          this.totalScrollY -= rem;
          if (this.totalScrollY < 0) this.totalScrollY = 0;
        }
        this.draw();
      }
    }, 16);
    this.animatorId = id;
  }

  private stopAnimator() {
    if (this.animatorId !== undefined) {
      clearInterval(this.animatorId);
      this.animatorId = undefined;
    }
  }

  build() {
    Column() {
      Canvas(this.canvasCtx)
        .width('100%')
        .height('100%')
        .onAreaChange((_, newArea) => this.handleAreaChange(newArea))
        .onTouch((event) => this.handleTouch(event))
        .onReady(() => {
          if (this.containerWidth > 0 && this.containerHeight > 0) {
            this.draw();
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}