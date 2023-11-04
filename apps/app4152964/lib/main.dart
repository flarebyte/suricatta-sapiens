import 'package:app4152964/widgets/suricatta_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'model/widget_model.dart';

void main() {
  runApp(const MyApp());
}

final RegExp regExpForWord = RegExp(r"[\w-._]+");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu button with icon
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    // TODO: implement menu functionality
                  },
                ),
                // Dashboard button
                TextButton(
                  child: Text('Dashboard'),
                  onPressed: () {
                    // TODO: implement dashboard functionality
                  },
                ),
                // Profile button
                TextButton(
                  child: Text('Profile'),
                  onPressed: () {
                    // TODO: implement profile functionality
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown list
                DropdownButton<String>(
                  value: 'Option 1',
                  items: [
                    DropdownMenuItem(
                      child: Text('Option 1'),
                      value: 'Option 1',
                    ),
                    DropdownMenuItem(
                      child: Text('Option 2'),
                      value: 'Option 2',
                    ),
                    DropdownMenuItem(
                      child: Text('Option 3'),
                      value: 'Option 3',
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: implement dropdown functionality
                  },
                ),
                // Previous button
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // TODO: implement previous functionality
                  },
                ),
                // Next button
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    // TODO: implement next functionality
                  },
                ),
              ],
            ),
            SuricattaTextField(
                label: AppLocalizations.of(context)!.helloWorld,
                hint: 'Some hint',
                controller: myTextController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return [
                      Message("Enter some text:\n- Be relevant\n- Be concise",
                          Level.info, Category.syntax),
                    ];
                  }
                  if (value.isNotEmpty && value.length < 5) {
                    return [
                      Message("Invalid syntax", Level.error, Category.syntax),
                      Message(
                          "Misspelled word", Level.warning, Category.spelling)
                    ];
                  }
                  return [
                    Message("Looks good so far", Level.info, Category.syntax),
                    Message(
                        "${value.length} characters, ${regExpForWord.allMatches(value).length} words.",
                        Level.info,
                        Category.syntax)
                  ];
                }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    myTextController.dispose();
    super.dispose();
  }
}
