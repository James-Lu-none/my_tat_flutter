// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';

import 'package:flutter_app/ui/pages/score/widgets/metrics_title_widget.dart';
import 'add_course_page.dart';

class CourseSelectionPage extends StatefulWidget {
  const CourseSelectionPage({super.key});
  @override
  State<StatefulWidget> createState() => _CourseSelectionPage();
}

class _CourseSelectionPage extends State<CourseSelectionPage> {
  @override
  List<String> _courseCodeList = [
    '123456',
    '456945',
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("選課小幫手"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MetricsTitle(title: "選課小幫手"),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _courseCodeList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                final data = _courseCodeList[index];
                return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(data));
              },
            ),
            IconButton(onPressed: onPressed, icon: Icon(Icons.add_circle_outline))
          ],
        ),
      ),
    );
  }

  void onPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(onSubmit: handleDataFromPopup);
      },
    );
  }

  void handleDataFromPopup(String courseCode) {
    setState(() {
      _courseCodeList.add(courseCode);
    });
  }
}
