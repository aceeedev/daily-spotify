import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/pages/home_page.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/step_one.dart';
import 'package:daily_spotify/widgets/step_two.dart';
import 'package:daily_spotify/widgets/step_three.dart';
import 'package:daily_spotify/widgets/step_four.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final List<Widget> stepWidgets = const [
    StepOne(),
    StepTwo(),
    StepThree(),
    StepFour()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lets Setup'),
      ),
      body: Frame(
        child: Column(
          children: <Widget>[
            Expanded(child: stepWidgets[context.watch<SetupForm>().step]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      getNavigationStepButtons(context.read<SetupForm>().step)),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getStepCircleIcons(context.read<SetupForm>().step),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getStepCircleIcons(int step) {
    List<Widget> stepCircleIcons = [];

    int totalSteps = 4;
    for (int i = 0; i < totalSteps; i++) {
      stepCircleIcons.add(Icon(i == step
          ? Icons.radio_button_checked
          : Icons.radio_button_unchecked));
    }

    return stepCircleIcons;
  }

  List<Widget> getNavigationStepButtons(step) {
    List<Widget> navigationStepButtons = [];

    // previous step button
    if (step > 0) {
      navigationStepButtons
          .add(const NextOrPreviousStepButton(nextOrPrevious: false));
      navigationStepButtons.add(const Spacer());
    } else {
      navigationStepButtons.add(const Spacer());
    }

    // next step button
    navigationStepButtons.add(const Spacer());
    navigationStepButtons
        .add(const NextOrPreviousStepButton(nextOrPrevious: true));

    return navigationStepButtons;
  }
}

/// A widget that can either be a next or previous icon button depending on
/// the parameter passed.
///
/// [nextOrPrevious] when true the widget becomes a next step button and when
/// false the widget becomes a previous step button.
class NextOrPreviousStepButton extends StatelessWidget {
  const NextOrPreviousStepButton({super.key, required this.nextOrPrevious});
  final bool nextOrPrevious;
  final double paddingSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(!nextOrPrevious ? paddingSize : 0, 0,
          nextOrPrevious ? paddingSize : 0, 0),
      child: !nextOrPrevious || context.watch<SetupForm>().finishedStep
          ? IconButton(
              onPressed: () async {
                if (context.read<SetupForm>().step >= 3 && nextOrPrevious) {
                  // last step--finished step 4
                  await db.Config.instance.saveGenreConfig(
                      context.read<SetupForm>().selectedGenreList);
                  await db.Config.instance.saveArtistConfig(
                      context.read<SetupForm>().selectedArtistList);
                  await db.Config.instance.saveTrackConfig(
                      context.read<SetupForm>().selectedTrackList);

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomePage()));
                } else {
                  context.read<SetupForm>().addToStep(nextOrPrevious ? 1 : -1);

                  //context.read<SetupForm>().setFinishedStep(false);
                }
              },
              icon: Icon(
                  nextOrPrevious ? Icons.navigate_next : Icons.navigate_before,
                  size: 40.0))
          : const SizedBox.shrink(),
    );
  }
}
