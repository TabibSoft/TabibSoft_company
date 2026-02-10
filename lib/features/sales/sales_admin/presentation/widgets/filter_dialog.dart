import 'package:flutter/material.dart';
import '../../data/models/requirement_model.dart';

class FilterDialog extends StatefulWidget {
  final List<SalesPerson> salesPersons;
  final List<StatusCount> statusCounts;
  final DateTime? currentFromDate;
  final DateTime? currentToDate;
  final String? currentSalesPersonId;
  final String? currentStatusId;
  final String? currentName;

  const FilterDialog({
    super.key,
    required this.salesPersons,
    required this.statusCounts,
    this.currentFromDate,
    this.currentToDate,
    this.currentSalesPersonId,
    this.currentStatusId,
    this.currentName,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedSalesPersonId;
  String? selectedStatusId;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    fromDate = widget.currentFromDate;
    toDate = widget.currentToDate;
    selectedSalesPersonId = widget.currentSalesPersonId;
    selectedStatusId = widget.currentStatusId;
    nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? fromDate : toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF104D9D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF104D9D), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      fromDate = null;
      toDate = null;
      selectedSalesPersonId = null;
      selectedStatusId = null;
      nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('تصفية النتائج',
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Section
                const Text('الفترة الزمنية',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF104D9D))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(
                        label: 'من تاريخ',
                        date: fromDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateSelector(
                        label: 'إلى تاريخ',
                        date: toDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Filters Section

                // Name Search
                const Text('بحث بالاسم',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF104D9D))),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'ادخل اسم العميل',
                    hintStyle: const TextStyle(
                        fontFamily: 'Amiri', color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF104D9D)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF104D9D), width: 2),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Amiri'),
                ),
                const SizedBox(height: 16),

                // Sales Person Dropdown
                _buildDropdown(
                  label: ' المبيعات',
                  value: selectedSalesPersonId,
                  hint: 'اختر المهندس',
                  items: widget.salesPersons.map((person) {
                    return DropdownMenuItem(
                      value: person.id,
                      child: Text(person.name,
                          style: const TextStyle(fontFamily: 'Amiri')),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedSalesPersonId = value),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                _buildDropdown(
                  label: 'الحالة',
                  value: selectedStatusId,
                  hint: 'اختر الحالة',
                  items: widget.statusCounts.map((status) {
                    return DropdownMenuItem(
                      value: status.statusName,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(int.parse(status.statusColor
                                  .replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(status.statusName,
                              style: const TextStyle(fontFamily: 'Amiri')),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedStatusId = value),
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'مسح الفلاتر',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'fromDate': fromDate,
                      'toDate': toDate,
                      'salesPersonId': selectedSalesPersonId,
                      'statusId': selectedStatusId,
                      'name': nameController.text.trim(),
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF104D9D),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('تطبيق الفلتر',
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : '----/--/--',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: date != null ? Colors.black87 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 18, color: const Color(0xFF104D9D).withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF104D9D), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: Text(hint,
              style: const TextStyle(fontFamily: 'Amiri', color: Colors.grey)),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('الكل', style: TextStyle(fontFamily: 'Amiri')),
            ),
            ...items,
          ],
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ],
    );
  }
}
