import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'models/wallet.dart';
import 'models/budget.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [TransactionSchema, CategorySchema, WalletSchema, BudgetSchema],
        directory: dir.path,
      );
    } else {
      isar = Isar.getInstance()!;
    }

    await _seedDefaultData();
  }

  static Future<void> _seedDefaultData() async {
    final categoryCount = await isar.categorys.count();

    if (categoryCount == 0) {
      final defaultCategories = [
        Category()
          ..name = 'Gaji'
          ..iconName = 'attach_money'
          ..type = 'income',
        Category()
          ..name = 'Bonus'
          ..iconName = 'card_giftcard'
          ..type = 'income',
        Category()
          ..name = 'Investasi'
          ..iconName = 'trending_up'
          ..type = 'income',
        Category()
          ..name = 'Makanan'
          ..iconName = 'restaurant'
          ..type = 'expense',
        Category()
          ..name = 'Transportasi'
          ..iconName = 'directions_car'
          ..type = 'expense',
        Category()
          ..name = 'Belanja'
          ..iconName = 'shopping_bag'
          ..type = 'expense',
        Category()
          ..name = 'Tagihan'
          ..iconName = 'receipt'
          ..type = 'expense',
        Category()
          ..name = 'Hiburan'
          ..iconName = 'movie'
          ..type = 'expense',
        Category()
          ..name = 'Lainnya'
          ..iconName = 'more_horiz'
          ..type = 'expense',
      ];
      await isar
          .writeTxn(() async => await isar.categorys.putAll(defaultCategories));
    }

    final walletCount = await isar.wallets.count();
    if (walletCount == 0) {
      final defaultWallet = Wallet()
        ..name = 'Uang Tunai'
        ..iconName = 'account_balance_wallet'
        ..initialBalance = 0.0;
      await isar.writeTxn(() async => await isar.wallets.put(defaultWallet));
    }
  }
}
