import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/material.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:intl/intl.dart';
import 'package:testable_form_field/testable_form_field.dart';


class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final _formKey = GlobalKey<FormState>();

  final repository = MetroRepository();

  Station? _station;
  IncidentType? _type;
  int? _rating;
  String? _dateTime;
  String? _notes;

  @override
  Widget build(BuildContext context) {

    final stations = repository.getStations();

    return Scaffold(
        key: const Key('incidents-report-screen'),
        appBar: AppBar(
          title: const Text('Incidente'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  /// ESTAÇÃO

                  TestableFormField<Station>(
                    key: const Key('incident-station-selection-field'),

                    getValue: () => _station!,
                    internalSetValue: (state, value) {
                      state.didChange(value);
                      _station = value;
                    },

                    validator: (value) {
                      if (value == null) {
                        return 'Preencha a estação';
                      }
                      return null;
                    },

                    onSaved: (value) {
                      _station = value;
                    },

                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          errorText: field.errorText,
                        ),
                        child: DropdownButton<Station>(
                          value: field.value,
                          hint: const Text('Selecione'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: stations.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            field.didChange(value);
                          },
                        ),
                      );
                    },
                  ),

                  /// TIPO

                  TestableFormField<IncidentType>(
                    key: const Key('incident-type-selection-field'),

                    getValue: () => _type!,
                    internalSetValue: (state, value) {
                      state.didChange(value);
                      _type = value;
                    },

                    validator: (value) {
                      if (value == null) return 'Preencha o tipo de incidente';
                      return null;
                    },
                    onSaved: (value) {
                      _type = value;
                    },

                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          errorText: field.errorText,
                        ),
                        child: DropdownButton<IncidentType>(
                          value: field.value,
                          hint: const Text('Selecione'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: IncidentType.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            field.didChange(value);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  ///AVALIAÇÃO

                  TestableFormField<int>(
                    key: const Key('incident-rating-field'),

                    getValue: () => _rating!,
                    internalSetValue: (state, value) {
                      state.didChange(value);
                      _rating = value;
                    },

                    validator: (value) {
                      if (value == null || value < 1 || value > 5) {
                        return 'Preencha a avaliação';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _rating = value;
                    },

                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          errorText: field.errorText,
                          labelText: 'Avaliação',
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(border: InputBorder.none),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null) field.didChange(parsed);
                          },
                        ),
                      );
                    },
                  ),


                  const SizedBox(height: 16),

                  /// DATA E HORA

                  TestableFormField<DateTime>(
                    key: const Key('incident-datetime-field'),

                    getValue: () => DateFormat('dd/MM/yyyy HH:mm').parse(_dateTime!),
                    internalSetValue: (state, value) {
                      state.didChange(value);
                      _dateTime = DateFormat('dd/MM/yyyy HH:mm').format(value);
                    },

                    validator: (value) {
                      if (value == null) return 'Preencha a data e hora';
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _dateTime = DateFormat('dd/MM/yyyy HH:mm').format(value);
                      }
                    },

                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          errorText: field.errorText,
                          labelText: 'Data e hora',
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            try {
                              final parsed = DateFormat('dd/MM/yyyy HH:mm').parseStrict(value.trim());
                              field.didChange(parsed);
                            } catch (_) {
                              field.didChange(null);
                            }
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// NOTAS

                  TestableFormField<String>(
                    key: const Key('incident-notes-field'),

                    getValue: () => _notes ?? '',
                    internalSetValue: (state, value) {
                      state.didChange(value);
                      _notes = value;
                    },

                    onSaved: (value) {
                      _notes = value;
                    },

                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          errorText: field.errorText,
                          labelText: 'Notas',
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(border: InputBorder.none),
                          maxLines: 2,
                          onChanged: (value) {
                            field.didChange(value);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  /// BOTÃO

                  Center(
                    child: ElevatedButton(
                      key: const Key('incident-form-submit-button'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Incidente submetido'),
                            ),
                          );
                        }
                      },
                      child: const Text('Submeter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}