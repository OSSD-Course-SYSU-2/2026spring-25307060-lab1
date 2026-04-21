import router from '@ohos.router';
import { RecordItem, RecordType, EXPENSE_CATEGORIES, INCOME_CATEGORIES } from '../model/RecordItem';
import { DataManager } from '../data/DataManager';

@Entry
@Component
struct AddRecord {
  @State currentType: RecordType = RecordType.EXPENSE;  // 当前选择的类型
  @State amount: string = '';                           // 金额输入
  @State selectedCategory: string = '';                 // 选择的分类
  @State description: string = '';                      // 描述
  @State selectedDate: Date = new Date();               // 选择日期
  
  private dataManager: DataManager = DataManager.getInstance();
  
  // 获取当前类型的分类列表
  private getCategories(): string[] {
    return this.currentType === RecordType.EXPENSE ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
  }
  
  // 切换记录类型
  private switchType(type: RecordType): void {
    this.currentType = type;
    this.selectedCategory = this.getCategories()[0]; // 重置为第一个分类
  }
  
  // 保存记录
  private async saveRecord(): Promise<void> {
    const amountNum = parseFloat(this.amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      console.error('Invalid amount');
      return;
    }
    
    if (!this.selectedCategory) {
      console.error('Please select category');
      return;
    }
    
    const record = new RecordItem(
      DataManager.generateId(),
      this.currentType,
      amountNum,
      this.selectedCategory,
      this.description,
      this.selectedDate.getTime()
    );
    
    const success = await this.dataManager.addRecord(record);
    if (success) {
      router.back();
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .backgroundColor(Color.Transparent)
          .fontColor('#333333')
          .onClick(() => router.back())
        
        Blank()
        
        Text('添加记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Button('保存')
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .onClick(() => this.saveRecord())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      
      Divider().color('#E0E0E0')
      
      Scroll() {
        Column() {
          // 类型选择
          Row() {
            Button('支出')
              .width('45%')
              .height(40)
              .backgroundColor(this.currentType === RecordType.EXPENSE ? '#FF5722' : '#F5F5F5')
              .fontColor(this.currentType === RecordType.EXPENSE ? Color.White : '#333333')
              .onClick(() => this.switchType(RecordType.EXPENSE))
            
            Button('收入')
              .width('45%')
              .height(40)
              .backgroundColor(this.currentType === RecordType.INCOME ? '#4CAF50' : '#F5F5F5')
              .fontColor(this.currentType === RecordType.INCOME ? Color.White : '#333333')
              .onClick(() => this.switchType(RecordType.INCOME))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 20, bottom: 20 })
          
          // 金额输入
          Column() {
            Text('金额')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
            
            TextInput({ placeholder: '请输入金额', text: this.amount })
              .type(InputType.Number)
              .height(50)
              .fontSize(24)
              .fontColor(this.currentType === RecordType.EXPENSE ? '#FF5722' : '#4CAF50')
              .onChange((value: string) => {
                this.amount = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .margin({ bottom: 20 })
          
          // 分类选择
          Column() {
            Text('分类')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
              .margin({ bottom: 12 })
            
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.getCategories(), (category: string) => {
                Button(category)
                  .height(36)
                  .fontSize(14)
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.selectedCategory === category ? 
                    (this.currentType === RecordType.EXPENSE ? '#FF5722' : '#4CAF50') : '#F0F0F0')
                  .fontColor(this.selectedCategory === category ? Color.White : '#333333')
                  .onClick(() => {
                    this.selectedCategory = category;
                  })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .margin({ bottom: 20 })
          
          // 备注
          Column() {
            Text('备注')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
            
            TextArea({ placeholder: '添加备注（可选）', text: this.description })
              .height(80)
              .onChange((value: string) => {
                this.description = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  // 组件生命周期 - 初始化默认分类
  aboutToAppear(): void {
    this.selectedCategory = this.getCategories()[0];
  }
}
