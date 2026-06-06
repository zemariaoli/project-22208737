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

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _station = null;
      _type = null;
      _rating = null;
      _dateTime = null;
      _notes = null;
    });
  }


  Future<void> _submitForm(MetroRepository repository) async {
    // LOG 1: Verificar se o botão está a funcionar
    debugPrint('--- [DEBUG] Botão Submeter pressionado ---');

    if (!_formKey.currentState!.validate()) {
      // LOG 2: O formulário falhou na validação visual
      debugPrint('--- [DEBUG] Erro: O formulário NÃO é válido! ---');
      return;
    }

    _formKey.currentState!.save();
    debugPrint('--- [DEBUG] Formulário validado e guardado com sucesso ---');

    final report = IncidentReport(
      timestamp: _dateTime!,
      rate: _rating!,
      notes: _notes,
      type: _type!,
    );

    try {
      debugPrint('--- [DEBUG] A iniciar chamada ao repositório... ---');
      await repository.attachIncident(_station!.id, report);
      debugPrint('--- [DEBUG] Sucesso no repositório! ---');
    } catch (erro) {
      // LOG 3: Se a tua API ou Base de Dados der erro, vai cair aqui
      debugPrint('--- [DEBUG] ERRO GRAVE NO REPOSITÓRIO: $erro ---');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao submeter: $erro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // LOG 4: Verificar se o ecrã não foi fechado durante o 'await'
    if (!mounted) {
      debugPrint('--- [DEBUG] Erro: O widget já não está "mounted" na árvore! ---');
      return;
    }

    debugPrint('--- [DEBUG] A disparar a SnackBar de sucesso... ---');

    // Limpa qualquer SnackBar pendente antes de mostrar a nova
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incidente submetido'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _resetForm();
        debugPrint('--- [DEBUG] Formulário limpo e reiniciado ---');
      }
    });
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFFB71C1C),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? errorText}) {
    return InputDecoration(
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCDD5E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCDD5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();

    return Scaffold(
      key: const Key('incidents-report-screen'),
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Reportar Incidente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: FutureBuilder<List<Station>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final stations = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8E0000),
                            Color(0xFFC62828),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C1C).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.report_problem_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reporte um Incidente',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Ajude a melhorar a experiência dos passageiros',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FORMULÁRIO
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFFB71C1C),
                            width: 4,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ESTAÇÃO
                          _buildLabel('Estação'),
                          TestableFormField<Station>(
                            key: const Key('incident-station-selection-field'),
                            getValue: () => _station as Station,
                            internalSetValue: (state, value) {
                              state.didChange(value);
                              _station = value;
                            },
                            validator: (v) => v == null ? 'Preencha a estação' : null,
                            onSaved: (v) => _station = v,
                            builder: (field) {
                              final selectedValue = stations.any((s) => s == field.value)
                                  ? field.value
                                  : null;
                              return InputDecorator(
                                decoration: _fieldDecoration(errorText: field.errorText),
                                child: DropdownButton<Station>(
                                  value: selectedValue,
                                  hint: const Text('Selecione uma estação',
                                      style: TextStyle(color: Color(0xFF9AA5B4))),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: stations.map((s) => DropdownMenuItem<Station>(
                                    value: s,
                                    child: Text(s.name),
                                  )).toList(),
                                  onChanged: (value) {
                                    field.didChange(value);
                                    _station = value;
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // TIPO
                          _buildLabel('Tipo de incidente'),
                          TestableFormField<IncidentType>(
                            key: const Key('incident-type-selection-field'),
                            getValue: () => _type as IncidentType,
                            internalSetValue: (state, value) {
                              state.didChange(value);
                              _type = value;
                            },
                            validator: (v) => v == null ? 'Preencha o tipo de incidente' : null,
                            onSaved: (v) => _type = v,
                            builder: (field) => InputDecorator(
                              decoration: _fieldDecoration(errorText: field.errorText),
                              child: DropdownButton<IncidentType>(
                                value: field.value,
                                hint: const Text('Selecione o tipo',
                                    style: TextStyle(color: Color(0xFF9AA5B4))),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: IncidentType.values.map((t) => DropdownMenuItem<IncidentType>(
                                  value: t,
                                  child: Text(t.displayName),
                                )).toList(),
                                onChanged: (value) {
                                  field.didChange(value);
                                  _type = value;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // AVALIAÇÃO
                          _buildLabel('Avaliação (1-5)'),
                          TestableFormField<int>(
                            key: const Key('incident-rating-field'),
                            getValue: () => _rating as int,
                            internalSetValue: (state, value) {
                              state.didChange(value);
                              _rating = value;
                            },
                            validator: (v) => (v == null || v < 1 || v > 5)
                                ? 'Preencha a avaliação'
                                : null,
                            onSaved: (v) => _rating = v,
                            builder: (field) => InputDecorator(
                              decoration: _fieldDecoration(errorText: field.errorText),
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Ex: 3',
                                  hintStyle: TextStyle(color: Color(0xFF9AA5B4)),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final parsed = int.tryParse(value);
                                  field.didChange(parsed);
                                  _rating = parsed;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // DATA E HORA
                          _buildLabel('Data e hora'),
                          TestableFormField<DateTime>(
                            key: const Key('incident-datetime-field'),
                            getValue: () => _dateTime as DateTime,
                            internalSetValue: (state, value) {
                              state.didChange(value);
                              _dateTime = value;
                            },
                            validator: (value) {
                              if (value == null) return 'Preencha a data e hora';
                              final now = DateTime.now();
                              if (value.isAfter(now)) return 'A data não pode ser no futuro';
                              final threeYearsAgo = DateTime(now.year - 3, now.month, now.day);
                              if (value.isBefore(threeYearsAgo)) return 'A data não pode ser há mais de 3 anos';
                              return null;
                            },
                            onSaved: (v) => _dateTime = v,
                            builder: (field) => InputDecorator(
                              decoration: _fieldDecoration(errorText: field.errorText),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'dd/MM/yyyy HH:mm',
                                  hintStyle: TextStyle(color: Color(0xFF9AA5B4)),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  try {
                                    final parsed = DateFormat('dd/MM/yyyy HH:mm').parseStrict(value.trim());
                                    field.didChange(parsed);
                                    _dateTime = parsed;
                                  } catch (_) {
                                    field.didChange(null);
                                    _dateTime = null;
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // NOTAS
                          _buildLabel('Notas (opcional)'),
                          TestableFormField<String>(
                            key: const Key('incident-notes-field'),
                            getValue: () => _notes ?? '',
                            internalSetValue: (state, value) {
                              state.didChange(value);
                              _notes = value;
                            },
                            onSaved: (v) => _notes = v,
                            builder: (field) => InputDecorator(
                              decoration: _fieldDecoration(errorText: field.errorText),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Descrição do incidente...',
                                  hintStyle: TextStyle(color: Color(0xFF9AA5B4)),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                maxLines: 2,
                                onChanged: (value) {
                                  field.didChange(value);
                                  _notes = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('incident-form-submit-button'),
                        onPressed: () async => await _submitForm(repository),
                        icon: const Icon(Icons.send),
                        label: const Text('Submeter', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E7529),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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