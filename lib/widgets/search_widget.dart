import 'package:flutter/material.dart';
import 'package:daily_spotify/styles.dart';

class Search extends StatefulWidget {
  const Search({super.key, required this.onSubmit});
  final Function(String) onSubmit;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Form(
        key: _formKey,
        child: Row(children: [
          Expanded(
            child: TextFormField(
              controller: textController,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'You have to type something to search...';
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              style: Styles().subtitleText,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Search',
              ),
            ),
          ),
          IconButton(
              onPressed: () => _submit(),
              iconSize: 32.0,
              icon: const Icon(Icons.search)),
        ]),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String searchedTerm = textController.text;

      widget.onSubmit(searchedTerm);
    }
  }
}
