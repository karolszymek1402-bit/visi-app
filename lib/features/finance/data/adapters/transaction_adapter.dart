import 'package:hive/hive.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  static const hiveTypeId = 4;

  @override
  int get typeId => hiveTypeId;

  @override
  Transaction read(BinaryReader reader) {
    final json = (reader.read() as Map).cast<String, dynamic>();
    return Transaction.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.toJson());
  }
}
