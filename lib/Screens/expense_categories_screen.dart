import 'package:expense_tracker/Database/database_manager.dart';
import 'package:expense_tracker/Models/expense_categories_model.dart';
import 'package:expense_tracker/Screens/all_expenses.dart';
import 'package:expense_tracker/Screens/expenses_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Widgets/bottom_sheet_widget.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  List<ExpenseCategories>? expenseCategoriesList = [];

  double findTotalAmt() {
    double totalAmt = 0.0;
    for (ExpenseCategories vCategory in expenseCategoriesList!) {
      totalAmt += vCategory.totalAmount;
    }
    return totalAmt;
  }

  void fetchExpenseCategoriesFromDB() async {
    DatabaseManager DBManager = DatabaseManager.getInstance();
    List<ExpenseCategories> expenseCategories =
        await DBManager.fetchExpenseCategoriesFromDB();
    setState(() {
      expenseCategoriesList = expenseCategories;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExpenseCategoriesFromDB();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    bool screenOrientation = screenHeight > screenWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your expenses',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.055 : screenHeight * 0.055),),
        centerTitle: true,
      ),
      body: (expenseCategoriesList == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  // pie chart
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: screenOrientation ? screenWidth * 0.50 : screenHeight * 0.50,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Text(
                                    'Total Amount: ₹ ${findTotalAmt()}',
                                    style: TextStyle(
                                        fontSize: screenOrientation ? screenWidth * 0.048 : screenHeight * 0.048,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: screenOrientation ? screenWidth * 0.03 : screenHeight * 0.03,
                                ),
                                ...List.generate(
                                  expenseCategoriesList!.length,
                                  (index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: screenOrientation ? screenWidth * 0.007 : screenHeight * 0.007),
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: screenOrientation ? screenWidth * 0.0165 : screenHeight * 0.0165,
                                              width: screenOrientation ? screenWidth * 0.0165 : screenHeight * 0.0165,
                                              color: Colors.primaries[index],
                                            ),
                                            SizedBox(
                                              width: screenOrientation ? screenWidth * 0.018 : screenHeight * 0.018,
                                            ),
                                            Text(
                                              expenseCategoriesList![index].categoryTitle,
                                              style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.036 : screenHeight * 0.036),
                                            ),
                                            SizedBox(
                                              width: screenOrientation ? screenWidth * 0.018 : screenHeight * 0.018,
                                            ),
                                            Text((findTotalAmt() != 0.0)
                                                ? '${((expenseCategoriesList![index].totalAmount / findTotalAmt()) * 100).toStringAsFixed(2)}%'
                                                : '0.0%',
                                              style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),)
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: screenOrientation ? screenWidth * 0.07 : screenHeight * 0.07,
                                sections: List.generate(
                                  expenseCategoriesList!.length,
                                  (index) {
                                    return PieChartSectionData(
                                      value: (findTotalAmt() != 0.0)
                                          ? expenseCategoriesList![index]
                                              .totalAmount
                                          : null,
                                      color: Colors.primaries[index],
                                      showTitle: false,
                                      radius: screenOrientation ? screenWidth * 0.12 : screenHeight * 0.12,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //view all expense
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Expenses',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.05 : screenHeight * 0.05),),
                        TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllExpenses(),
                                  ));
                              fetchExpenseCategoriesFromDB();
                            },
                            child: Text('View all',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),)),
                      ],
                    ),
                  ),

                  // expense categories
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: expenseCategoriesList!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpensesScreen(
                                      categoryTitle:
                                          expenseCategoriesList![index]
                                              .categoryTitle),
                                ));
                          },
                          leading: Icon(expenseCategoriesList![index].icon,size: screenOrientation ? screenWidth * 0.06 : screenHeight * 0.06,),
                          title:
                              Text(expenseCategoriesList![index].categoryTitle,style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),),
                          subtitle: Text(
                            "entries: ${expenseCategoriesList![index].entries}",
                            style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),
                          ),
                          trailing: Text(
                            '₹ ${expenseCategoriesList![index].totalAmount}',
                            style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.043 : screenHeight * 0.043),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: screenOrientation ? screenWidth * 0.010 : screenHeight * 0.010,bottom: screenOrientation ? screenWidth * 0.015 : screenHeight * 0.015),
        child: SizedBox(
          height: screenOrientation ? screenWidth * 0.165 : screenHeight *0.165,
          width: screenOrientation ? screenWidth * 0.165 : screenHeight * 0.165,
          child: FloatingActionButton(
            elevation: 0.0,
            shape: CircleBorder(),
            backgroundColor: Colors.purple.shade100,
            onPressed: () async {
              bool? flag = await openBottomSheet(context: context);
              if (flag != null) {
                fetchExpenseCategoriesFromDB();
              }
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
