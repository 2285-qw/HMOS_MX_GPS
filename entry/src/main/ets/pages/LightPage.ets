import EntryAbility from '../entryability/EntryAbility';
import { LanGuangAnalysis } from '../macrochip/FunctionalAnalysis/LanGuangAnalysis';
import { LightBean } from '../macrochip/mode/LightBean';
import { RouteHelper } from '../macrochip/utils/RouteHelper'
import { WheelView } from '../macrochip/view/WheelView';

@Entry
@Component
struct LightPage {
  @State items: string[] =
    ['双色跳变', '三色跳变', '七色跳变', '双色渐变', '三色渐变', '七色渐变', '双色流水', '三色流水', '七色流水',
      '双色频闪',];
  //判断条件 跳变 lightType2 = 1;  渐变 lightType2 = 2;  频闪 lightType2 = 3;   流水lightType2 = 4;
  //七 lightType1 = 3; 三 lightType1 = 2; 双 lightType1 = 1;
  private colorIcons: Resource[] = [
    $r('app.media.ic_yellow_select'),
    $r('app.media.ic_white_select'),
    $r('app.media.ic_light_blue_select'),
    $r('app.media.ic_red_select'),
    $r('app.media.ic_light_green_select'),
    $r('app.media.ic_blue_select'),
    $r('app.media.ic_pink_select')
  ];
  @State selectedIdx: number = 2;
  @State selectedIndex: Resource = $r('app.media.ic_yellow_select');
  @State lightType1: number = 0;
  @State lightType2: number = 0;
  @State isTrue: boolean = false;

  build() {
    RelativeContainer() {


      WheelView({
        items: this.items,
        selectedIndex: $selectedIdx,
        loop: true,
        textSize: 90,
        visibleItems: 5, // 设置可见条目数为 9（实际显示 7 个
        lineSpacing: 2.0, // 配合调整条目间距
        centerTextColor: '#05FBFB',
        dividerColor: '#00000000',
        // label: 'kg',
        reverse: true, // 反转方向
        onSelected: (index) => {
          /*   ['双色跳变','三色跳变', '七色跳变',  '双色渐变','三色渐变', '七色渐变',  '双色流水', '三色流水','七色流水',
      '双色频闪',];*/
          //判断条件 跳变 lightType2 = 1;  渐变 lightType2 = 2;  频闪 lightType2 = 3;   流水lightType2 = 4;
          //七 lightType1 = 3; 三 lightType1 = 2; 双 lightType1 = 1;
          if (index === 0) {
            this.lightType1 = 1;
            this.lightType2 = 1;
          } else if (index === 1) {
            this.lightType1 = 2;
            this.lightType2 = 1;
          } else if (index === 2) {
            this.lightType1 = 3;
            this.lightType2 = 1;
          }
          if (index === 3) {
            this.lightType1 = 1;
            this.lightType2 = 2;
          } else if (index === 4) {
            this.lightType1 = 2;
            this.lightType2 = 2;
          } else if (index === 5) {
            this.lightType1 = 3;
            this.lightType2 = 2;
          }
          if (index === 6) {
            this.lightType1 = 1;
            this.lightType2 = 4;
          } else if (index === 7) {
            this.lightType1 = 2;
            this.lightType2 = 4;
          } else if (index === 8) {
            this.lightType1 = 3;
            this.lightType2 = 4;
          }
          if (index === 9) {
            this.lightType1 = 1;
            this.lightType2 = 3;
          }
          this.lightData(0, 0, 0);
        }
      })
        .margin({ left: 50 })
        .width(200)

      Image($r('app.media.ic_back_white'))
        .width(30)
        .height(30)
        .objectFit(ImageFit.CENTER)

        .margin({ left: 20, top: 20 })
        .onClick(() => {
          RouteHelper.back()
        })


      Row({ space: 10 }) {
        Text('经典').fontSize(20).fontColor(Color.White)
        ForEach(this.colorIcons, (icon: Resource, index: number) => {
          Image(icon)
            .width(50)
            .height(50)
            .objectFit(ImageFit.Cover) // 填满并裁剪，图片显得更大
            .clip(true) // 默认裁剪（true），多余的切除
            /* .border({
               width: 2,
               color: this.selectedIndex === index ? '#FF6B6B' : Color.Transparent,
               radius: 8
             })*/
            .onClick(() => {
              this.selectedIndex = icon;
              this.lightType1 = 0;
              this.lightType2 = this.isTrue ? 0 : 5;
              if (index == 0) {
                this.lightData(252, 252, 14);
              } else if (index == 1) {
                this.lightData(254, 254, 254);
              } else if (index == 2) {
                this.lightData(33, 254, 254);
              } else if (index == 3) {
                this.lightData(248, 0, 7);
              } else if (index == 4) {
                this.lightData(35, 255, 12);
              } else if (index == 5) {
                this.lightData(0, 0, 242);
              } else if (index == 6) {
                this.lightData(221, 0, 228);
              }

            })
        }) // 使用索引作为唯一键
      }.alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        right: { anchor: '__container__', align: HorizontalAlign.End }
      }).margin({ right: 50, top: 80 }).id('right')

      Image(this.selectedIndex)
        .alignRules({
          bottom: { anchor: 'right', align: VerticalAlign.Top },
          left: { anchor: 'right', align: HorizontalAlign.Start }
        })
        .margin({ bottom: 80 })
        .width(50)
        .height(50)

      Toggle({ type: ToggleType.Switch, isOn: this.isTrue })
        .selectedColor('#59B3F9')   // 设置选中时的背景色
        .switchPointColor('#FFFFFF') // 设置滑块颜色
        .onChange((isOn: boolean) => { // 2. 监听状态变化
          this.isTrue = isOn;
          console.log(`Switch is now: ${isOn ? 'ON' : 'OFF'}`);
          // 在这里执行相应的业务逻辑，比如开启/关闭某个功能
        })
        .alignRules({
          bottom: { anchor: 'right', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .margin({ bottom: 100, right: 20 })
        .border({
          width: 1,
          color: this.isTrue ? '#59B3F9' : '#ffffff', // 选中时边框与背景色一致，未选中时灰色
          radius: 20
        })


    }.backgroundImage($r('app.media.img_control_bg'))
    .height('100%')
    .width('100%')
    .backgroundImageSize(ImageSize.Cover) // 或 ImageSize.Contain
  }

  private lightData(R: number, G: number, B: number): void {
    const data = new Uint8Array(8);
    data[0] = 0x68;
    data[1] = 0x07;
    data[2] = 0x04;
    const lightBean = new LightBean();
    lightBean.lightType1 = this.lightType1; // 假设是类的属性
    lightBean.lightType2 = this.lightType2;
    lightBean.readN = R;
    lightBean.greenN = G;
    lightBean.blueN = B;

    const newData = LanGuangAnalysis.packLightBean(lightBean); // 返回 Uint8Array 长度4
    // 复制到 data 从索引3开始
    for (let i = 0; i < newData.length; i++) {
      data[3 + i] = newData[i];
    }
    // 计算校验和：异或 data[1] 到 data[6]
    let checksum = 0;
    for (let i = 1; i <= 6; i++) {
      checksum ^= data[i];
    }
    data[7] = checksum;
    // 发送 TCP 命令
    // 假设有 writeTCPCmd 方法，传入 Uint8Array
    // 发送 TCP 命令
    EntryAbility.getInstance().sendUDPCmd(data);
  }
}