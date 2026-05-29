import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/material.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<List<Station>>? _stationsFuture;

  Station? _station;
  IncidentType? _type;
  int? _rating;
  DateTime? _dateTime;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();

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
            child: FutureBuilder<List<Station>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar estações: ${snapshot.error}'));
                }

                final stations = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    /// ESTAÇÃO
                    TestableFormField<Station>(
                      key: const Key('incident-station-selection-field'),

                      getValue: () {
                        return _station as Station;
                      },

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
                        final selectedValue = stations.any((s) => s == field.value)
                            ? field.value
                            : null;

                        return InputDecorator(
                          decoration: InputDecoration(
                            errorText: field.errorText,
                          ),
                          child: DropdownButton<Station>(
                            value: selectedValue,
                            hint: const Text('Selecione'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: stations.map((station) {
                              return DropdownMenuItem<Station>(
                                value: station,
                                child: Text(station.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              field.didChange(value);
                              _station = value;
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TIPO
                    TestableFormField<IncidentType>(
                      key: const Key('incident-type-selection-field'),

                      getValue: () {
                        return _type as IncidentType;
                      },

                      internalSetValue: (state, value) {
                        state.didChange(value);
                        _type = value;
                      },

                      validator: (value) {
                        if (value == null) {
                          return 'Preencha o tipo de incidente';
                        }
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
                            items: IncidentType.values.map((type) {
                              return DropdownMenuItem<IncidentType>(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              field.didChange(value);
                              _type = value;
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// AVALIAÇÃO
                    TestableFormField<int>(
                      key: const Key('incident-rating-field'),

                      getValue: () {
                        return _rating as int;
                      },

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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              field.didChange(parsed);
                              _rating = parsed;
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// DATA E HORA
                    TestableFormField<DateTime>(
                      key: const Key('incident-datetime-field'),

                      getValue: () {
                        return _dateTime as DateTime;
                      },

                      internalSetValue: (state, value) {
                        state.didChange(value);
                        _dateTime = value;
                      },

                      validator: (value) {
                        if (value == null) {
                          return 'Preencha a data e hora';
                        }
                        return null;
                      },

                      onSaved: (value) {
                        _dateTime = value;
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
                                final parsed = DateFormat('dd/MM/yyyy HH:mm')
                                    .parseStrict(value.trim());
                                field.didChange(parsed);
                                _dateTime = parsed;
                              } catch (_) {
                                field.didChange(null);
                                _dateTime = null;
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

                      getValue: () {
                        return _notes ?? '';
                      },

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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            maxLines: 2,
                            onChanged: (value) {
                              field.didChange(value);
                              _notes = value;
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

                            final report = IncidentReport(
                              timestamp: _dateTime!,
                              rate: _rating!,
                              notes: _notes,
                              type: _type!,
                            );

                            repository.attachIncident(_station!.id, report);

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

                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}