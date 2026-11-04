import 'package:bookbank/data/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FinancialCalculations {
  final List<MyData> transactions;

  FinancialCalculations(this.transactions);

  // ────────── Bank Income ──────────
  double filterBankIncome() {
    double sum = 0;
    for (var element in transactions) {
      if (element.moneyType == 'income' && element.moneyList == 'bank') {
        sum += element.amount.toDouble();
      } else if (element.moneyType == 'transfer' &&
          element.moneyGroup == 'bank') {
        // transfer เข้า bank → เพิ่มยอด bank
        sum += element.amount.toDouble();
      }
    }
    return sum;
  }

  // ────────── Bank Expense ──────────
  double filterBankExpense() {
    double sum = 0;
    for (var element in transactions) {
      if (element.moneyType == 'expense' && element.moneyList == 'bank') {
        sum += element.amount.toDouble();
      } else if (element.moneyType == 'transfer' &&
          element.moneyList == 'bank') {
        // transfer ออกจาก bank → ลดยอด bank
        sum += element.amount.toDouble();
      }
    }
    return sum;
  }

  // ────────── Cash Income ──────────
  double filterCashIncome() {
    double sum = 0;
    for (var element in transactions) {
      if (element.moneyType == 'income' && element.moneyList == 'cash') {
        sum += element.amount.toDouble();
      } else if (element.moneyType == 'transfer' &&
          element.moneyGroup == 'cash') {
        // transfer เข้า cash → เพิ่มยอด cash
        sum += element.amount.toDouble();
      }
    }
    return sum;
  }

  // ────────── Cash Expense ──────────
  double filterCashExpense() {
    double sum = 0;
    for (var element in transactions) {
      if (element.moneyType == 'expense' && element.moneyList == 'cash') {
        sum += element.amount.toDouble();
      } else if (element.moneyType == 'transfer' &&
          element.moneyList == 'cash') {
        // transfer ออกจาก cash → ลดยอด cash
        sum += element.amount.toDouble();
      }
    }
    return sum;
  }

  // ────────── Group Income ──────────
  double groupIncome(String group) {
    return transactions
        .where((e) => e.moneyGroup == group && e.moneyType == 'income')
        .fold(
          0.0,
          (previousValue, element) => previousValue + element.amount.toDouble(),
        );
  }

  // ────────── Group Expense ──────────
  double groupExpense(String group) {
    return transactions
        .where((e) => e.moneyGroup == group && e.moneyType == 'expense')
        .fold(
          0.0,
          (previousValue, element) => previousValue + element.amount.toDouble(),
        );
  }

  // ────────── Income Group Total ──────────
  double incomeGroupTotal() {
    return transactions
        .where((e) => e.moneyType == 'income' && e.moneyGroup.isNotEmpty)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Expense Group Total ──────────
  double expenseGroupTotal() {
    return transactions
        .where((e) => e.moneyType == 'expense' && e.moneyGroup.isNotEmpty)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Bank Total ──────────
  double sumBank() {
    return filterBankIncome() - filterBankExpense();
  }

  // ────────── Cash Total ──────────
  double sumCash() {
    return filterCashIncome() - filterCashExpense();
  }

  // ────────── Income Total ──────────
  double income() {
    double sum = 0;
    for (var element in transactions) {
      if (element.moneyType == 'income') {
        sum += element.amount.toDouble();
      }
    }
    return sum;
  }

  // ────────── Expense Total ──────────
  double expense() {
    return filterBankExpense() + filterCashExpense();
  }

  // ────────── Total Balance ──────────
  double sumAll() {
    return sumBank() + sumCash();
  }

  // ────────── Group Balance ──────────
  double sumGroup(String group) {
    double base = groupIncome(group) - groupExpense(group);

    // transfer out
    double transferOut = transactions
        .where((e) => e.moneyType == 'transfer' && e.moneyList == group)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());

    // transfer in
    double transferIn = transactions
        .where((e) => e.moneyType == 'transfer' && e.moneyGroup == group)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());

    return base - transferOut + transferIn;
  }

  // ────────── Group Total ──────────
  double sumGroupAll() {
    return incomeGroupTotal() - expenseGroupTotal();
  }

  // ────────── Gap ──────────
  double gap() {
    return sumAll() - sumGroupAll();
  }

  // ────────── Group Percentage ──────────
  double calculateGroupPercentage(String group) {
    double groupTotal = sumGroupAll().toDouble();
    if (groupTotal <= 0) return 0.0;
    double groupAmount = sumGroup(group).toDouble();
    return (groupAmount / groupTotal) * 100.0;
  }

  // ────────── Unallocated Percentage ──────────
  double calculateUnallocatedPercentage() {
    double groupTotal = sumGroupAll().toDouble();
    if (groupTotal <= 0) return 0.0;
    double unallocated = gap().toDouble();
    return (unallocated / groupTotal) * 100.0;
  }

  // ────────── Group Count ──────────
  int groupCount(String group) {
    return transactions.where((e) => e.moneyGroup == group).length;
  }

  // ────────── Unallocated Count ──────────
  int unallocatedCount() {
    return transactions
        .where((e) => e.moneyGroup.isEmpty && e.moneyType == 'income')
        .length;
  }

  // ────────── Unallocated Amount ──────────
  double unallocatedAmount() {
    double base = transactions
        .where((e) => e.moneyGroup.isEmpty && e.moneyType == 'income')
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());

    // transfer out CashBox → down
    double transferOut = transactions
        .where((e) => e.moneyType == 'transfer' && e.moneyList == 'CashBox')
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());

    // transfer in CashBox → add
    double transferIn = transactions
        .where((e) => e.moneyType == 'transfer' && e.moneyGroup == 'CashBox')
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());

    return base - transferOut + transferIn;
  }

  // ────────── Monthly Spots ──────────
  List<FlSpot> generateMonthlySpots() {
    List<FlSpot> spots = [];
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Calculate data for last 30 days
    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dateStr = dateFormat.format(date);

      // Calculate income for the day
      double dailyIncome = transactions
          .where((e) => e.moneyType == 'income' && e.date == dateStr)
          .fold(0.0, (sum, e) => sum + e.amount.toDouble());

      // Calculate expense for the day
      double dailyExpense = transactions
          .where((e) => e.moneyType == 'expense' && e.date == dateStr)
          .fold(0.0, (sum, e) => sum + e.amount.toDouble());

      // Calculate net amount (income - expense)
      double netAmount = dailyIncome - dailyExpense;

      // x = วันที่ (1-30), y = ยอดสุทธิ
      spots.add(FlSpot((30 - i).toDouble(), netAmount));
    }

    return spots;
  }

  // ────────── Monthly Spots for Group ──────────
  List<FlSpot> generateMonthlySpotsForGroup(String group) {
    List<FlSpot> spots = [];
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Filter transactions for this group
    final groupTransactions = transactions
        .where((e) => e.moneyGroup == group)
        .toList();

    // Create data for last 30 days
    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dateStr = dateFormat.format(date);

      // Calculate income for the day in this group
      double dailyIncome = groupTransactions
          .where((e) => e.moneyType == 'income' && e.date == dateStr)
          .fold(0.0, (sum, e) => sum + e.amount.toDouble());

      // Calculate expense for the day in this group
      double dailyExpense = groupTransactions
          .where((e) => e.moneyType == 'expense' && e.date == dateStr)
          .fold(0.0, (sum, e) => sum + e.amount.toDouble());

      // Calculate net amount (income - expense)
      double netAmount = dailyIncome - dailyExpense;

      // x = day (1-30), y = net amount
      spots.add(FlSpot((30 - i).toDouble(), netAmount));
    }

    return spots;
  }

  // ────────── Monthly Income ──────────
  double monthlyIncome() {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    return transactions
        .where(
          (e) =>
              e.moneyType == 'income' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isCurrentMonth(e.date!, currentMonth, currentYear),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Expense ──────────
  double monthlyExpense() {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isCurrentMonth(e.date!, currentMonth, currentYear),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Group Income ──────────
  double monthlyGroupIncome(String group) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    return transactions
        .where(
          (e) =>
              e.moneyGroup == group &&
              e.moneyType == 'income' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isCurrentMonth(e.date!, currentMonth, currentYear),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Group Expense ──────────
  double monthlyGroupExpense(String group) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    return transactions
        .where(
          (e) =>
              e.moneyGroup == group &&
              e.moneyType == 'expense' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isCurrentMonth(e.date!, currentMonth, currentYear),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Helper Methods ──────────
  bool _isCurrentMonth(String dateStr, int currentMonth, int currentYear) {
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length != 3) return false;
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      return year == currentYear && month == currentMonth;
    } catch (e) {
      return false;
    }
  }

  // ========== Daily Calculations ==========

  // ────────── Daily Income ──────────
  double dailyIncome(String dateStr) {
    return transactions
        .where((e) => e.moneyType == 'income' && e.date == dateStr)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Daily Expense ──────────
  double dailyExpense(String dateStr) {
    return transactions
        .where((e) => e.moneyType == 'expense' && e.date == dateStr)
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Daily Net ──────────
  double dailyNet(String dateStr) {
    return dailyIncome(dateStr) - dailyExpense(dateStr);
  }

  // ────────── Daily Expense by Category ──────────
  double dailyExpenseByCategory(String dateStr, String group) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.moneyGroup == group &&
              e.date == dateStr,
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Daily Category Percentage ──────────
  double dailyCategoryPercentage(String dateStr, String group) {
    double totalExpense = dailyExpense(dateStr);
    if (totalExpense <= 0) return 0.0;
    return (dailyExpenseByCategory(dateStr, group) / totalExpense) * 100.0;
  }

  // ========== Monthly Calculations ==========

  // ────────── Monthly Income for Date ──────────
  double monthlyIncomeForDate(int year, int month) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'income' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isMonthYear(e.date!, year, month),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Expense for Date ──────────
  double monthlyExpenseForDate(int year, int month) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isMonthYear(e.date!, year, month),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Net for Date ──────────
  double monthlyNetForDate(int year, int month) {
    return monthlyIncomeForDate(year, month) -
        monthlyExpenseForDate(year, month);
  }

  // ────────── Monthly Expense by Category ──────────
  double monthlyExpenseByCategory(int year, int month, String group) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.moneyGroup == group &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isMonthYear(e.date!, year, month),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Monthly Category Percentage ──────────
  double monthlyCategoryPercentage(int year, int month, String group) {
    double totalExpense = monthlyExpenseForDate(year, month);
    if (totalExpense <= 0) return 0.0;
    return (monthlyExpenseByCategory(year, month, group) / totalExpense) *
        100.0;
  }

  // ────────── Generate Daily Spots for Month ──────────
  List<FlSpot> generateDailySpotsForMonth(int year, int month) {
    List<FlSpot> spots = [];
    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      String dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      double netAmount = dailyNet(dateStr);
      spots.add(FlSpot(day.toDouble(), netAmount));
    }

    return spots;
  }

  // ========== Yearly Calculations ==========

  // ────────── Yearly Income ──────────
  double yearlyIncome(int year) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'income' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isYear(e.date!, year),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Yearly Expense ──────────
  double yearlyExpense(int year) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isYear(e.date!, year),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Yearly Net ──────────
  double yearlyNet(int year) {
    return yearlyIncome(year) - yearlyExpense(year);
  }

  // ────────── Yearly Expense by Category ──────────
  double yearlyExpenseByCategory(int year, String group) {
    return transactions
        .where(
          (e) =>
              e.moneyType == 'expense' &&
              e.moneyGroup == group &&
              e.date != null &&
              e.date!.isNotEmpty &&
              _isYear(e.date!, year),
        )
        .fold(0.0, (sum, e) => sum + e.amount.toDouble());
  }

  // ────────── Yearly Category Percentage ──────────
  double yearlyCategoryPercentage(int year, String group) {
    double totalExpense = yearlyExpense(year);
    if (totalExpense <= 0) return 0.0;
    return (yearlyExpenseByCategory(year, group) / totalExpense) * 100.0;
  }

  // ────────── Generate Monthly Spots for Year ──────────
  List<FlSpot> generateMonthlySpotsForYear(int year) {
    List<FlSpot> spots = [];

    for (int month = 1; month <= 12; month++) {
      double netAmount = monthlyNetForDate(year, month);
      spots.add(FlSpot(month.toDouble(), netAmount));
    }

    return spots;
  }

  // ========== Helper Functions ==========

  // ────────── Is Month Year ──────────
  bool _isMonthYear(String dateStr, int year, int month) {
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length != 3) return false;
      int dateYear = int.parse(parts[0]);
      int dateMonth = int.parse(parts[1]);
      return dateYear == year && dateMonth == month;
    } catch (e) {
      return false;
    }
  }

  // ────────── Is Year ──────────
  bool _isYear(String dateStr, int year) {
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length != 3) return false;
      int dateYear = int.parse(parts[0]);
      return dateYear == year;
    } catch (e) {
      return false;
    }
  }
}

// ────────── Calculate Percentage ──────────
double calculatePercentage(double amount, double total) {
  if (total <= 0) return 0.0;
  return (amount / total) * 100.0;
}

// ────────── Calculate Bar Width ──────────
double calculateBarWidth(double amount, double total, double maxWidth) {
  if (total <= 0) return 0.0;
  return (amount * maxWidth) / total;
}
