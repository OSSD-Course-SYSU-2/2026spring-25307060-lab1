import dataPreferences from '@ohos.data.preferences';
import { RecordItem, RecordType } from '../model/RecordItem';

// 数据管理类 - 负责记账数据的持久化存储和管理
export class DataManager {
  private static instance: DataManager | null = null;
  private preferences: dataPreferences.Preferences | null = null;
  private records: RecordItem[] = [];
  private readonly RECORDS_KEY = 'ledger_records';
  
  private constructor() {}
  
  // 获取单例实例
  static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager();
    }
    return DataManager.instance;
  }
  
  // 初始化数据管理器
  async init(context: Context): Promise<void> {
    try {
      const preferencesName = 'electronic_ledger';
      this.preferences = await dataPreferences.getPreferences(context, preferencesName);
      await this.loadRecords();
    } catch (error) {
      console.error('DataManager init failed:', error);
    }
  }
  
  // 从持久化存储加载记录
  private async loadRecords(): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      const recordsJson = await this.preferences.get(this.RECORDS_KEY, '[]') as string;
      const recordsArray = JSON.parse(recordsJson) as Record<string, Object>[];
      this.records = recordsArray.map((json: Record<string, Object>) => RecordItem.fromJson(json));
      // 按时间倒序排列
      this.records.sort((a, b) => b.date - a.date);
    } catch (error) {
      console.error('Load records failed:', error);
      this.records = [];
    }
  }
  
  // 保存记录到持久化存储
  private async saveRecords(): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      const recordsJson = JSON.stringify(this.records.map(record => record.toJson()));
      await this.preferences.put(this.RECORDS_KEY, recordsJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Save records failed:', error);
    }
  }
  
  // 获取所有记录
  getAllRecords(): RecordItem[] {
    return this.records;
  }
  
  // 添加新记录
  async addRecord(record: RecordItem): Promise<boolean> {
    try {
      this.records.unshift(record); // 添加到开头
      await this.saveRecords();
      return true;
    } catch (error) {
      console.error('Add record failed:', error);
      return false;
    }
  }
  
  // 删除记录
  async deleteRecord(id: string): Promise<boolean> {
    try {
      const index = this.records.findIndex(record => record.id === id);
      if (index !== -1) {
        this.records.splice(index, 1);
        await this.saveRecords();
        return true;
      }
      return false;
    } catch (error) {
      console.error('Delete record failed:', error);
      return false;
    }
  }
  
  // 获取总收入
  getTotalIncome(): number {
    return this.records
      .filter(record => record.type === RecordType.INCOME)
      .reduce((sum, record) => sum + record.amount, 0);
  }
  
  // 获取总支出
  getTotalExpense(): number {
    return this.records
      .filter(record => record.type === RecordType.EXPENSE)
      .reduce((sum, record) => sum + record.amount, 0);
  }
  
  // 获取结余
  getBalance(): number {
    return this.getTotalIncome() - this.getTotalExpense();
  }
  
  // 根据类型筛选记录
  getRecordsByType(type: RecordType): RecordItem[] {
    return this.records.filter(record => record.type === type);
  }
  
  // 生成唯一ID
  static generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }
  
  // 获取指定日期范围内的记录
  getRecordsByDateRange(startDate: Date, endDate: Date): RecordItem[] {
    const startTime = startDate.getTime();
    const endTime = endDate.getTime();
    return this.records.filter(record => record.date >= startTime && record.date <= endTime);
  }
  
  // 获取今日统计
  getTodayStatistics(): StatisticsData {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    return this.calculateStatistics(this.getRecordsByDateRange(today, tomorrow));
  }
  
  // 获取本周统计（周一至周日）
  getWeekStatistics(): StatisticsData {
    const now = new Date();
    const dayOfWeek = now.getDay() || 7; // 将周日的0转换为7
    const monday = new Date(now);
    monday.setDate(now.getDate() - dayOfWeek + 1);
    monday.setHours(0, 0, 0, 0);
    
    const nextMonday = new Date(monday);
    nextMonday.setDate(monday.getDate() + 7);
    
    return this.calculateStatistics(this.getRecordsByDateRange(monday, nextMonday));
  }
  
  // 获取本月统计
  getMonthStatistics(): StatisticsData {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 1);
    
    return this.calculateStatistics(this.getRecordsByDateRange(firstDay, lastDay));
  }
  
  // 获取本年统计
  getYearStatistics(): StatisticsData {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), 0, 1);
    const lastDay = new Date(now.getFullYear() + 1, 0, 1);
    
    return this.calculateStatistics(this.getRecordsByDateRange(firstDay, lastDay));
  }
  
  // 获取每日统计（最近N天）
  getDailyStatistics(days: number): StatisticsData[] {
    const result: StatisticsData[] = [];
    const now = new Date();
    
    for (let i = 0; i < days; i++) {
      const date = new Date(now);
      date.setDate(now.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const nextDate = new Date(date);
      nextDate.setDate(date.getDate() + 1);
      
      const stats = this.calculateStatistics(this.getRecordsByDateRange(date, nextDate));
      stats.label = this.formatDateLabel(date, 'day');
      result.push(stats);
    }
    
    return result.reverse();
  }
  
  // 获取每周统计（最近N周）
  getWeeklyStatistics(weeks: number): StatisticsData[] {
    const result: StatisticsData[] = [];
    const now = new Date();
    
    for (let i = 0; i < weeks; i++) {
      const dayOfWeek = now.getDay() || 7;
      const monday = new Date(now);
      monday.setDate(now.getDate() - dayOfWeek + 1 - i * 7);
      monday.setHours(0, 0, 0, 0);
      
      const nextMonday = new Date(monday);
      nextMonday.setDate(monday.getDate() + 7);
      
      const stats = this.calculateStatistics(this.getRecordsByDateRange(monday, nextMonday));
      stats.label = this.formatDateLabel(monday, 'week');
      result.push(stats);
    }
    
    return result.reverse();
  }
  
  // 获取每月统计（最近N个月）
  getMonthlyStatistics(months: number): StatisticsData[] {
    const result: StatisticsData[] = [];
    const now = new Date();
    
    for (let i = 0; i < months; i++) {
      const firstDay = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const lastDay = new Date(now.getFullYear(), now.getMonth() - i + 1, 1);
      
      const stats = this.calculateStatistics(this.getRecordsByDateRange(firstDay, lastDay));
      stats.label = this.formatDateLabel(firstDay, 'month');
      result.push(stats);
    }
    
    return result.reverse();
  }
  
  // 获取每年统计
  getYearlyStatistics(): StatisticsData[] {
    const result: StatisticsData[] = [];
    const years = new Set<number>();
    
    this.records.forEach(record => {
      const date = new Date(record.date);
      years.add(date.getFullYear());
    });
    
    const sortedYears = Array.from(years).sort((a, b) => a - b);
    
    sortedYears.forEach(year => {
      const firstDay = new Date(year, 0, 1);
      const lastDay = new Date(year + 1, 0, 1);
      
      const stats = this.calculateStatistics(this.getRecordsByDateRange(firstDay, lastDay));
      stats.label = `${year}年`;
      result.push(stats);
    });
    
    return result;
  }
  
  // 计算统计数据
  private calculateStatistics(records: RecordItem[]): StatisticsData {
    const income = records
      .filter(r => r.type === RecordType.INCOME)
      .reduce((sum, r) => sum + r.amount, 0);
    
    const expense = records
      .filter(r => r.type === RecordType.EXPENSE)
      .reduce((sum, r) => sum + r.amount, 0);
    
    return {
      income: income,
      expense: expense,
      balance: income - expense,
      count: records.length,
      label: ''
    };
  }
  
  // 格式化日期标签
  private formatDateLabel(date: Date, type: string): string {
    if (type === 'day') {
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    } else if (type === 'week') {
      const endDay = new Date(date);
      endDay.setDate(date.getDate() + 6);
      return `${date.getMonth() + 1}/${date.getDate()}-${endDay.getMonth() + 1}/${endDay.getDate()}`;
    } else if (type === 'month') {
      return `${date.getFullYear()}年${date.getMonth() + 1}月`;
    }
    return '';
  }
}

// 统计数据结构
export interface StatisticsData {
  income: number;      // 收入
  expense: number;     // 支出
  balance: number;     // 结余
  count: number;       // 记录数
  label: string;       // 时间标签
}
