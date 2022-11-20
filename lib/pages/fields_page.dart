import 'dart:math';

import 'package:beat_the_beetroot/firebase/firestore_refs.dart';
import 'package:beat_the_beetroot/pages/field_markup_page.dart';
import 'package:beat_the_beetroot/pages/field_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FieldsPage extends StatefulWidget {
  const FieldsPage({super.key});

  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  final _formKey = GlobalKey<FormState>();
  late String _newFieldName;
  final _stream = fieldsRef.snapshots();

  Future<bool> get _locationPermissionGranted async {
    return await Permission.location.request().isGranted;
  }

  @override
  void initState() {
    super.initState();
    _locationPermissionGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поля'),
        centerTitle: true,
      ),
      body: StreamBuilder(
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

          final fieldsSnapshots = snapshot.data!.docs;
          final fields = fieldsSnapshots.map((snapshot) {
            return snapshot.data();
          }).toList();

          if (fields.isEmpty) {
            return const Center(child: Text('Полей нет'));
          }

          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              return ListTile(
                title: Text(field.name),
                subtitle: Text(
                  'Координаты центра: ${field.center.latitude}, ${field.center.longitude}',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: ((context) {
                        return FieldPage(fieldId: fieldsSnapshots[index].id);
                      }),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 5,
          left: 20,
          right: 20,
        ),
        child: SizedBox(
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
                            'Назовите поле',
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
                              labelText: 'Название',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите название поля';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _newFieldName = newValue!;
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
                                    return FieldMarkupPage(
                                      fieldName: _newFieldName,
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                'Создать',
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
                'Добавить поле',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
