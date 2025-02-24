
import 'package:expense_tracker/AppUtils/app_utils.dart';
import 'package:expense_tracker/Database/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Constants/icons.dart';
import '../Models/expense_model.dart';

Future<bool?> openBottomSheet({required BuildContext context}) async{
  return await showModalBottomSheet(
    shape: RoundedRectangleBorder(),
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return ExpenseBottomSheet();
    },
  );
}

class ExpenseBottomSheet extends StatefulWidget {
  const ExpenseBottomSheet({super.key});

  @override
  State<ExpenseBottomSheet> createState() => _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends State<ExpenseBottomSheet> {
  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  String initialCategory = 'Other';

  DateTime? selectedDate;

  String? errExpenseTitle, errExpenseAmount;

  void openDatePicker() async {
    DateTime? returnedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    setState(() {
      selectedDate = returnedDate;
    });
  }

  //dispose
  @override
  void dispose() {
    super.dispose();
    _expenseTitleController;
    _amountController;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    bool screenOrientation = screenHeight > screenWidth;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: screenOrientation ? screenWidth * 1.0 : screenHeight * 1.0,
        padding: EdgeInsets.fromLTRB(
            screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04,
            screenOrientation ? screenWidth * 0.07 : screenHeight * 0.07,
            screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04,
            0.0),
        child: Column(
          children: [
            paintTextField(
                pErrorText: errExpenseTitle,
                pFocusNode: _titleFocusNode,
                pController: _expenseTitleController,
                pHelperText: 'Add Expense Title',
                pHintText: 'Enter title'),
            // for space
            SizedBox(
              height: screenOrientation ? screenWidth * 0.03 : screenHeight * 0.03,
            ),
            paintTextField(
                pErrorText: errExpenseAmount,
                pFocusNode: _amountFocusNode,
                pController: _amountController,
                pHelperText: 'Add Amount',
                pHintText: 'Enter amount'),
            // for space
            SizedBox(
              height: screenOrientation ? screenWidth * 0.045 : screenHeight * 0.045,
            ),
            // select date row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenOrientation ? screenWidth * 0.015 : screenHeight * 0.015,),
              child: Row(
                children: [
                  Expanded(
                      child: (selectedDate == null)
                          ? Text('Select Date',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),)
                          : Text(AppUtils.formatDate(pDate: selectedDate.toString()))),
                  GestureDetector(
                    onTap: () {
                      openDatePicker();
                      _titleFocusNode.unfocus();
                      _amountFocusNode.unfocus();
                    },
                    child: Icon(Icons.date_range_rounded),
                  )
                ],
              ),
            ),
            // for space
            SizedBox(
              height: screenOrientation ? screenWidth * 0.03 : screenHeight * 0.03,
            ),
            // select category row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenOrientation ? screenWidth * 0.015 : screenHeight * 0.015),
              child: Row(
                children: [
                  Expanded(child: Text('Select Category',style: TextStyle(fontSize: screenOrientation ? screenWidth * 0.035 : screenHeight * 0.035),)),
                  DropdownButton(
                    value: initialCategory,
                    items: icons.keys.map(
                      (e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        initialCategory = value ?? 'No Data';
                      });
                    },
                  ),
                ],
              ),
            ),
            // for space
            SizedBox(
              height: screenOrientation ? screenWidth * 0.07 : screenHeight * 0.07,
            ),
            // green button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenOrientation ? screenWidth * 0.02 : screenHeight * 0.02)),
                    padding: EdgeInsets.all(screenOrientation ? screenWidth * 0.05 : screenHeight * 0.05)),
                onPressed: () async {
                  validateStuffs();

                  },
                child: Text(
                  'Add Expense',
                  style: TextStyle(color: Colors.white, fontSize: screenOrientation ? screenWidth * 0.04 : screenHeight * 0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paintTextField(
      {required TextEditingController pController,
      required String pHelperText,
      required String pHintText,
      required String? pErrorText,
      required FocusNode pFocusNode}) {
    return TextField(
        controller: pController,
        focusNode: pFocusNode,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: pHintText,
          helperText: pHelperText,
          errorText: pErrorText
        ));
  }

  void validateStuffs() async{
    errExpenseTitle = AppUtils.validateExpenseTitle(_expenseTitleController.text.trim());
    errExpenseAmount = AppUtils.validateExpenseTitle(_amountController.text.trim());

    if(errExpenseTitle == null && errExpenseAmount == null){
      String vExpenseTitle = _expenseTitleController.text;
      double vAmount = double.tryParse(_amountController.text) ?? 0.0;

      Expense vExpense = Expense(
        id: 0,
        expenseTitle: vExpenseTitle,
        amount: vAmount,
        date:(selectedDate ?? DateTime.now()).toString(),
        expenseCategory: initialCategory,
      );
      DatabaseManager manager = DatabaseManager.getInstance();
      await manager.addExpense(pExpense: vExpense);
      Navigator.pop(context,true);
    }
    setState(() {});
  }
}
