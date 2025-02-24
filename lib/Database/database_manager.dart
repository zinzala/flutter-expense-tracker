import 'dart:developer';
import 'dart:io';
import 'package:expense_tracker/Constants/icons.dart';
import 'package:expense_tracker/Models/expense_categories_model.dart';
import 'package:expense_tracker/Models/expense_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  ///singleton
  DatabaseManager._private();

  static final DatabaseManager _instance = DatabaseManager._private();

  factory DatabaseManager.getInstance() => _instance;

  // for expense categories table
  static const EXPENSE_CATEGORY_TABL = 'Expense_Categories';
  static const EXPENSE_CATEGORY_TITLE_COLM = 'category_title';
  static const EXPENSE_CATEGORY_ENTRIES_COLM = 'entries';
  static const EXPENSE_CATEGORY_TOTAL_AMT_COLM = 'total_amount';

  // for expense table
  static const EXPENSE_TABL = "Expense";
  static const EXPENSE_TABL_ID_COLM = 'expense_id';
  static const EXPENSE_TABL_TITLE_COLM = 'expense_title';
  static const EXPENSE_TABL_AMOUNT_COLM = 'amount';
  static const EXPENSE_TABL_DATE_COLM = 'date';
  static const EXPENSE_TABL_CATEGORY_COLM = 'expense_category';

  Database? database;

  Future<Database> getDB() async {
    return database ?? openDB();
  }

  Future<Database> openDB() async {
    Directory databaseDirectory = await getApplicationDocumentsDirectory();
    String databasePath = join(databaseDirectory.path, "ExpenseDataBase.db");
    Database database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $EXPENSE_CATEGORY_TABL(
        $EXPENSE_CATEGORY_TITLE_COLM TEXT,
        $EXPENSE_CATEGORY_ENTRIES_COLM INTEGER,
        $EXPENSE_CATEGORY_TOTAL_AMT_COLM REAL)
        ''');

        await db.execute('''CREATE TABLE $EXPENSE_TABL(
        $EXPENSE_TABL_ID_COLM INTEGER PRIMARY KEY AUTOINCREMENT,
        $EXPENSE_TABL_TITLE_COLM TEXT,
        $EXPENSE_TABL_AMOUNT_COLM REAL,
        $EXPENSE_TABL_DATE_COLM TEXT,
        $EXPENSE_TABL_CATEGORY_COLM TEXT)
        ''');

        for (int i = 0; i < icons.length; i++) {
          await db.insert(EXPENSE_CATEGORY_TABL, {
            EXPENSE_CATEGORY_TITLE_COLM: icons.keys.toList()[i],
            EXPENSE_CATEGORY_ENTRIES_COLM: 0,
            EXPENSE_CATEGORY_TOTAL_AMT_COLM: 0.0,
          });
        }
      },
    );
    return database;
  }

  // All queries

  // fetching ExpenseCategories from database
  Future<List<ExpenseCategories>> fetchExpenseCategoriesFromDB() async {
    List<ExpenseCategories> expenseCategoriesList = [];
    var db = await getDB();
    List<Map<String, dynamic>> expenseCategories =
        await db.query(EXPENSE_CATEGORY_TABL);
    for (Map<String, dynamic> map in expenseCategories) {
      ExpenseCategories expenseCategories = ExpenseCategories.fromMap(map);
      expenseCategoriesList.add(expenseCategories);
    }
    return expenseCategoriesList;
  }

  //add expense in database
  Future<void> addExpense({required Expense pExpense}) async {
    Database db = await getDB();
    try{
      await db.insert(EXPENSE_TABL, pExpense.toMap());
      ExpenseCategories vExpenseCategory = await calculateEntriesAndTotalAmount(pCategoryTitle: pExpense.expenseCategory);
      updateExpenseCategories(pCategoryTitle: pExpense.expenseCategory, pEntry: vExpenseCategory.entries + 1, pAmount: vExpenseCategory.totalAmount + pExpense.amount);
    }catch(e){
      log('error',name: 'addExpense_catchBlock', error: e);
    }
  }

  // for calculating entries and total amount
  Future<ExpenseCategories> calculateEntriesAndTotalAmount(
      {required String pCategoryTitle}) async {
    ExpenseCategories vExpenseCategory;
    List<ExpenseCategories> vExpenseCategoryList =
        await fetchExpenseCategoriesFromDB();
    vExpenseCategory = vExpenseCategoryList.firstWhere(
      (element) => element.categoryTitle == pCategoryTitle,
    );
    return vExpenseCategory;
  }

  // after adding expense we need to update expense_categories table
  void updateExpenseCategories(
      {required String pCategoryTitle,
      required int pEntry,
      required double pAmount}) async {
    Database db = await getDB();
    db.update(
        EXPENSE_CATEGORY_TABL,
        {
          EXPENSE_CATEGORY_ENTRIES_COLM: pEntry,
          EXPENSE_CATEGORY_TOTAL_AMT_COLM: pAmount,
        },
        where: '$EXPENSE_CATEGORY_TITLE_COLM = ?',
        whereArgs: [pCategoryTitle]);
  }

  // fetch expense from DB
   Future<List<Expense>> fetchExpense({required String pExpenseCategory}) async {
    List<Expense> vExpensesList = [];
    Database db = await getDB();
    List<Map<String,dynamic>> vReceivedExpensesList = await db.query(EXPENSE_TABL, where: '$EXPENSE_TABL_CATEGORY_COLM = ?', whereArgs: [pExpenseCategory]);
    for(Map<String,dynamic> vMap in vReceivedExpensesList){
       Expense vExpense = Expense.fromMap(vMap);
       vExpensesList.add(vExpense);
    }
    return vExpensesList;
  }

  // fetch all expense
  Future<List<Expense>> fetchAllExpense() async{
    List<Expense> vExpensesList = [];
    Database db = await getDB();
    List<Map<String,dynamic>> vFetchedExpense = await db.query(EXPENSE_TABL);
    for(Map<String,dynamic> vMap in vFetchedExpense){
       Expense vExpense = Expense.fromMap(vMap);
       vExpensesList.add(vExpense);
    }
    return vExpensesList;
  }

  // delete expense
  Future<void> deleteExpense({required String category,required double amount,required int id}) async {
    Database db = await getDB();
    db.delete(EXPENSE_TABL, where: '$EXPENSE_TABL_ID_COLM = ?', whereArgs: ['$id']);
    ExpenseCategories oExpenseCategories = await calculateEntriesAndTotalAmount(pCategoryTitle: category);
    updateExpenseCategories(pCategoryTitle: category, pEntry: oExpenseCategories.entries - 1, pAmount: oExpenseCategories.totalAmount - amount);
  }


}
