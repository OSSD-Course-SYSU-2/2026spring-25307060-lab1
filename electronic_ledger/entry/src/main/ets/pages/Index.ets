import router from '@ohos.router';
import { RecordItem, RecordType } from '../model/RecordItem';
import { DataManager } from '../data/DataManager';

@Entry
@Component
struct Index {
  @State records: RecordItem[] = [];
  @State totalIncome: number = 0;
  @State totalExpense: number = 0;
  @State balance: number = 0;
  @State filterType: string = 'all'; // 'all', 'income', 'expense'
  
  private dataManager: DataManager = DataManager.getInstance();
  
  // 刷新数据
  private refreshData(): void {
    this.records = this.dataManager.getAllRecords();
    this.totalIncome = this.dataManager.getTotalIncome();
    this.totalExpense = this.dataManager.getTotalExpense();
    this.balance = this.dataManager.getBalance();
  }
  
  // 格式化金额
  private formatAmount(amount: number): string {
    return amount.toFixed(2);
  }
  
  // 格式化日期
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }
  
  // 根据筛选条件获取记录
  private getFilteredRecords(): RecordItem[] {
    if (this.filterType === 'income') {
      return this.records.filter(record => record.type === RecordType.INCOME);
    } else if (this.filterType === 'expense') {
      return this.records.filter(record => record.type === RecordType.EXPENSE);
    }
    return this.records;
  }
  
  // 删除记录
  private async deleteRecord(id: string): Promise<void> {
    await this.dataManager.deleteRecord(id);
    this.refreshData();
  }
  
  build() {
    Column() {
      // 顶部统计卡片
      Column() {
        Text('电子记账本')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 20 })
        
        Row() {
          Column() {
            Text('收入')
              .fontSize(12)
              .fontColor('#E8F5E9')
            Text(`¥${this.formatAmount(this.totalIncome)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          
          Column() {
            Text('支出')
              .fontSize(12)
              .fontColor('#FFEBEE')
            Text(`¥${this.formatAmount(this.totalExpense)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          
          Column() {
            Text('结余')
              .fontSize(12)
              .fontColor('#E3F2FD')
            Text(`¥${this.formatAmount(this.balance)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .linearGradient({
        angle: 135,
        colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
      })
      
      // 筛选栏
      Row() {
        Button('全部')
          .height(32)
          .fontSize(14)
          .backgroundColor(this.filterType === 'all' ? '#667eea' : '#F0F0F0')
          .fontColor(this.filterType === 'all' ? Color.White : '#333333')
          .onClick(() => {
            this.filterType = 'all';
          })
        
        Button('收入')
          .height(32)
          .fontSize(14)
          .backgroundColor(this.filterType === 'income' ? '#4CAF50' : '#F0F0F0')
          .fontColor(this.filterType === 'income' ? Color.White : '#333333')
          .onClick(() => {
            this.filterType = 'income';
          })
        
        Button('支出')
          .height(32)
          .fontSize(14)
          .backgroundColor(this.filterType === 'expense' ? '#FF5722' : '#F0F0F0')
          .fontColor(this.filterType === 'expense' ? Color.White : '#333333')
          .onClick(() => {
            this.filterType = 'expense';
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#FAFAFA')
      
      // 记录列表
      if (this.getFilteredRecords().length === 0) {
        Column() {
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 100 })
          
          Text('点击右下角按钮添加记账记录')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        List() {
          ForEach(this.getFilteredRecords(), (record: RecordItem) => {
            ListItem() {
              Row() {
                // 分类图标
                Column() {
                  Text(record.category.substring(0, 1))
                    .fontSize(20)
                    .fontColor(Color.White)
                }
                .width(48)
                .height(48)
                .borderRadius(24)
                .backgroundColor(record.type === RecordType.INCOME ? '#4CAF50' : '#FF5722')
                .justifyContent(FlexAlign.Center)
                
                // 记录信息
                Column() {
                  Row() {
                    Text(record.category)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    
                    Blank()
                    
                    Text(`${record.type === RecordType.INCOME ? '+' : '-'}¥${this.formatAmount(record.amount)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(record.type === RecordType.INCOME ? '#4CAF50' : '#FF5722')
                  }
                  .width('100%')
                  
                  Row() {
                    Text(record.description || '无备注')
                      .fontSize(12)
                      .fontColor('#999999')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    
                    Blank()
                    
                    Text(this.formatDate(record.date))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .padding({ left: 12 })
                .alignItems(HorizontalAlign.Start)
                
                // 删除按钮
                Button('删除')
                  .height(32)
                  .fontSize(12)
                  .backgroundColor('#FFEBEE')
                  .fontColor('#FF5722')
                  .onClick(() => this.deleteRecord(record.id))
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 8 })
            }
          })
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .backgroundColor('#FAFAFA')
      }
      
      // 添加按钮
      Row() {
        Blank()
        
        Button() {
          Text('+')
            .fontSize(32)
            .fontColor(Color.White)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#667eea')
        .shadow({ radius: 8, color: '#667eea', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddRecord' });
        })
      }
      .width('100%')
      .padding({ right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  // 组件生命周期 - 初始化时加载数据
  aboutToAppear(): void {
    this.refreshData();
  }
  
  // 页面显示时刷新数据
  onPageShow(): void {
    this.refreshData();
  }
}
