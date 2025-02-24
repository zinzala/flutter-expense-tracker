import 'package:expense_tracker/AppUtils/app_utils.dart';
import 'package:expense_tracker/Database/database_manager.dart';
import 'package:expense_tracker/Models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Constants/icons.dart';

class AllExpenses extends StatefulWidget {
  const AllExpenses({super.key});

  @override
  State<AllExpenses> createState() => _AllExpensesState();
}

class _AllExpensesState extends State<AllExpenses> {
  List<Expense>? allExpensesList = [];
  List<Expense>? filteredExpenseList = [];

  // init
  @override
  void initState() {
    super.initState();
    fetchAllExpensesFromDB();
  }

  // build
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    bool screenOrientation = screenHeight > screenWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text('All Expenses',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.055 : screenHeight * 0.055)),
        centerTitle: true,
      ),
      body: (filteredExpenseList == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search'
                  ),
                  onChanged: (value) => findExpense(value),
                ),
              ),
              SizedBox(height: screenOrientation ? screenWidth * 0.001 : screenHeight * 0.001,),
              Expanded(
                child: (filteredExpenseList!.isNotEmpty) ? ListView.builder(
                    itemCount: filteredExpenseList!.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(color: Colors.red,),
                        onDismissed: (direction) async{
                          DatabaseManager manager = DatabaseManager.getInstance();
                          await manager.deleteExpense(category: filteredExpenseList![index].expenseCategory, amount: filteredExpenseList![index].amount, id: filteredExpenseList![index].id);
                          setState(() {
                            Expense expense = filteredExpenseList!.removeAt(index);
                            allExpensesList!.remove(expense);
                          });
                        },
                        child: ListTile(
                          leading: Icon(icons[filteredExpenseList![index].expenseCategory],size: screenOrientation ? screenWidth * 0.06 : screenHeight * 0.06,),
                          title: Text(filteredExpenseList![index].expenseTitle,style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),),
                          subtitle: Text(AppUtils.formatDate(pDate: (filteredExpenseList![index].date).toString()),style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),),
                          trailing: Text('₹ ${filteredExpenseList![index].amount}',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),),
                        ),
                      );
                    },
                  ) : Center(child: Text('No expense',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),),),
              ),
            ],
          ),
    );
  }

  Future<void> fetchAllExpensesFromDB() async {
    DatabaseManager manager = DatabaseManager.getInstance();
    List<Expense> receivedExpensesList = await manager.fetchAllExpense();
    setState(() {
      allExpensesList = receivedExpensesList;
      filteredExpenseList = allExpensesList;
    });
  }

  void findExpense(String value) {
    var cacheList = allExpensesList;
    if(value.isNotEmpty){
      setState(() {
        filteredExpenseList = cacheList!.where((expense) => expense.expenseTitle.toLowerCase().contains(value.toLowerCase()),).toList();
      });
    }else{
      setState(() {
        filteredExpenseList = allExpensesList;
      });

  }
}
}
