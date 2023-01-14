import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/styles.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: Styles().largeText,
        ),
        backgroundColor: Styles().backgroundColor,
        leading: BackButton(color: Styles().mainColor),
      ),
      body: Frame(
        showLogo: false,
        child: FutureBuilder(
          future: db.Tracks.instance.getAllDailyTracks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('An error has occurred, ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<DailyTrack> allDailyTracksList =
                    snapshot.data as List<DailyTrack>;

                // find the months between the first daily track and now
                DateTime firstDailyTrackDateTime =
                    allDailyTracksList.first.date;
                DateTime now = DateTime.now();
                List<DateTime> monthsBetweenFirstDailyTrackAndNow = [];
                while (firstDailyTrackDateTime.isBefore(now)) {
                  monthsBetweenFirstDailyTrackAndNow
                      .add(firstDailyTrackDateTime);

                  firstDailyTrackDateTime = DateTime(
                      firstDailyTrackDateTime.year,
                      firstDailyTrackDateTime.month + 1);
                }

                // go through and sort the daily tracks by month and year
                List<List<DailyTrack>> dailyTracksByMonth =
                    List.filled(monthsBetweenFirstDailyTrackAndNow.length, []);
                int i = 0;
                for (DailyTrack dailyTrack in allDailyTracksList) {
                  if (dailyTrack.date.month ==
                          monthsBetweenFirstDailyTrackAndNow[i].month &&
                      dailyTrack.date.year ==
                          monthsBetweenFirstDailyTrackAndNow[i].year) {
                    dailyTracksByMonth[i].add(dailyTrack);
                  } else {
                    while (dailyTrack.date.month !=
                            monthsBetweenFirstDailyTrackAndNow[i].month &&
                        dailyTrack.date.year !=
                            monthsBetweenFirstDailyTrackAndNow[i].year) {
                      i++;
                    }

                    dailyTracksByMonth[i].add(dailyTrack);
                  }
                }

                return ListView.builder(
                    itemCount: monthsBetweenFirstDailyTrackAndNow.length,
                    itemBuilder: (context, index) => Column(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  DateFormat('MMM y').format(
                                      monthsBetweenFirstDailyTrackAndNow[
                                          index]),
                                  style: Styles().largeText,
                                )),
                            MonthCalendar(
                              monthlyDateTime:
                                  monthsBetweenFirstDailyTrackAndNow[index],
                              dailyTracksThisMonth: dailyTracksByMonth[index],
                            ),
                          ],
                        ));
              }
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class MonthCalendar extends StatefulWidget {
  const MonthCalendar(
      {super.key,
      required this.monthlyDateTime,
      required this.dailyTracksThisMonth});
  final DateTime monthlyDateTime;
  final List<DailyTrack> dailyTracksThisMonth;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  int dailyTrackIndex = 0;

  @override
  Widget build(BuildContext context) {
    int year = widget.monthlyDateTime.year;
    int month = widget.monthlyDateTime.month;

    int monthOffset = DateUtils.firstDayOffset(
        year, month, const DefaultMaterialLocalizations());

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: DateUtils.getDaysInMonth(year, month) + monthOffset,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        // account for the month's date offset, add empty entries
        if (index < monthOffset) {
          return const SizedBox.shrink();
        }

        if (widget.dailyTracksThisMonth.length - 1 >= dailyTrackIndex) {
          DailyTrack? dailyTrack = widget.dailyTracksThisMonth[dailyTrackIndex];
          if (dailyTrack.date.day == (index - monthOffset) + 1) {
            dailyTrackIndex++;
            return Card(
                color: Styles().backgroundColor,
                semanticContainer: true,
                child: Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(dailyTrack.track.images.first.url)),
                  CalendarText(
                    index: index - monthOffset,
                    containsImage: true,
                  )
                ]));
          }
        }
        return CalendarText(
          index: index - monthOffset,
          containsImage: false,
        );
      },
    );
  }
}

class CalendarText extends StatelessWidget {
  const CalendarText(
      {super.key, required this.index, required this.containsImage});
  final int index;
  final bool containsImage;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('${index + 1}',
            style: containsImage
                ? Styles().calendarTextIfImage
                : Styles().calendarText));
  }
}
