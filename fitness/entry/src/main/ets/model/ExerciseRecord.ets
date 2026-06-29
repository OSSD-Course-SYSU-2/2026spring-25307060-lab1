export interface ExerciseRecordJson {
  id: string;
  type: string;
  duration: number;
  date: string;
  note?: string;
}

export class ExerciseRecord {
  id: string;
  type: string;
  duration: number; // in minutes
  date: string; // ISO string format
  note?: string;

  constructor(type: string, duration: number, date: string, note?: string) {
    this.id = new Date().getTime().toString() + Math.random().toString(36).substring(2);
    this.type = type;
    this.duration = duration;
    this.date = date;
    this.note = note;
  }

  static fromJson(json: ExerciseRecordJson): ExerciseRecord {
    const record = new ExerciseRecord(json.type, json.duration, json.date, json.note);
    record.id = json.id;
    return record;
  }

  toJson(): ExerciseRecordJson {
    return {
      id: this.id,
      type: this.type,
      duration: this.duration,
      date: this.date,
      note: this.note
    };
  }
}