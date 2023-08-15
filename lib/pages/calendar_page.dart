import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/custom_scaffold.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/track_view_widget.dart';
import 'package:daily_spotify/widgets/brand_text_widget.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/providers/track_view_provider.dart';
import 'package:daily_spotify/providers/calendar_page_provider.dart';
import 'package:daily_spotify/utils/get_average_color.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Calendar',
            style: Styles().largeText,
          ),
          backgroundColor: Styles().backgroundColor,
          leading: BackButton(color: Styles().mainColor),
          actions: [
            FutureBuilder(
                future: streakFuture(),
                builder: (context, snapshot) {
                  EdgeInsets padding = const EdgeInsets.only(right: 12.0);
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      // TODO: fix the streaks to be cleaner and not just wait a
                      int streak = snapshot.data as int;

                      return Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: Styles().mainColor, size: 32.0),
                          Padding(
                            padding: padding,
                            child: Text(
                              '$streak',
                              style: Styles().largeText,
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  return Padding(
                    padding: padding,
                    child: const CircularProgressIndicator(),
                  );
                }),
          ],
        ),
        body: Frame(
            showLogo: false,
            showMetadataAttribute: true,
            child: FutureBuilder(
              future: db.Tracks.instance.getAllDailyTracks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('An error has occurred, ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<DailyTrack> allDailyTracksList =
                        snapshot.data as List<DailyTrack>;

                    // find the months between the first daily track and now
                    DateTime firstDailyTrackDateTime =
                        allDailyTracksList.first.date;

                    /// aka now
                    DateTime mostRecentDailyTrackDate = DateTime.now();
                    for (DailyTrack dailyTrack in allDailyTracksList) {
                      if (dailyTrack.date.compareTo(mostRecentDailyTrackDate) >
                          0) {
                        mostRecentDailyTrackDate = dailyTrack.date;
                      }
                    }

                    List<DateTime> monthsBetweenFirstDailyTrackAndNow = [];
                    while (firstDailyTrackDateTime
                        .isBefore(mostRecentDailyTrackDate)) {
                      monthsBetweenFirstDailyTrackAndNow
                          .add(firstDailyTrackDateTime);

                      firstDailyTrackDateTime = DateTime(
                          firstDailyTrackDateTime.year,
                          firstDailyTrackDateTime.month + 1);
                    }

                    // go through and sort the daily tracks by month and year
                    List<List<DailyTrack>> dailyTracksByMonth = [];
                    for (DateTime month in monthsBetweenFirstDailyTrackAndNow) {
                      dailyTracksByMonth.add([]);
                    }

                    int i = 0;
                    for (DailyTrack dailyTrack in allDailyTracksList) {
                      if (dailyTrack.date.month ==
                              monthsBetweenFirstDailyTrackAndNow[i].month &&
                          dailyTrack.date.year ==
                              monthsBetweenFirstDailyTrackAndNow[i].year) {
                        dailyTracksByMonth[i].add(dailyTrack);
                      } else {
                        while (dailyTrack.date.month !=
                                monthsBetweenFirstDailyTrackAndNow[i].month ||
                            dailyTrack.date.year !=
                                monthsBetweenFirstDailyTrackAndNow[i].year) {
                          i++;
                        }

                        dailyTracksByMonth[i].add(dailyTrack);
                      }
                    }

                    // flip daily tracks and months since ListView starts at bottom
                    //   and is reversed
                    if (monthsBetweenFirstDailyTrackAndNow.length > 2) {
                      dailyTracksByMonth = dailyTracksByMonth.reversed.toList();
                      monthsBetweenFirstDailyTrackAndNow =
                          monthsBetweenFirstDailyTrackAndNow.reversed.toList();
                    }

                    return ListView.builder(
                        reverse: monthsBetweenFirstDailyTrackAndNow.length > 2,
                        itemCount: monthsBetweenFirstDailyTrackAndNow.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: index !=
                                              monthsBetweenFirstDailyTrackAndNow
                                                      .length -
                                                  1
                                          ? 16.0
                                          : 0.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        DateFormat('MMM y').format(
                                            monthsBetweenFirstDailyTrackAndNow[
                                                index]),
                                        style: Styles().largeText,
                                      )),
                                ),
                                MonthCalendar(
                                  monthlyDateTime:
                                      monthsBetweenFirstDailyTrackAndNow[index],
                                  dailyTracksThisMonth:
                                      dailyTracksByMonth[index],
                                ),
                              ],
                            ));
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            )));
  }

  Future<int> streakFuture() async {
    if (context.read<CalendarPageProvider>().streak == 0) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return 0;
    return context.read<CalendarPageProvider>().streak;
  }
}

// WidgetsBinding.instance.addPostFrameCallback((_) =>
//        setState(() => streak = context.read<CalendarPageProvider>().streak))

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.monthlyDateTime,
    required this.dailyTracksThisMonth,
  });
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

            context.read<CalendarPageProvider>().addToStreak();

            return GestureDetector(
                onTap: () async {
                  Color averageColor =
                      await getAverageColor(dailyTrack.track.images.last.url);

                  if (!mounted) return;
                  context
                      .read<TrackViewProvider>()
                      .setEmojiReactionClicked(false);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CustomScaffold(
                            body: Frame(
                              customPadding: const EdgeInsets.all(0.0),
                              showLogo: false,
                              child: TrackView(
                                  header: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Styles().mainColor,
                                        ),
                                      ),
                                      const BrandText(),
                                      const SizedBox(width: 24.0)
                                    ],
                                  ),
                                  dailyTrack: dailyTrack,
                                  track: dailyTrack.track,
                                  averageColorOfImage: averageColor),
                            ),
                          )));
                },
                child: Image.network(dailyTrack.track.images.first.url,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(color: Styles().secondaryColor);
                }));
          }
        }

        int dateDay = index - monthOffset + 1;

        context.read<CalendarPageProvider>().setStreak(0);

        return CalendarText(
          index: dateDay,
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
        child: Text('$index',
            style: containsImage
                ? Styles().calendarTextIfImage
                : Styles().calendarText));
  }
}
