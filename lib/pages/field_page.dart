import 'dart:math';

import 'package:beat_the_beetroot/firebase/firestore_refs.dart';
import 'package:beat_the_beetroot/models/field.dart';
import 'package:beat_the_beetroot/pages/field_collect_page.dart';
import 'package:beat_the_beetroot/widgets/field_report_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldPage extends StatefulWidget {
  const FieldPage({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<FieldPage> createState() => _FieldPageState();
}

class _FieldPageState extends State<FieldPage> {
  final _formKey = GlobalKey<FormState>();
  late double _newCollectorRadius;
  late Stream<DocumentSnapshot<Field>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = fieldsRef.doc(widget.fieldId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Что-то пошло не так')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Text('Загрузка')),
          );
        }

        final field = snapshot.data!.data()!;

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text('Поле: ${field.name}'),
            centerTitle: true,
          ),
          body: FieldReportMap(field: field),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 5,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: max(
                                    MediaQuery.of(context).viewInsets.bottom,
                                    MediaQuery.of(context).padding.bottom,
                                  ) +
                                  5,
                              left: 20,
                              right: 20,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Введите данные о сборе',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Радиус сбора',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Введите радиус сбора';
                                      }

                                      if (double.tryParse(value) == null) {
                                        return 'Введите число';
                                      }

                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _newCollectorRadius = double.parse(
                                        newValue!,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(
                                        50,
                                      ), // fromHeight use double.infinity as width and 40 is the height
                                    ),
                                    onPressed: () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      _formKey.currentState!.save();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return FieldCollectPage(
                                              field: field,
                                              collectorRadius:
                                                  _newCollectorRadius,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Начать сбор',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Center(
                      child: Text(
                        'Начать сбор',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      fieldsRef.doc(widget.fieldId).delete();
                    },
                    child: const Center(
                      child: Text(
                        'Удалить поле',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
