import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../providers/exam_provider.dart';
import 'add_event_screen.dart';
import 'map_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return context.read<ExamProvider>().getEventsForDay(day);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.tealAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red), // Custom weekend text color
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.teal),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.teal),
            ),
          ),
          Expanded(
            child: Consumer<ExamProvider>(
              builder: (context, examProvider, child) {
                final events = _selectedDay != null
                    ? examProvider.getEventsForDay(_selectedDay!)
                    : [];
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          Icons.event, // You can customize this to be dynamic based on event type
                          color: Colors.teal,
                        ),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${event.dateTime.toString()} - ${event.location}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          // Navigate to map screen with the event location
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(event: event),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
