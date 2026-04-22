import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cmproject/data/metro_repository.dart';


class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final _formKey = GlobalKey<FormState>();

  final repository = MetroRepository();

  Station? _station;
  String? _type;
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

                  /// Estação
                  DropdownButtonFormField<Station>(
                    key: const Key('incident-station-selection-field'),
                    decoration: const InputDecoration(
                      labelText: 'Selecione',
                    ),
                      items: stations.map((station) {
                        return DropdownMenuItem<Station>(
                          value: station,
                          child: Text(station.name),
                        );
                      }).toList(),
                    onChanged: (value) {
                      _station = value;
                    },
                    validator: (value) =>
                    value == null ? 'Selecione uma estação' : null,
                  ),

                  const SizedBox(height: 16),

                  /// Tipo
                  DropdownButtonFormField<String>(
                    key: const Key('incident-type-selection-field'),
                    decoration: const InputDecoration(
                      labelText: 'Selecione',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Escalator', child: Text('ESCALATOR')),
                      DropdownMenuItem(value: 'Elevator', child: Text('ELEVATOR')),
                      DropdownMenuItem(value: 'Ticket Machine', child: Text('TICKET_MACHINE')),
                      DropdownMenuItem(value: 'Turnstile', child: Text('TURNSTILE')),
                      DropdownMenuItem(value: 'Other', child: Text('OTHER')),
                    ],
                    onChanged: (value) {
                      _type = value;
                    },
                    validator: (value) =>
                    value == null ? 'Preencha o tipo de incidente' : null,
                  ),

                  const SizedBox(height: 16),

                  /// Avaliação
                  TextFormField(
                    key: const Key('incident-rating-field'),
                    decoration: const InputDecoration(
                      labelText: 'Avaliação',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 1 || parsed > 5) {
                        return 'Preencha a avaliação';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _rating = int.tryParse(value ?? '');
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Data e hora
                  TextFormField(
                    key: const Key('incident-datetime-field'),
                    decoration: const InputDecoration(
                      labelText: 'Data e hora',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Preencha a data e hora';
                      }

                      try {
                        DateFormat('dd/MM/yyyy HH:mm').parseStrict(value.trim());
                        return null;
                      } catch (_) {
                        return 'Formato esperado: dd/MM/yyyy HH:mm';
                      }
                    },
                    onSaved: (value) {
                      _dateTime = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Notas
                  TextFormField(
                    key: const Key('incident-notes-field'),
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                    ),
                    maxLines: 2,
                    onSaved: (value) {
                      _notes = value;
                    },
                  ),

                  const SizedBox(height: 32),

                  /// Botão
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