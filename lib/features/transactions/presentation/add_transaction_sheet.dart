import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late String _selectedCategory;

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Housing & Utilities',
    'Shopping',
    'Entertainment',
    'Health & Fitness',
    'Personal Care',
    'Education',
    'Travel',
    'Bills & Fees',
    'Subscriptions',
    'Gifts & Donations',
    'Miscellaneous'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Refunds',
    'Rental Income',
    'Sale of Items',
    'Other Income'
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;

    _amountController = TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _notesController = TextEditingController(text: tx?.notes ?? '');
    _selectedType = tx?.type ?? TransactionType.expense;
    _selectedDate = tx?.date ?? DateTime.now();

    if (tx != null && tx.category.isNotEmpty) {
      _selectedCategory = tx.category;
    } else {
      _selectedCategory = _selectedType == TransactionType.expense
          ? _expenseCategories.first
          : _incomeCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitData() {
    final amountText = _amountController.text;

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final newTx = Transaction()
      ..amount = amount
      ..type = _selectedType
      ..category = _selectedCategory
      ..date = _selectedDate
      ..notes = _notesController.text.trim();

    if (widget.transaction != null) newTx.id = widget.transaction!.id;

    ref.read(transactionNotifierProvider.notifier).addTransaction(newTx);
    Navigator.of(context).pop();
  }

  void _presentDatePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: isDark
            ? ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.brandPurple,
            onPrimary: Colors.white,
            surface: AppTheme.darkBgAccent,
            onSurface: Colors.white,
          ),
        )
            : ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.brandPurple,
            onPrimary: Colors.white,
            surface: AppTheme.lightBgMain,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textColor = AppTheme.textColor(context);
    final textDimColor = AppTheme.textDimColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentCategories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.glassBorder(context))),
      ),
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textDimColor.withAlpha((0.3 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.transaction != null ? 'Edit Transaction' : 'New Transaction',
            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedType = TransactionType.expense;
                  if (!_expenseCategories.contains(_selectedCategory)) {
                    _selectedCategory = _expenseCategories.first;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedType == TransactionType.expense
                        ? AppTheme.expenseRed.withAlpha((0.15 * 255).toInt())
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == TransactionType.expense
                          ? AppTheme.expenseRed
                          : textDimColor.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Expense',
                    style: TextStyle(
                      color: _selectedType == TransactionType.expense
                          ? AppTheme.expenseRed
                          : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedType = TransactionType.income;
                  if (!_incomeCategories.contains(_selectedCategory)) {
                    _selectedCategory = _incomeCategories.first;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedType == TransactionType.income
                        ? AppTheme.incomeGreen.withAlpha((0.15 * 255).toInt())
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == TransactionType.income
                          ? AppTheme.incomeGreen
                          : textDimColor.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Income',
                    style: TextStyle(
                      color: _selectedType == TransactionType.income
                          ? AppTheme.incomeGreen
                          : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          GlassTextField(
            hintText: 'Amount (₹)',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.currency_rupee,
          ),

          const SizedBox(height: 24),

          Text('Category', style: TextStyle(color: textDimColor, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: currentCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.brandPurple.withAlpha(((isDark ? 0.4 : 0.2) * 255).toInt())
                          : AppTheme.glassColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.brandPurple : AppTheme.glassBorder(context),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? textColor : textDimColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: Text(
                'Date: ${AppFormatters.formatDate(_selectedDate)}',
                style: TextStyle(color: textDimColor, fontSize: 16),
              ),
            ),
            TextButton.icon(
              onPressed: _presentDatePicker,
              icon: const Icon(Icons.calendar_today, color: AppTheme.brandPurple),
              label: const Text(
                'Choose Date',
                style: TextStyle(color: AppTheme.brandPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          GlassTextField(
            hintText: 'Notes (Optional)',
            controller: _notesController,
            prefixIcon: Icons.notes,
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPurple,
                elevation: 8,
                shadowColor: AppTheme.brandPurple.withAlpha((0.4 * 255).toInt()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitData,
              child: Text(
                widget.transaction != null ? 'Update Transaction' : 'Add Transaction',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}