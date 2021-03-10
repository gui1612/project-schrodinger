import 'package:uni/model/app_state.dart';
import 'package:uni/model/entities/exam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:uni/view/Pages/secondary_page_view.dart';
import 'package:uni/view/Widgets/exam_page_title_filter.dart';
import 'package:uni/view/Widgets/row_container.dart';
import 'package:uni/view/Widgets/schedule_row.dart';
import 'package:uni/view/Widgets/title_card.dart';

class ExamsPageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ExamsPageViewState();
}

class ExamsPageViewState extends SecondaryPageViewState {
  final double borderRadius = 10.0;

  //TODO Descobrir pq que os valores estao null
  @override
  Widget getBody(BuildContext context) {
    return StoreConnector<AppState, List<dynamic>>(
      converter: (store) {
        final List<Exam> exams = store.state.content['exams'];
        final Map<String, bool> filteredExams =
            store.state.content['filteredExams'];
        List<Exam> examListFiltered = [];


          print(filteredExams);
          for(Exam exam in exams){
            bool checked = filteredExams[Exam.getExamTypeLong(exam.examType)] ?? false;
            print(checked);
            if(checked) examListFiltered.add(exam);
          }
 
        return examListFiltered;
            // .where((exam) => filteredExams[Exam.getExamTypeLong(exam.examType)] && exam.examType!=null )
            // .toList();
      },
      builder: (context, exams) {
        return ExamsList(exams: exams);
      },
    );
  }

  // List<String> getCheckedExamTypes(Map<String, bool> filteredExamMap) {
  //   List<String> filteredExamList;
  //   final Iterable<String> examTypes = Exam.getExamTypes().keys;
  //   examTypes.forEach((type) {
  //     if (filteredExamMap[type] = true) filteredExamList.add(type);
  //   });
  //   return filteredExamList;
  // }

  // @override
  // Widget getBody(BuildContext context) {
  //   return StoreConnector<AppState, List<dynamic>>(
  //     converter: (store) => store.state.content['filteredExams'],
  //     builder: (context, exams) {
  //       for (Exam exam in exams) {
  //         //Exam type é a abrev
  //         print(exam.examType);
  //         if()
  //       }
  //       return ExamsList(exams: exams);
  //     },
  //   );
  // }

  //TODO Talvez aqui fizesse mais sentido ele ser criado logo com os exames filtrados
  // Transformar mapa na lista dos que estiverem a true
  // Widget getBody1(BuildContext context) {
  //   return StoreConnector<AppState, List<dynamic>>(
  //     converter: (store) => store.state.content['filteredExams'],
  //     builder: (context, filteredExams) {
  //       return ExamsList(exams: filteredExams);
  //     },
  //   );
  // }
}

// ignore: must_be_immutable
class ExamsList extends StatelessWidget {
  final List<Exam> exams;
  Map<String, bool> pretendedExamTypes;

  ExamsList({Key key, @required this.exams}) : super(key: key) {
    //TODO This should be in the database
    pretendedExamTypes = checkboxValues();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: this.createExamsColumn(context, exams),
          ),
        )
      ],
    );
  }

  List<Widget> createExamsColumn(context, exams) {
    final List<Widget> columns = List<Widget>();
    columns.add(ExamPageTitleFilter(
      name: 'Exames',
      pretendedExams: pretendedExamTypes,
    ));

    if (exams.length == 1) {
      columns.add(this.createExamCard(context, [exams[0]]));
      return columns;
    }

    final List<Exam> currentDayExams = List<Exam>();

    for (int i = 0; i < exams.length; i++) {
      final examTypeLong = Exam.getExamTypeLong(exams[i].examType);
      //TODO Passar a frente caso no mapa esteja a falso
      //if (!pretendedExamTypes[examTypeLong]) continue;
      if (i + 1 >= exams.length) {
        if (exams[i].day == exams[i - 1].day &&
            exams[i].month == exams[i - 1].month) {
          currentDayExams.add(exams[i]);
        } else {
          if (currentDayExams.isNotEmpty) {
            columns.add(this.createExamCard(context, currentDayExams));
          }
          currentDayExams.clear();
          currentDayExams.add(exams[i]);
        }
        columns.add(this.createExamCard(context, currentDayExams));
        break;
      }
      if (exams[i].day == exams[i + 1].day &&
          exams[i].month == exams[i + 1].month) {
        currentDayExams.add(exams[i]);
      } else {
        currentDayExams.add(exams[i]);
        columns.add(this.createExamCard(context, currentDayExams));
        currentDayExams.clear();
      }
    }
    return columns;
  }

  Widget createExamCard(context, exams) {
    final keyValue = exams.map((exam) => exam.toString()).join();
    return Container(
      key: Key(keyValue),
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      child: this.createExamsCards(context, exams),
    );
  }

  Widget createExamsCards(context, exams) {
    final List<Widget> examCards = List<Widget>();
    examCards.add(TitleCard(
        day: exams[0].day, weekDay: exams[0].weekDay, month: exams[0].month));
    for (int i = 0; i < exams.length; i++) {
      examCards.add(this.createExamContext(context, exams[i]));
    }
    return Column(children: examCards);
  }

  Widget createExamContext(context, exam) {
    final keyValue = '${exam.toString()}-exam';
    return Container(
        key: Key(keyValue),
        margin: EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: RowContainer(
            child: ScheduleRow(
                subject: exam.subject,
                rooms: exam.rooms,
                begin: exam.begin,
                end: exam.end,
                type: exam.examType)));
  }

  //TODO Adicionar isto no app shared preferences
  Map<String, bool> checkboxValues() {
    final Iterable<String> examTypes = Exam.getExamTypes().keys;
    final Map<String, bool> chekboxes = {};
    examTypes.forEach((type) => chekboxes[type] = true);
    return chekboxes;
  }
}
