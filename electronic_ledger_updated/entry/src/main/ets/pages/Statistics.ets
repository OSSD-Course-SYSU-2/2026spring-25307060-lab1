import router from '@ohos.router';
import { DataManager, StatisticsData } from '../data/DataManager';

@Entry
@Component
struct Statistics {
  @State currentTab: string = 'today'; // 'today', 'week', 'month', 'year'
  @State todayStats: StatisticsData = { income: 0, expense: 0, balance: 0, count: 0, label: '' };
  @State weekStats: StatisticsData = { income: 0, expense: 0, balance: 0, count: 0, label: '' };
  @State monthStats: StatisticsData = { income: 0, expense: 0, balance: 0, count: 0, label: '' };
  @State yearStats: StatisticsData = { income: 0, expense: 0, balance: 0, count: 0, label: '' };
  @State dailyStats: StatisticsData[] = [];
  @State weeklyStats: StatisticsData[] = [];
  @State monthlyStats: StatisticsData[] = [];
  @State yearlyStats: StatisticsData[] = [];
  
  private dataManager: DataManager = DataManager.getInstance();
  
  // 刷新统计数据
  private refreshStatistics(): void {
    this.todayStats = this.dataManager.getTodayStatistics();
    this.weekStats = this.dataManager.getWeekStatistics();
    this.monthStats = this.dataManager.getMonthStatistics();
    this.yearStats = this.dataManager.getYearStatistics();
    
    this.dailyStats = this.dataManager.getDailyStatistics(7);
    this.weeklyStats = this.dataManager.getWeeklyStatistics(4);
    this.monthlyStats = this.dataManager.getMonthlyStatistics(6);
    this.yearlyStats = this.dataManager.getYearlyStatistics();
  }
  
  // 格式化金额
  private formatAmount(amount: number): string {
    return amount.toFixed(2);
  }
  
  // 获取当前统计
  private getCurrentStats(): StatisticsData {
    switch (this.currentTab) {
      case 'today':
        return this.todayStats;
      case 'week':
        return this.weekStats;
      case 'month':
        return this.monthStats;
      case 'year':
        return this.yearStats;
      default:
        return this.todayStats;
    }
  }
  
  // 获取趋势数据
  private getTrendData(): StatisticsData[] {
    switch (this.currentTab) {
      case 'today':
        return this.dailyStats;
      case 'week':
        return this.weeklyStats;
      case 'month':
        return this.monthlyStats;
      case 'year':
        return this.yearlyStats;
      default:
        return this.dailyStats;
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .backgroundColor(Color.Transparent)
          .fontColor('#333333')
          .onClick(() => router.back())
        
        Blank()
        
        Text('统计分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text('  ')
          .width(48)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      
      Divider().color('#E0E0E0')
      
      // 时间维度选择
      Row() {
        Button('今日')
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTab === 'today' ? '#667eea' : '#F0F0F0')
          .fontColor(this.currentTab === 'today' ? Color.White : '#333333')
          .onClick(() => { this.currentTab = 'today'; })
        
        Button('本周')
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTab === 'week' ? '#667eea' : '#F0F0F0')
          .fontColor(this.currentTab === 'week' ? Color.White : '#333333')
          .onClick(() => { this.currentTab = 'week'; })
        
        Button('本月')
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTab === 'month' ? '#667eea' : '#F0F0F0')
          .fontColor(this.currentTab === 'month' ? Color.White : '#333333')
          .onClick(() => { this.currentTab = 'month'; })
        
        Button('本年')
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTab === 'year' ? '#667eea' : '#F0F0F0')
          .fontColor(this.currentTab === 'year' ? Color.White : '#333333')
          .onClick(() => { this.currentTab = 'year'; })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#FAFAFA')
      
      Scroll() {
        Column() {
          // 当前统计概览
          Column() {
            Text(this.getTimeLabel())
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 16 })
            
            Row() {
              Column() {
                Text('收入')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.formatAmount(this.getCurrentStats().income)}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4CAF50')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              
              Column() {
                Text('支出')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.formatAmount(this.getCurrentStats().expense)}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF5722')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              
              Column() {
                Text('结余')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.formatAmount(this.getCurrentStats().balance)}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getCurrentStats().balance >= 0 ? '#2196F3' : '#F44336')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
            
            Text(`共 ${this.getCurrentStats().count} 笔记录`)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 16 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, left: 16, right: 16 })
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
          
          // 收支比例
          if (this.getCurrentStats().income > 0 || this.getCurrentStats().expense > 0) {
            Column() {
              Text('收支比例')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 16 })
              
              Row() {
                Text('收入')
                  .fontSize(12)
                  .fontColor('#999999')
                
                Row()
                  .height(24)
                  .layoutWeight(1)
                  .backgroundColor('#E8F5E9')
                  .borderRadius(4)
                  
                Text(`${this.getIncomePercentage()}%`)
                  .fontSize(12)
                  .fontColor('#4CAF50')
                  .width(48)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              
              Row() {
                Text('支出')
                  .fontSize(12)
                  .fontColor('#999999')
                
                Row()
                  .height(24)
                  .layoutWeight(1)
                  .backgroundColor('#FFEBEE')
                  .borderRadius(4)
                  
                Text(`${this.getExpensePercentage()}%`)
                  .fontSize(12)
                  .fontColor('#FF5722')
                  .width(48)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ top: 16, left: 16, right: 16 })
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
          }
          
          // 趋势图表
          Column() {
            Text(this.getTrendTitle())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 16 })
            
            if (this.getTrendData().length === 0) {
              Text('暂无数据')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .height(100)
                .textAlign(TextAlign.Center)
            } else {
              ForEach(this.getTrendData(), (stats: StatisticsData) => {
                Row() {
                  Text(stats.label)
                    .fontSize(12)
                    .fontColor('#666666')
                    .width(80)
                  
                  Column() {
                    Row() {
                      if (stats.income > 0) {
                        Row()
                          .height(16)
                          .width(`${this.getBarWidth(stats.income)}%`)
                          .backgroundColor('#4CAF50')
                          .borderRadius(2)
                      }
                    }
                    .width('100%')
                    .margin({ bottom: 4 })
                    
                    Row() {
                      if (stats.expense > 0) {
                        Row()
                          .height(16)
                          .width(`${this.getBarWidth(stats.expense)}%`)
                          .backgroundColor('#FF5722')
                          .borderRadius(2)
                      }
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text(`+${this.formatAmount(stats.income)}`)
                      .fontSize(10)
                      .fontColor('#4CAF50')
                    Text(`-${this.formatAmount(stats.expense)}`)
                      .fontSize(10)
                      .fontColor('#FF5722')
                      .margin({ top: 2 })
                  }
                  .width(70)
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .margin({ bottom: 12 })
              })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, left: 16, right: 16, bottom: 16 })
          .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#FAFAFA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  // 获取时间标签
  private getTimeLabel(): string {
    switch (this.currentTab) {
      case 'today':
        return '今日统计';
      case 'week':
        return '本周统计';
      case 'month':
        return '本月统计';
      case 'year':
        return '本年统计';
      default:
        return '今日统计';
    }
  }
  
  // 获取趋势标题
  private getTrendTitle(): string {
    switch (this.currentTab) {
      case 'today':
        return '最近7天趋势';
      case 'week':
        return '最近4周趋势';
      case 'month':
        return '最近6个月趋势';
      case 'year':
        return '年度统计';
      default:
        return '趋势';
    }
  }
  
  // 计算收入百分比
  private getIncomePercentage(): number {
    const total = this.getCurrentStats().income + this.getCurrentStats().expense;
    if (total === 0) return 0;
    return Math.round((this.getCurrentStats().income / total) * 100);
  }
  
  // 计算支出百分比
  private getExpensePercentage(): number {
    const total = this.getCurrentStats().income + this.getCurrentStats().expense;
    if (total === 0) return 0;
    return Math.round((this.getCurrentStats().expense / total) * 100);
  }
  
  // 计算柱状图宽度
  private getBarWidth(amount: number): number {
    const maxValue = Math.max(
      ...this.getTrendData().map(s => Math.max(s.income, s.expense))
    );
    if (maxValue === 0) return 0;
    return Math.round((amount / maxValue) * 100);
  }
  
  // 页面显示时刷新数据
  aboutToAppear(): void {
    this.refreshStatistics();
  }
  
  onPageShow(): void {
    this.refreshStatistics();
  }
}
