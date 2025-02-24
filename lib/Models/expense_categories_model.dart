import 'package:expense_tracker/Constants/icons.dart';
import 'package:flutter/cupertino.dart';


class ExpenseCategories {
  String categoryTitle;
  int entries;
  double totalAmount;
  IconData? icon;

  ExpenseCategories({
    required this.categoryTitle,
    required this.entries,
    required this.totalAmount,
    required this.icon,
  });

  //map to object
  factory ExpenseCategories.fromMap(Map<String, dynamic> pMap) {
    return ExpenseCategories(
      categoryTitle: pMap['category_title'],
      entries: pMap['entries'],
      totalAmount: pMap['total_amount'],
      icon: icons[pMap['category_title']],
    );
  }

  //object to map
  Map<String, dynamic> toMap() {
    return {
      'category_title': categoryTitle,
      'entries': entries,
      'total_amount': totalAmount,
    };
  }
}
