import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _categoryController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submitData() {
    final amountText = _amountController.text;
    final category = _categoryController.text.trim();

    if (amountText.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount and category')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final newTx = Transaction()
      ..amount = amount
      ..type = _selectedType
      ..category = category
      ..date = _selectedDate
      ..notes = _notesController.text.trim();

    ref.read(transactionNotifierProvider.notifier).addTransaction(newTx);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.brandPurple,
              onPrimary: Colors.white,
              surface: AppTheme.backgroundMid,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'New Transaction',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == TransactionType.expense
                            ? AppTheme.expenseRed.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == TransactionType.expense
                              ? Colors.redAccent
                              : Colors.white24,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == TransactionType.income
                            ? AppTheme.incomeGreen.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == TransactionType.income
                              ? Colors.greenAccent
                              : Colors.white24,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          GlassTextField(
            hintText: 'Amount (₹)',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.currency_rupee,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            hintText: 'Category (e.g. Food, Fuel, Salary)',
            controller: _categoryController,
            prefixIcon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),


          Row(
            children: [
              Expanded(
                child: Text(
                  'Date: ${AppFormatters.formatDate(_selectedDate)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: _presentDatePicker,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text('Choose Date', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitData,
              child: const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}