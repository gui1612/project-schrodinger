import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:uni/model/app_state.dart';
import 'package:uni/redux/action_creators.dart';

// ignore: must_be_immutable
class ExamFilterMenu extends StatefulWidget {
  //TODO
  // Isto com as checkboxes dava, mas ao adicionar o storeConnector isto deixou de atualizar
  //Verificar que os exams da epoca de covid aparecem com ?
  //Verificar o que acontece quando ele nao tem shared preferences
  //StoreConnector mais dentro tb nao funciona
  //uma opçao é ir buscar os dados aqui, e no state usar o valor
  //Versao a funcionar no commit anterior
  //Ver a questão dos exams covid
  @override
  _ExamFilterMenuState createState() => _ExamFilterMenuState();
}

class _ExamFilterMenuState extends State<ExamFilterMenu> {
  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    final store = StoreConnector<AppState, Map<String, bool>>(
        converter: (store) => store.state.content['filteredExams'],
        builder: (context, filteredExams) {
          return AlertDialog(
            content: Container(
                height: 300.0,
                width: 200.0,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return ListView(
                    children: filteredExams.keys.map((String key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: filteredExams[key],
                        onChanged: (bool value) {
                          setState(() {
                            filteredExams[key] = value;
                            //Not calling OnChanged?
                            print("ZAAAS" + value.toString());
                            StoreProvider.of<AppState>(context)
                                .dispatch(setFilteredExams(key, Completer()));
                          });
                        },
                      );
                    }).toList(),
                  );
                })),
          );
        });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return store;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () {
        showAlertDialog(context);
      },
    );
  }
}
