import 'package:expense_tracker/AppUtils/app_utils.dart';
import 'package:expense_tracker/Constants/icons.dart';
import 'package:expense_tracker/Database/database_manager.dart';
import 'package:expense_tracker/Models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  ExpensesScreen({super.key, required this.categoryTitle});

  String categoryTitle;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> barChartList = [];
  List<Expense>? vExpensesList = [];

  double findTotalAmt() {
    double totalAmt = 0.0;
    for (Expense vExpense in vExpensesList!) {
      totalAmt += vExpense.amount;
    }
    return totalAmt;
  }

  // init
  @override
  void initState() {
    super.initState();
    fetchExpensesFromDB();
  }

  // build
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    bool screenOrientation = screenHeight > screenWidth;
    lastWeekData();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle,style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.055 : screenHeight * 0.055)),
        centerTitle: true,
      ),
      body: (vExpensesList == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // bar chart
                SizedBox(
                  height: screenOrientation ? screenWidth * 0.55 : screenHeight * 0.55,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                              getTitlesWidget: (value, meta) => Text(AppUtils.formatDateAndGetDay(barChartList[value.toInt()]['date'])),
                          )
                        ),
                        topTitles: AxisTitles(drawBelowEverything: true)
                      ),
                      minY: 0,
                      maxY: findTotalAmt(),
                      barGroups: [
                        ...barChartList.map(
                          (e) => BarChartGroupData(
                            x: barChartList.indexOf(e),
                            barRods: [
                              BarChartRodData(toY: e['totalAmt'],width: 30,borderRadius: BorderRadius.zero)
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // expense
                Expanded(
                  child: (findTotalAmt() != 0.0) ? ListView.builder(
                    itemCount: vExpensesList!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(icons[vExpensesList![index].expenseCategory],size: screenOrientation ? screenWidth * 0.06 : screenHeight * 0.06,),
                        title: Text(vExpensesList![index].expenseTitle,style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),),
                        subtitle: Text(AppUtils.formatDate(pDate: vExpensesList![index].date),style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),),
                        trailing: Text('₹ ${vExpensesList![index].amount}', style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),
                        ),
                      );
                    },
                  ) : Center(child: Text('No expense',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),)),
                ),
              ],
            ),
    );
  }

  // change: Future<List<Map<String,dynamic>>?> to Future<void> in below method
  Future<void> fetchExpensesFromDB() async {
    DatabaseManager manager = DatabaseManager.getInstance();
    List<Expense> vReceivedExpensesList =
        await manager.fetchExpense(pExpenseCategory: widget.categoryTitle);
    setState(() {
      vExpensesList = vReceivedExpensesList;
    });
  }

  // calculating last week Expense
  void lastWeekData(){
    List<Map<String,dynamic>> lastWeekCalculationList = [];
    for(int i = 0; i < 7; i++){
      double total = 0.0;
      DateTime weekDays = DateTime.now().subtract(Duration(days: i));

      // let's check how many transaction happens that day
      for(int j = 0; j < vExpensesList!.length; j++){

        if(DateTime.parse(vExpensesList![j].date).year == weekDays.year &&
            DateTime.parse(vExpensesList![j].date).month == weekDays.month &&
            DateTime.parse(vExpensesList![j].date).day == weekDays.day
        ){
          total += vExpensesList![j].amount;

        }
      }
      lastWeekCalculationList.add({'date' : weekDays, 'totalAmt' : total});
    }
    setState(() {
      barChartList = lastWeekCalculationList;
      barChartList = barChartList.reversed.toList();
    });
  }
}
