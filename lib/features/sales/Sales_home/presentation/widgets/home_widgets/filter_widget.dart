import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabib_soft_company/features/sales/Sales_home/data/models/filter/status_model.dart';
import 'package:tabib_soft_company/features/technical_support/data/model/customer/addCustomer/product_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? currentStatusId;
  final String? currentProductId;
  final DateTime? currentFrom;
  final DateTime? currentTo;
  final List<ProductModel> products;
  final List<StatusModel> statuses;

  const FilterBottomSheet({
    super.key,
    this.currentStatusId,
    this.currentProductId,
    this.currentFrom,
    this.currentTo,
    required this.products,
    required this.statuses,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedStatusId;
  String? selectedProductId;
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatusId = widget.currentStatusId;
    selectedProductId = widget.currentProductId;
    fromDate = widget.currentFrom;
    toDate = widget.currentTo;
    if (fromDate != null) {
      fromController.text = _formatDate(fromDate!);
    }
    if (toDate != null) {
      toController.text = _formatDate(toDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> pickDate(bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          fromController.text = _formatDate(picked);
        } else {
          toDate = picked;
          toController.text = _formatDate(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: ListView(
          controller: controller,
          children: [
            // IconButton(
            //   onPressed: () => Navigator.pop(context),
            //   icon: const Icon(
            //     Icons.close,
            //     color: Color(0xff104D9D),
            //   ),
            // ),
            const Align(
              alignment: AlignmentDirectional.center,
              // child: Text(
              //   'فلتر',
              //   style: TextStyle(
              //     fontSize: 20.sp,
              //     fontWeight: FontWeight.w600,
              //     color: const Color(0xff104D9D),
              //   ),
              // ),
            ),
            // SizedBox(height: 20.h),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                'الحاله',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff104D9D),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            if (widget.statuses.isNotEmpty)
              SizedBox(
                height: 110.h,
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: widget.statuses.map((status) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8.r),
                        onTap: () {
                          setState(() {
                            selectedStatusId = status.id;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 15.h,
                          ),
                          decoration: BoxDecoration(
                            color: selectedStatusId == status.id
                                ? const Color(0xff104D9D)
                                : const Color(0xFFE8F3F1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (selectedStatusId == status.id)
                                const Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 10.w),
                              Text(
                                status.name,
                                style: TextStyle(
                                  color: selectedStatusId == status.id
                                      ? Colors.white
                                      : const Color(0xff104D9D),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              const Text('لا توجد بيانات'),
            SizedBox(height: 20.h),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                'التخصص',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff104D9D),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            if (widget.products.isNotEmpty)
              SizedBox(
                height: 220.h,
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: widget.products.map((product) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8.r),
                        onTap: () {
                          setState(() {
                            selectedProductId = product.id;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 15.h,
                          ),
                          decoration: BoxDecoration(
                            color: selectedProductId == product.id
                                ? const Color(0xff104D9D)
                                : const Color(0xFFE8F3F1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (selectedProductId == product.id)
                                const Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 10.w),
                              Text(
                                product.name,
                                style: TextStyle(
                                  color: selectedProductId == product.id
                                      ? Colors.white
                                      : const Color(0xff104D9D),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              const Text('لا توجد بيانات'),
            SizedBox(height: 20.h),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                'الوقت من .. إلى',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff104D9D),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: fromController,
                    readOnly: true,
                    onTap: () => pickDate(true),
                    decoration: InputDecoration(
                      hintText: 'من',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextFormField(
                    controller: toController,
                    readOnly: true,
                    onTap: () => pickDate(false),
                    decoration: InputDecoration(
                      hintText: 'إلى',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'status': selectedStatusId,
                        'productId': selectedProductId,
                        'from': fromDate,
                        'to': toDate,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff104D9D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    child: Text(
                      'إضافة فلتر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'status': null,
                        'productId': null,
                        'from': null,
                        'to': null,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    child: Text(
                      'إزالة فلتر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
