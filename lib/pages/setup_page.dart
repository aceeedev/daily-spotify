import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart' as spotify;
import 'package:daily_spotify/pages/home_page.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';

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
            stepWidgets[context.watch<SetupForm>().step],
            const Spacer(),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    getNavigationStepButtons(context.read<SetupForm>().step)),
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
      stepCircleIcons.add(Icon(i < step
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

class StepOne extends StatefulWidget {
  const StepOne({super.key});

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Step One'),
        const Text(
            'First we need to personalize your music taste by viewing your Spotify account'),
        TextButton(
          onPressed: () async {
            //spotify.authorizationCodeFlowWithPKCE();

            String? authCode = await spotify.requestUserAuthWithPKCE();
            print(authCode);
          },
          child: const Text('Login with Spotify'),
        ),
      ],
    );
  }
}

class StepTwo extends StatefulWidget {
  const StepTwo({super.key});

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
  @override
  Widget build(BuildContext context) {
    return const Text("Step Two");
  }
}

class StepThree extends StatefulWidget {
  const StepThree({super.key});

  @override
  State<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends State<StepThree> {
  @override
  Widget build(BuildContext context) {
    return const Text("Step Three");
  }
}

class StepFour extends StatefulWidget {
  const StepFour({super.key});

  @override
  State<StepFour> createState() => _StepFourState();
}

class _StepFourState extends State<StepFour> {
  @override
  Widget build(BuildContext context) {
    return const Text("Step Four");
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
      child: IconButton(
          onPressed: () {
            if (context.read<SetupForm>().step >= 3 && nextOrPrevious) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()));
            } else {
              context.read<SetupForm>().addToStep(nextOrPrevious ? 1 : -1);
            }
          },
          icon: Icon(
              nextOrPrevious ? Icons.navigate_next : Icons.navigate_before,
              size: 40.0)),
    );
  }
}
