class Expense {
  int id;
  String expenseTitle;
  double amount;
  String date;
  String expenseCategory;

  Expense({
    required this.id,
    required this.expenseTitle,
    required this.amount,
    required this.date,
    required this.expenseCategory,
  });

  //Object to Map
  Map<String, dynamic> toMap() {
    return {
      'expense_title': expenseTitle,
      'amount': amount,
      'date': date,
      'expense_category': expenseCategory
    };
  }

  // Map to Object
  factory Expense.fromMap(Map<String, dynamic> pMap) {
    return Expense(
      id: pMap['expense_id'],
      expenseTitle: pMap['expense_title'],
      amount: pMap['amount'],
      date: pMap['date'],
      expenseCategory: pMap['expense_category'],
    );
  }
}
