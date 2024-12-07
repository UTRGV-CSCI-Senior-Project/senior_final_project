import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/controller/schedule_controller';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PortfolioCalender extends ConsumerStatefulWidget {
  final UserModel? userModel;
  final PortfolioModel? portfolioModel;

  const PortfolioCalender({
    super.key,
    this.userModel,
    this.portfolioModel,
  });

  @override
  ConsumerState<PortfolioCalender> createState() => _PortfolioCalenderState();
}

class _PortfolioCalenderState extends ConsumerState<PortfolioCalender> {
  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      allowViewNavigation: true,
      view: CalendarView.week, // Example: Set the default view to month
      dataSource: MeetingDataSource(_getDataSource()),
      todayHighlightColor: Colors.blue, // Customize properties as required
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
      'Conference',
      startTime,
      endTime,
      const Color(0xFF0F8644),
      false,
    ));
    return meetings;
  }
}
