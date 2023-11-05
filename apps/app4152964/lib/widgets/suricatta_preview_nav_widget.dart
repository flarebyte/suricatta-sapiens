import 'package:flutter/material.dart';

import '../model/widget_model.dart';
import '../styling/widget_styling.dart';

class SuricattaPreviewNavigationWidget extends StatefulWidget {
  const SuricattaPreviewNavigationWidget({
    super.key,
    required this.label,
  });

  final String label;

  @override
  SuricattaPreviewNavigationWidgetState createState() =>
      SuricattaPreviewNavigationWidgetState();
}

class SuricattaPreviewNavigationWidgetState
    extends State<SuricattaPreviewNavigationWidget> {
  List<NavigationPath> navigationPaths = [];

  void _setNavigationPaths(List<NavigationPath> updated) {
    setState(() {
      navigationPaths = updated;
    });
  }

  @override
  void initState() {
    super.initState();
    navigationPaths = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: navigationPaths.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                getNavigationPathStatusIcon(navigationPaths[index].status),
                color:
                    getNavigationPathStatusColor(navigationPaths[index].status),
              ),
              title: Text(navigationPaths[index].title),
              subtitle: Text(navigationPaths[index].preview),
              onTap: () {
                // TODO: implement navigation functionality
              },
            );
          },
        ));
  }
}
