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
}
