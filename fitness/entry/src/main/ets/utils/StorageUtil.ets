import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { ExerciseRecord, ExerciseRecordJson } from '../model/ExerciseRecord';
import common from '@ohos.app.ability.common';

const STORE_NAME = 'fitness_store';
const RECORDS_KEY = 'exercise_records';

class StorageUtil {
  private static instance: StorageUtil | null = null;
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  static async getInstance(context: common.UIAbilityContext): Promise<StorageUtil> {
    if (!StorageUtil.instance) {
      StorageUtil.instance = new StorageUtil();
      await StorageUtil.instance.init(context);
    }
    return StorageUtil.instance;
  }

  private async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.context = context;
      this.preferences = await preferences.getPreferences(context, STORE_NAME);
    } catch (err) {
      console.error(`Failed to get preferences: ${JSON.stringify(err)}`);
    }
  }

  async saveRecord(record: ExerciseRecord): Promise<void> {
    const records = await this.getAllRecords();
    records.push(record);
    await this.saveAllRecords(records);
  }

  async updateRecord(record: ExerciseRecord): Promise<void> {
    const records = await this.getAllRecords();
    const index = records.findIndex(r => r.id === record.id);
    if (index >= 0) {
      records[index] = record;
      await this.saveAllRecords(records);
    }
  }

  async deleteRecord(id: string): Promise<void> {
    const records = await this.getAllRecords();
    const filtered = records.filter(r => r.id !== id);
    await this.saveAllRecords(filtered);
  }

  async getAllRecords(): Promise<ExerciseRecord[]> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return [];
    }
    try {
      const recordsJson = await this.preferences.get(RECORDS_KEY, '[]') as string;
      const recordsArray = JSON.parse(recordsJson) as ExerciseRecordJson[];
      return recordsArray.map((json: ExerciseRecordJson) => ExerciseRecord.fromJson(json));
    } catch (err) {
      console.error(`Failed to get records: ${JSON.stringify(err)}`);
      return [];
    }
  }

  async clearAllRecords(): Promise<void> {
    await this.saveAllRecords([]);
  }

  private async saveAllRecords(records: ExerciseRecord[]): Promise<void> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return;
    }
    const recordsJson = JSON.stringify(records.map(r => r.toJson()));
    await this.preferences.put(RECORDS_KEY, recordsJson);
    await this.preferences.flush();
  }
}

export default StorageUtil;