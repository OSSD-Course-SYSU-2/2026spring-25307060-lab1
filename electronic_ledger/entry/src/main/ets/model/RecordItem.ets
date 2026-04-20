// 记账记录数据模型
export class RecordItem {
  id: string = '';           // 记录唯一标识
  type: RecordType = RecordType.EXPENSE;  // 记录类型：收入/支出
  amount: number = 0;        // 金额
  category: string = '';     // 分类
  description: string = '';  // 描述/备注
  date: number = 0;          // 记录时间戳
  
  constructor(
    id: string,
    type: RecordType,
    amount: number,
    category: string,
    description: string,
    date: number
  ) {
    this.id = id;
    this.type = type;
    this.amount = amount;
    this.category = category;
    this.description = description;
    this.date = date;
  }
  
  // 从JSON对象创建实例
  static fromJson(json: Record<string, Object>): RecordItem {
    return new RecordItem(
      json['id'] as string,
      json['type'] as RecordType,
      json['amount'] as number,
      json['category'] as string,
      json['description'] as string,
      json['date'] as number
    );
  }
  
  // 转换为JSON对象
  toJson(): Record<string, Object> {
    return {
      'id': this.id,
      'type': this.type,
      'amount': this.amount,
      'category': this.category,
      'description': this.description,
      'date': this.date
    };
  }
}

// 记录类型枚举
export enum RecordType {
  INCOME = 'income',    // 收入
  EXPENSE = 'expense'   // 支出
}

// 支出分类
export const EXPENSE_CATEGORIES: string[] = [
  '餐饮',
  '交通',
  '购物',
  '娱乐',
  '医疗',
  '教育',
  '住房',
  '通讯',
  '其他'
];

// 收入分类
export const INCOME_CATEGORIES: string[] = [
  '工资',
  '奖金',
  '投资',
  '兼职',
  '礼金',
  '其他'
];
