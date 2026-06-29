import { ExerciseRecord } from '../model/ExerciseRecord';
import StorageUtil from '../utils/StorageUtil';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import mediaquery from '@ohos.mediaquery';

interface SelectOption {
  value: string;
}

@Entry
@Component
struct Index {
  @State exerciseType: string = '跑步';
  @State duration: number = 30;
  @State note: string = '';
  @State records: ExerciseRecord[] = [];
  @State storageUtil: StorageUtil | null = null;
  @State isTablet: boolean = false;

  // Available exercise types
  private exerciseTypes: string[] = [
    '跑步',
    '骑行',
    '游泳',
    '步行',
    '瑜伽',
    '其他'
  ];

  private selectOptions: SelectOption[] = this.exerciseTypes.map(type => ({ value: type } as SelectOption));

  aboutToAppear() {
    // Get UIAbility context
    const context = getContext(this) as common.UIAbilityContext;
    StorageUtil.getInstance(context).then((util) => {
      this.storageUtil = util;
      this.loadRecords();
    }).catch((err: Error) => {
      console.error(`Failed to initialize storage: ${JSON.stringify(err)}`);
    });

    // Setup media query for tablet detection
    const mediaQuery = mediaquery.matchMediaSync('(min-width: 600vp) and (orientation: landscape)');
    this.isTablet = mediaQuery.matches;
    
    mediaQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      this.isTablet = result.matches;
    });
  }

  async loadRecords() {
    if (this.storageUtil) {
      this.records = await this.storageUtil.getAllRecords();
    }
  }

  async logExercise() {
    if (!this.storageUtil) {
      promptAction.showToast({ message: '存储未初始化' });
      return;
    }
    if (this.duration <= 0) {
      promptAction.showToast({ message: '时长必须大于0' });
      return;
    }
    const record = new ExerciseRecord(
      this.exerciseType,
      this.duration,
      new Date().toISOString(),
      this.note
    );
    await this.storageUtil.saveRecord(record);
    promptAction.showToast({ message: '打卡成功' });
    this.note = '';
    await this.loadRecords();
  }

  async deleteRecord(id: string) {
    if (!this.storageUtil) {
      return;
    }
    await this.storageUtil.deleteRecord(id);
    await this.loadRecords();
  }

  async clearAllRecords() {
    if (!this.storageUtil) {
      return;
    }
    // Show confirmation dialog
    promptAction.showDialog({
      title: '确认',
      message: '确定要清空所有记录吗？',
      buttons: [
        {
          text: '取消',
          color: '#999999'
        },
        {
          text: '确认',
          color: '#007DFF'
        }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        // User confirmed
        this.storageUtil?.clearAllRecords().then(() => {
          promptAction.showToast({ message: '记录已清空' });
          this.loadRecords();
        });
      }
    }).catch((err: Error) => {
      console.error(`Failed to show dialog: ${JSON.stringify(err)}`);
    });
  }

  aboutToDisappear() {
    // Clean up media query listeners if needed
  }

  build() {
    Column() {
      // Header
      Text('运动打卡')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 30 })

      // Input section
      Column() {
        // Exercise type picker
        Row() {
          Text('运动类型')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('40%')
          Select(this.selectOptions)
            .value(this.exerciseType)
            .onSelect((index: number, value: string) => {
              this.exerciseType = value;
            })
            .width('60%')
        }
        .margin({ bottom: 20 })

        // Duration input
        Row() {
          Text('时长（分钟）')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('40%')
          TextInput({ placeholder: '分钟', text: this.duration.toString() })
            .type(InputType.Number)
            .onChange((value: string) => {
              const num = parseInt(value);
              if (!isNaN(num)) {
                this.duration = num;
              }
            })
            .width('60%')
            .height(40)
            .border({ width: 1, color: '#CCCCCC', radius: 4 })
            .padding({ left: 10, right: 10 })
        }
        .margin({ bottom: 20 })

        // Note input
        Row() {
          Text('备注')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('40%')
          TextInput({ placeholder: '可选', text: this.note })
            .onChange((value: string) => {
              this.note = value;
            })
            .width('60%')
            .height(40)
            .border({ width: 1, color: '#CCCCCC', radius: 4 })
            .padding({ left: 10, right: 10 })
        }
        .margin({ bottom: 30 })

        // Log button
        Button('打卡', { type: ButtonType.Capsule })
          .width('80%')
          .height(50)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.logExercise();
          })
      }
      .padding(20)
      .border({ width: 1, color: '#EEEEEE', radius: 12 })
      .margin({ left: 20, right: 20, bottom: 30 })

      // History section
      Column() {
        Row() {
          Text('历史记录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
          Blank()
          if (this.records.length > 0) {
            Button('清空记录', { type: ButtonType.Normal })
              .fontSize(14)
              .fontColor('#FF3B30')
              .backgroundColor(Color.Transparent)
              .borderColor(Color.Transparent)
              .onClick(() => {
                this.clearAllRecords();
              })
          }
        }
        .width('100%')
        .padding({ bottom: 10 })

        if (this.records.length === 0) {
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 30 })
        } else {
          List({ space: 10 }) {
            ForEach(this.records, (record: ExerciseRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(record.type)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                    Blank()
                    Text(`${record.duration} 分钟`)
                      .fontSize(16)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .margin({ bottom: 5 })

                  Row() {
                    Text(new Date(record.date).toLocaleDateString())
                      .fontSize(14)
                      .fontColor('#999999')
                    if (record.note && record.note.trim() !== '') {
                      Text(` | ${record.note}`)
                        .fontSize(14)
                        .fontColor('#999999')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    Blank()
                    Button('删除', { type: ButtonType.Normal })
                      .fontSize(12)
                      .fontColor('#FF3B30')
                      .backgroundColor(Color.Transparent)
                      .borderColor(Color.Transparent)
                      .onClick(() => {
                        this.deleteRecord(record.id);
                      })
                  }
                  .width('100%')
                }
                .padding(15)
                .border({ width: 1, color: '#EEEEEE', radius: 8 })
                .backgroundColor('#FFFFFF')
                .width('100%')
              }
            }, (record: ExerciseRecord) => record.id)
          }
          .width('100%')
          .height(this.isTablet ? '60%' : '40%')
          .margin({ top: 10 })
        }
      }
      .padding(20)
      .border({ width: 1, color: '#EEEEEE', radius: 12 })
      .margin({ left: this.isTablet ? '20%' : 20, right: this.isTablet ? '20%' : 20 })
      .width(this.isTablet ? '60%' : '100%')
      .layoutWeight(1) // Take remaining space
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
  }
}