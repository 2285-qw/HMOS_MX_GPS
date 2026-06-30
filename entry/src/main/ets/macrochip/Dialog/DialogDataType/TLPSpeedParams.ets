export class TLPSpeedParams {
  speed: number = 4;
  dialogId?: ComponentContent;
  uiContext?: UIContext;
  minValue: number = 4;
  maxValue: number = 50;
  onSpeedClick?: (speed: number) => void

  constructor() {

  }

  setSpeed(speed: number) {
    this.speed = speed;
    return this;
  }


  setDialogId(dialogId: ComponentContent) {
    this.dialogId = dialogId;
    return this;
  }

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
    return this;
  }

  setOnSpeedClick(onSpeedClick: (speed: number) => void) {
    this.onSpeedClick = onSpeedClick;
    return this;
  }
}
