import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/category.dart';
import 'models/transaction.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [CategorySchema, TransactionSchema],
      directory: dir.path,
    );

    if (await isar.categorys.count() == 0) {
      final categories = [
        Category()
          ..name = 'Makan'
          ..type = 'expense'
          ..iconName = 'fastfood',
        Category()
          ..name = 'Transport'
          ..type = 'expense'
          ..iconName = 'directions_car',
        Category()
          ..name = 'Tagihan'
          ..type = 'expense'
          ..iconName = 'receipt',
        Category()
          ..name = 'Hiburan'
          ..type = 'expense'
          ..iconName = 'sports_esports',
        Category()
          ..name = 'Gaji'
          ..type = 'income'
          ..iconName = 'account_balance_wallet',
        Category()
          ..name = 'Bonus'
          ..type = 'income'
          ..iconName = 'card_giftcard',
        Category()
          ..name = 'Investasi'
          ..type = 'income'
          ..iconName = 'trending_up',
      ];

      await isar.writeTxn(() async {
        await isar.categorys.putAll(categories);
      });
    }
  }
}
