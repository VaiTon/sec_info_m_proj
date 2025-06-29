// SPDX-FileCopyrightText: 2025 Eyad Issa <eyadlorenzo@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:almastudio/oauth.dart';

class UniboAPI {
  final String baseUrl;
  final OAuthToken token;

  UniboAPI({
    this.baseUrl = 'https://services.unibo.it/myunibo/api',
    required this.token,
  });

  Future<http.Response> _getWithAuth(String url) async {
    return await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${token.accessToken}',
        'Accept': 'application/json',
      },
    );
  }

  Future<MeResponse> getMe() async {
    final String url = '$baseUrl/me';
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      return MeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load user data: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  Future<StudyPlanResponse> getStudyPlans(String id) async {
    final String url = '$baseUrl/studyPlans/$id';
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      return StudyPlanResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load study plans: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<StatsResponse> getStats(String id) async {
    final String url = '$baseUrl/stats/$id';
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      return StatsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load stats: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  Future<List<EnrolledExam>> getEnrolledExams(String id) async {
    final String url = '$baseUrl/studyPlans/$id/trialList/enrolled';
    final response = await _getWithAuth(url);

    if (response.statusCode == 200) {
      return (List<EnrolledExam>.from(
        jsonDecode(response.body).map((e) => EnrolledExam.fromJson(e)),
      ));
    } else {
      throw Exception(
        'Failed to load enrolled exams: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }
}

// Represents the response from the /me endpoint
class MeResponse {
  final String id;
  final String name;
  final String surname;
  final String gender;
  final String email;
  final String? photo;
  final bool admin;
  final List<Career> careers;

  MeResponse({
    required this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.email,
    required this.photo,
    required this.admin,
    required this.careers,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': var id,
        'name': String name,
        'surname': String surname,
        'gender': String gender,
        'email': String email,
        'photo': var photo,
        'admin': bool admin,
        'careers': List careers,
      } =>
        MeResponse(
          id: id.toString(),
          name: name,
          surname: surname,
          gender: gender,
          email: email,
          photo: photo as String?,
          admin: admin,
          careers: careers
              .map((e) => Career.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      _ => throw Exception('Invalid MeResponse JSON format'),
    };
  }
}

class Career {
  final String id;
  final String code;
  final String description;
  final String type;
  final String status;
  final String registrationNumber;
  final String? registrationDate;
  final String? graduationDate;
  final Outcome? graduationOutcome;
  final String? graduationTitle;
  final String? graduationLevel;
  final String? graduationClass;

  Career({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.status,
    required this.registrationNumber,
    this.registrationDate,
    this.graduationDate,
    this.graduationOutcome,
    this.graduationTitle,
    this.graduationLevel,
    this.graduationClass,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'programmeCode': var code,
        'programmeDescription': String? description,
        'programmeType': String? type,
        'statusDescription': String? status,
        'registrationNumber': String? registrationNumber,
        'graduationOutcome': var graduationOutcome,
      } =>
        Career(
          id: code?.toString() ?? '',
          code: code?.toString() ?? '',
          description: description ?? '',
          type: type ?? '',
          status: status ?? '',
          registrationNumber: registrationNumber ?? '',
          registrationDate: null,
          graduationDate: null,
          graduationOutcome: graduationOutcome != null
              ? Outcome.fromJson(graduationOutcome as Map<String, dynamic>)
              : null,
          graduationTitle: null,
          graduationLevel: null,
          graduationClass: null,
        ),
      _ => throw Exception('Invalid Career JSON format'),
    };
  }
}

class Outcome {
  final String value;
  final String type;
  final bool passed;
  final bool honours;
  final int base;
  final String? date;

  Outcome({
    required this.value,
    required this.type,
    required this.passed,
    required this.honours,
    required this.base,
    this.date,
  });

  factory Outcome.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'value': var value,
        'type': var type,
        'passed': bool? passed,
        'honours': bool? honours,
        'base': int? base,
        'date': String? date,
      } =>
        Outcome(
          value: value?.toString() ?? '',
          type: type?.toString() ?? '',
          passed: passed ?? false,
          honours: honours ?? false,
          base: base ?? 0,
          date: date,
        ),
      _ => throw Exception('Invalid Outcome JSON format'),
    };
  }
}

class StudyPlanResponse {
  final List<LearningActivity> learningActivities;

  StudyPlanResponse({required this.learningActivities});

  factory StudyPlanResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'learningActivities': List learningActivities} => StudyPlanResponse(
        learningActivities: learningActivities
            .map((e) => LearningActivity.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      _ => throw Exception('Invalid StudyPlanResponse JSON format'),
    };
  }
}

class LearningActivity {
  final int? programmeYear;
  final String code;
  final String description;
  final int? credits;
  final bool? useful;
  final DateTime? recordDate;
  final Outcome? outcome;
  final String id;

  LearningActivity({
    required this.programmeYear,
    required this.code,
    required this.description,
    required this.credits,
    required this.useful,
    required this.recordDate,
    required this.outcome,
    required this.id,
  });

  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'programmeYear': int? programmeYear,
        'code': String code,
        'description': String description,
        'credits': int? credits,
        'useful': bool? useful,
        'recordDate': String? recordDate,
        'outcome': var outcome,
        'id': String id,
      } =>
        LearningActivity(
          programmeYear: programmeYear,
          code: code,
          description: description,
          credits: credits,
          useful: useful,
          recordDate: recordDate != null ? DateTime.tryParse(recordDate) : null,
          outcome: outcome != null
              ? Outcome.fromJson(outcome as Map<String, dynamic>)
              : null,
          id: id,
        ),
      _ => throw Exception('Invalid LearningActivity JSON format'),
    };
  }
}

class StatsResponse {
  final DegreeStats degree;
  final ExamsStats exams;
  final CreditsStats credits;

  StatsResponse({
    required this.degree,
    required this.exams,
    required this.credits,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'degree': Map<String, dynamic> degree,
        'exams': Map<String, dynamic> exams,
        'credits': Map<String, dynamic> credits,
      } =>
        StatsResponse(
          degree: DegreeStats.fromJson(degree),
          exams: ExamsStats.fromJson(exams),
          credits: CreditsStats.fromJson(credits),
        ),
      _ => throw Exception('Invalid StatsResponse JSON format'),
    };
  }
}

class DegreeStats {
  final double average;

  DegreeStats({required this.average});

  factory DegreeStats.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'average': num average} => DegreeStats(average: average.toDouble()),
      _ => throw Exception('Invalid DegreeStats JSON format'),
    };
  }
}

class ExamsStats {
  final double average;
  final int count;
  final int honours;

  ExamsStats({
    required this.average,
    required this.count,
    required this.honours,
  });

  factory ExamsStats.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'average': num average, 'count': int count, 'honours': int honours} =>
        ExamsStats(average: average.toDouble(), count: count, honours: honours),
      _ => throw Exception('Invalid ExamsStats JSON format'),
    };
  }
}

class CreditsStats {
  final double passed;
  final int required;
  final dynamic finalExam;

  CreditsStats({required this.passed, required this.required, this.finalExam});

  factory CreditsStats.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'passed': num passed,
        'required': int required,
        'finalExam': var finalExam,
      } =>
        CreditsStats(
          passed: passed.toDouble(),
          required: required,
          finalExam: finalExam,
        ),
      _ => throw Exception('Invalid CreditsStats JSON format'),
    };
  }
}

// --- Data Models ---
class EnrolledExam {
  final String id;
  final TrialId trialId;
  final ExamState state;
  final String description;
  final DateTime date;
  final String place;
  final LearningActivity learningActivity;
  final DateTime? bookingStartDate;
  final DateTime? bookingEndDate;
  final dynamic outcome;
  final bool cancelable;
  final bool bookable;
  final DateTime bookingDate;
  final Teacher teacher;
  final DateTime? confirmationDeadline;
  final int placement;
  final int placementBase;
  final String placementType;
  final String type;
  final bool multipleSessions;
  final bool mustFilled;
  final String? note;
  final bool enrolled;

  EnrolledExam({
    required this.id,
    required this.trialId,
    required this.state,
    required this.description,
    required this.date,
    required this.place,
    required this.learningActivity,
    this.bookingStartDate,
    this.bookingEndDate,
    this.outcome,
    required this.cancelable,
    required this.bookable,
    required this.bookingDate,
    required this.teacher,
    this.confirmationDeadline,
    required this.placement,
    required this.placementBase,
    required this.placementType,
    required this.type,
    required this.multipleSessions,
    required this.mustFilled,
    this.note,
    required this.enrolled,
  });

  factory EnrolledExam.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'trialId': Map<String, dynamic> trialId,
        'state': Map<String, dynamic> state,
        'description': String description,
        'date': String date,
        'place': String place,
        'learningActivity': Map<String, dynamic> learningActivity,
        'cancelable': bool cancelable,
        'bookable': bool bookable,
        'bookingDate': String bookingDate,
        'teacher': Map<String, dynamic> teacher,
        'placementType': String placementType,
        'type': String type,
        'multipleSessions': bool multipleSessions,
        'mustFilled': bool mustFilled,
        'enrolled': bool enrolled,
      } =>
        EnrolledExam(
          id: id,
          trialId: TrialId.fromJson(trialId),
          state: ExamState.fromJson(state),
          description: description,
          date: DateTime.parse(date),
          place: place,
          learningActivity: LearningActivity.fromJson(learningActivity),
          bookingStartDate:
              json['bookingStartDate'] is String &&
                  (json['bookingStartDate'] as String).isNotEmpty
              ? DateTime.tryParse(json['bookingStartDate'])
              : null,
          bookingEndDate:
              json['bookingEndDate'] is String &&
                  (json['bookingEndDate'] as String).isNotEmpty
              ? DateTime.tryParse(json['bookingEndDate'])
              : null,
          outcome: json['outcome'],
          cancelable: cancelable,
          bookable: bookable,
          bookingDate: DateTime.parse(bookingDate),
          teacher: Teacher.fromJson(teacher),
          confirmationDeadline:
              json['confirmationDeadline'] is String &&
                  (json['confirmationDeadline'] as String).isNotEmpty
              ? DateTime.tryParse(json['confirmationDeadline'])
              : null,
          placement: json['placement'] as int? ?? 0,
          placementBase: json['placementBase'] as int? ?? 0,
          placementType: placementType,
          type: type,
          multipleSessions: multipleSessions,
          mustFilled: mustFilled,
          note: json['note'] as String?,
          enrolled: enrolled,
        ),
      _ => throw Exception('Invalid EnrolledExam JSON format'),
    };
  }
}

class TrialId {
  final RegistrationNumber registrationNumber;
  final String externalId;

  TrialId({required this.registrationNumber, required this.externalId});

  factory TrialId.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'externalId': String externalId,
        'registrationNumber': Map<String, dynamic> registrationNumber,
      } =>
        TrialId(
          registrationNumber: RegistrationNumber.fromJson(registrationNumber),
          externalId: externalId,
        ),
      _ => throw Exception('Invalid TrialId JSON format'),
    };
  }
}

class RegistrationNumber {
  final int registrationNumber;
  RegistrationNumber({required this.registrationNumber});

  factory RegistrationNumber.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'registrationNumber': int registrationNumber} => RegistrationNumber(
        registrationNumber: registrationNumber,
      ),
      _ => throw Exception('Invalid RegistrationNumber JSON format'),
    };
  }
}

class ExamState {
  final String type;
  final dynamic info;
  ExamState({required this.type, this.info});
  factory ExamState.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'type': String type, 'info': var info} => ExamState(
        type: type,
        info: info,
      ),
      _ => throw Exception('Invalid ExamState JSON format'),
    };
  }
}

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  Teacher({required this.id, required this.firstName, required this.lastName});
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'firstName': String firstName,
        'lastName': String lastName,
      } =>
        Teacher(id: id, firstName: firstName, lastName: lastName),
      _ => throw Exception('Invalid Teacher JSON format'),
    };
  }
}
