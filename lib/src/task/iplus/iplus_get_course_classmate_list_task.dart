// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';
import 'package:flutter_app/src/task/task.dart';

import 'dart:developer' as developer;

class IPlusCourseClassmateList extends IPlusSystemTask<List<ClassmateJson>> {
  final String id;

  IPlusCourseClassmateList(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourseClassmateList);
      final value = await ISchoolPlusConnector.getCourseClassmateList(id);
      super.onEnd();

      result = value;
      developer.log(result.toString());

      if(result != null) {
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseClassmateListError);
      }
    }
    return status;
  }
}