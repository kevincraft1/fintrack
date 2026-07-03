import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'models/wallet.dart';
import 'models/budget.dart';
import 'models/debt.dart';
import 'models/goal.dart'; // Import model Impian

class DatabaseService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open(
        [
          TransactionSchema,
          CategorySchema,
          WalletSchema,
          BudgetSchema,
          DebtSchema,
          GoalSchema // Daftarkan schema Impian
        ],
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
          ..type = 'income'
          ..colorHex = '#10B981',
        Category()
          ..name = 'Bonus'
          ..iconName = 'card_giftcard'
          ..type = 'income'
          ..colorHex = '#3B82F6',
        Category()
          ..name = 'Investasi'
          ..iconName = 'trending_up'
          ..type = 'income'
          ..colorHex = '#8B5CF6',
        Category()
          ..name = 'Makanan'
          ..iconName = 'restaurant'
          ..type = 'expense'
          ..colorHex = '#F59E0B',
        Category()
          ..name = 'Transportasi'
          ..iconName = 'directions_car'
          ..type = 'expense'
          ..colorHex = '#3B82F6',
        Category()
          ..name = 'Belanja'
          ..iconName = 'shopping_bag'
          ..type = 'expense'
          ..colorHex = '#EC4899',
        Category()
          ..name = 'Tagihan'
          ..iconName = 'receipt'
          ..type = 'expense'
          ..colorHex = '#EF4444',
        Category()
          ..name = 'Hiburan'
          ..iconName = 'movie'
          ..type = 'expense'
          ..colorHex = '#8B5CF6',
        Category()
          ..name = 'Lainnya'
          ..iconName = 'more_horiz'
          ..type = 'expense'
          ..colorHex = '#9CA3AF',
      ];
      await isar
          .writeTxn(() async => await isar.categorys.putAll(defaultCategories));
    }

    final walletCount = await isar.wallets.count();
    if (walletCount == 0) {
      final defaultWallet = Wallet()
        ..name = 'Uang Tunai'
        ..iconName = 'account_balance_wallet'
        ..initialBalance = 0.0
        ..balance = 0.0;
      await isar.writeTxn(() async => await isar.wallets.put(defaultWallet));
    }
  }
}
