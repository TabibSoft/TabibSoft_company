import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tabib_soft_company/core/utils/cache/cache_helper.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_app_bar_widget.dart';
import 'package:tabib_soft_company/core/utils/widgets/custom_nav_bar_widget.dart';
import 'package:tabib_soft_company/features/programmers/presentation/cubit/engineer_cubit.dart';

class Event {
  final String title;
  final String description;
  final DateTime time;

  Event(this.title, this.description, this.time);

  // تحويل Event إلى JSON
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'time': time.toIso8601String(),
      };

  // إنشاء Event من JSON
  factory Event.fromJson(Map<String, dynamic> json) => Event(
        json['title'],
        json['description'],
        DateTime.parse(json['time']),
      );
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Event>> _events = {};
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EngineerCubit>().fetchEngineers();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  // تحميل الأحداث من SharedPreferences
  Future<void> _loadEvents() async {
    await CacheHelper.init();
    final String eventsJson = CacheHelper.getString(key: 'calendar_events');
    if (eventsJson.isNotEmpty) {
      final Map<String, dynamic> eventsMap = jsonDecode(eventsJson);
      setState(() {
        _events.clear();
        eventsMap.forEach((key, value) {
          final date = DateTime.parse(key);
          _events[date] = (value as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
        });
      });
    }
  }

  // حفظ الأحداث في SharedPreferences
  Future<void> _saveEvents() async {
    final Map<String, dynamic> eventsMap = {};
    _events.forEach((key, value) {
      eventsMap[key.toIso8601String()] =
          value.map((event) => event.toJson()).toList();
    });
    await CacheHelper.saveData(
        key: 'calendar_events', value: jsonEncode(eventsMap));
  }

  void _addEvent(BuildContext context) {
    if (_selectedDay == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _eventDescController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              if (_eventTitleController.text.isNotEmpty) {
                setState(() {
                  final event = Event(
                    _eventTitleController.text,
                    _eventDescController.text,
                    _selectedDay!,
                  );
                  final dateKey = DateTime(_selectedDay!.year,
                      _selectedDay!.month, _selectedDay!.day);
                  if (_events[dateKey] == null) {
                    _events[dateKey] = [];
                  }
                  _events[dateKey]!.add(event);
                });
                _saveEvents(); // حفظ الأحداث بعد الإضافة
                _eventTitleController.clear();
                _eventDescController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomAppBar(
                title: 'Calendar',
                height: 332,
                leading: IconButton(
                  icon: Image.asset(
                    'assets/images/pngs/back.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/pngs/calendar.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () => _addEvent(context),
                  ),
                ],
              ),
            ),
            Positioned(
              top: size.height * 0.23,
              left: size.width * 0.05,
              right: size.width * 0.05,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 95, 93, 93).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF56C7F1), width: 3),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 50, left: 16, right: 16),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarFormat: CalendarFormat.month,
                          headerVisible: false,
                          daysOfWeekHeight: 40,
                          rowHeight: 40,
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(fontSize: 16),
                            weekendTextStyle: const TextStyle(fontSize: 16),
                            outsideTextStyle: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                            todayDecoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            tableBorder: TableBorder.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                            cellMargin: const EdgeInsets.all(4),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          locale: 'en_US',
                          startingDayOfWeek: StartingDayOfWeek.saturday,
                          calendarBuilders: CalendarBuilders(
                            dowBuilder: (context, day) {
                              final days = ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
                              final dayIndex =
                                  (day.weekday - DateTime.saturday) % 7;
                              final isSaturday =
                                  day.weekday == DateTime.saturday;

                              return Container(
                                decoration: BoxDecoration(
                                  color: isSaturday
                                      ? Colors.red.withOpacity(0.8)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  days[dayIndex],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (context, day, focusedDay) {
                              final isSelected = isSameDay(day, _selectedDay);
                              final isToday = isSameDay(day, DateTime.now());
                              final inMonth = day.month == focusedDay.month;
                              Color textColor;
                              if (!inMonth) {
                                textColor = Colors.grey;
                              } else if (isSelected || isToday) {
                                textColor = Colors.black87;
                              } else {
                                textColor = Colors.black87;
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.yellow.withOpacity(0.7)
                                        : (isToday
                                            ? Colors.green.withOpacity(0.7)
                                            : Colors.transparent),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                            outsideBuilder: (context, day, focusedDay) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              );
                            },
                            markerBuilder: (context, day, events) {
                              if (_getEventsForDay(day).isNotEmpty) {
                                return Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDay != null &&
                        _getEventsForDay(_selectedDay!).isNotEmpty)
                      Container(
                        height: size.height * 0.3,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: _getEventsForDay(_selectedDay!).length,
                          itemBuilder: (context, index) {
                            final event =
                                _getEventsForDay(_selectedDay!)[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(Icons.event,
                                      color: Colors.blue),
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  event.description.isNotEmpty
                                      ? event.description
                                      : 'No description',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _events[DateTime(
                                              _selectedDay!.year,
                                              _selectedDay!.month,
                                              _selectedDay!.day)]
                                          ?.removeAt(index);
                                    });
                                    _saveEvents(); // حفظ الأحداث بعد الحذف
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomNavBar(
          items: [],
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _eventDescController.dispose();
    super.dispose();
  }
}
