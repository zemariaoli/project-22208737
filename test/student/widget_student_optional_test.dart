import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:testable_form_field/testable_form_field.dart';
import 'test_helpers.dart';

void main() {
  runWidgetTests();
}

void runWidgetTests() {

  // ─── VALIDAÇÕES DE DATA ───────────────────────────────────────────────────

  testWidgets('Incidentes - Validacao rejeita data no futuro', (WidgetTester tester) async {
    final dependencies = await tester.pumpAppWithDependencies();
    final local = dependencies.localDataSource;

    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().add(Duration(days: 1)));

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('A data não pode ser no futuro'), findsOneWidget,
        reason: "Deveria apresentar erro quando a data é no futuro");
    expect(local.stations.first.reports.isEmpty, true,
        reason: "Com data no futuro, não deveria ser inserido nenhum incidente");
  });

  testWidgets('Incidentes - Validacao rejeita data ha mais de 3 anos', (WidgetTester tester) async {
    final dependencies = await tester.pumpAppWithDependencies();
    final local = dependencies.localDataSource;

    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 365 * 4)));

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('A data não pode ser há mais de 3 anos'), findsOneWidget,
        reason: "Deveria apresentar erro quando a data é há mais de 3 anos");
    expect(local.stations.first.reports.isEmpty, true,
        reason: "Com data há mais de 3 anos, não deveria ser inserido nenhum incidente");
  });

  testWidgets('Incidentes - Validacao aceita data no passado dentro do limite', (WidgetTester tester) async {
    final dependencies = await tester.pumpAppWithDependencies();
    final local = dependencies.localDataSource;

    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 30)));

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(find.textContaining('A data não pode'), findsNothing,
        reason: "Não deveria apresentar erro para data dentro do limite de 3 anos");
    expect(local.stations.first.reports.isNotEmpty, true,
        reason: "Com data válida, o incidente deveria ser inserido");
  });

  testWidgets('Incidentes - Formulario limpo apos submissao', (WidgetTester tester) async {
    final dependencies = await tester.pumpAppWithDependencies();
    final local = dependencies.localDataSource;

    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));
    final notesField = tester.widget<TestableFormField<String>>(find.byKey(Key('incident-notes-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 1)));
    notesField.setValue('Teste');

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(local.stations.first.reports.isNotEmpty, true,
        reason: "Após submissão, deveria existir pelo menos um incidente na estação");
  });

  // ─── INCIDENTES OFFLINE ───────────────────────────────────────────────────

  testWidgets('Offline - Incidente submetido offline é guardado localmente', (WidgetTester tester) async {
    final stations = [
      Station(
        id: 'st1',
        name: 'Station 1',
        latitude: 38.7369,
        longitude: -9.1427,
        lineName: 'Verde',
      ),
    ];

    final dependencies = await tester.pumpAppWithDependencies(
      localStations: stations,
      isOnline: false,
    );
    final local = dependencies.localDataSource;

    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));
    final notesField = tester.widget<TestableFormField<String>>(find.byKey(Key('incident-notes-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().subtract(const Duration(days: 1)));
    notesField.setValue('Elevador avariado em modo offline');

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(local.stations.first.reports.isNotEmpty, true,
        reason: 'O incidente deveria ter sido guardado localmente em modo offline');
    expect(local.stations.first.reports.first.notes, 'Elevador avariado em modo offline',
        reason: 'As notas do incidente deveriam estar corretas após submissão offline');
    expect(local.stations.first.reports.first.type, IncidentType.Elevator,
        reason: 'O tipo do incidente deveria estar correto após submissão offline');
    expect(local.stations.first.reports.first.rate, 3,
        reason: 'A avaliação do incidente deveria estar correta após submissão offline');
  });

  testWidgets('Offline - Incidente submetido offline aparece no detalhe da estacao', (WidgetTester tester) async {
    final stations = [
      Station(
        id: 'st1',
        name: 'Station 1',
        latitude: 38.7369,
        longitude: -9.1427,
        lineName: 'Verde',
      ),
    ];

    final dependencies = await tester.pumpAppWithDependencies(
      localStations: stations,
      isOnline: false,
    );
    final local = dependencies.localDataSource;

    // Submete o incidente
    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));
    final notesField = tester.widget<TestableFormField<String>>(find.byKey(Key('incident-notes-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(4);
    dateTimeField.setValue(DateTime.now().subtract(const Duration(days: 1)));
    notesField.setValue('Incidente offline visível no detalhe');

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Navega para o detalhe
    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
      of: find.byKey(Key('list-view')),
      matching: find.byType(ListTile),
    );
    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.byKey(Key('detail-screen-incidents-list')), findsOneWidget,
        reason: 'Deveria existir a lista de incidentes no detalhe');
    expect(find.text('Incidente offline visível no detalhe'), findsAtLeastNWidgets(1),
        reason: 'O incidente submetido offline deveria aparecer no detalhe da estação');
  });

  testWidgets('Offline - Incidente pre-existente é visivel no detalhe', (WidgetTester tester) async {
    final existingReport = IncidentReport(
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: IncidentType.Turnstile,
      rate: 4,
      notes: 'Torniquete bloqueado pre-existente',
    );

    final stations = [
      Station(
        id: 'st1',
        name: 'Station 1',
        latitude: 38.7369,
        longitude: -9.1427,
        lineName: 'Verde',
        reports: [existingReport],
      ),
      Station(
        id: 'st2',
        name: 'Station 2',
        latitude: 43.7128,
        longitude: -71.0060,
        lineName: 'Castanha',
      ),
    ];

    await tester.pumpAppWithDependencies(localStations: stations, isOnline: false);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
      of: find.byKey(Key('list-view')),
      matching: find.byType(ListTile),
    );
    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.byKey(Key('detail-screen-incidents-list')), findsOneWidget,
        reason: 'Deveria existir a lista de incidentes no detalhe');
    expect(find.text('Torniquete bloqueado pre-existente'), findsAtLeastNWidgets(1),
        reason: 'O incidente pré-existente deveria ser visível no detalhe em modo offline');

    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(existingReport.timestamp);
    expect(find.text(formattedDate), findsAtLeastNWidgets(1),
        reason: 'A data do incidente pré-existente deveria ser visível');
  });

  testWidgets('Offline - Dois incidentes submetidos ficam ambos guardados', (WidgetTester tester) async {
    final stations = [
      Station(id: 'st1', name: 'Station 1', latitude: 38.7369, longitude: -9.1427, lineName: 'Verde'),
      Station(id: 'st2', name: 'Station 2', latitude: 43.7128, longitude: -71.0060, lineName: 'Castanha'),
    ];

    final dependencies = await tester.pumpAppWithDependencies(
      localStations: stations,
      isOnline: false,
    );
    final local = dependencies.localDataSource;

    // Submete primeiro incidente
    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    TestableFormField<Station> stationField = tester.widget(find.byKey(Key('incident-station-selection-field')));
    TestableFormField<IncidentType> typeField = tester.widget(find.byKey(Key('incident-type-selection-field')));
    TestableFormField<int> ratingField = tester.widget(find.byKey(Key('incident-rating-field')));
    TestableFormField<DateTime> dateTimeField = tester.widget(find.byKey(Key('incident-datetime-field')));
    TestableFormField<String> notesField = tester.widget(find.byKey(Key('incident-notes-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(2);
    dateTimeField.setValue(DateTime.now().subtract(const Duration(days: 2)));
    notesField.setValue('Primeiro incidente');

    Finder submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Submete segundo incidente
    stationField = tester.widget(find.byKey(Key('incident-station-selection-field')));
    typeField = tester.widget(find.byKey(Key('incident-type-selection-field')));
    ratingField = tester.widget(find.byKey(Key('incident-rating-field')));
    dateTimeField = tester.widget(find.byKey(Key('incident-datetime-field')));
    notesField = tester.widget(find.byKey(Key('incident-notes-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Turnstile);
    ratingField.setValue(5);
    dateTimeField.setValue(DateTime.now().subtract(const Duration(days: 1)));
    notesField.setValue('Segundo incidente');

    submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(local.stations.first.reports.length, 2,
        reason: 'Deveriam existir 2 incidentes guardados após duas submissões offline');
    expect(local.stations.first.reports.any((r) => r.notes == 'Primeiro incidente'), true,
        reason: 'O primeiro incidente deveria estar guardado');
    expect(local.stations.first.reports.any((r) => r.notes == 'Segundo incidente'), true,
        reason: 'O segundo incidente deveria estar guardado');
  });

  // ─── DASHBOARD OFFLINE ───────────────────────────────────────────────────

  testWidgets('Dashboard - Apresenta numero de estacoes', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);
    expect(find.text('2'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria apresentar o número total de estações (2)");
  });

  testWidgets('Dashboard - Apresenta estacao com mais incidentes', (WidgetTester tester) async {
    final stations = [
      Station(
        id: "st1",
        name: 'Station 1',
        latitude: 40.7128,
        longitude: -74.0060,
        lineName: 'Rosa',
        reports: [
          IncidentReport(timestamp: DateTime(2024, 6, 2, 14, 30), type: IncidentType.Elevator, rate: 3),
          IncidentReport(timestamp: DateTime(2024, 6, 3, 10, 0), type: IncidentType.Turnstile, rate: 4),
        ],
      ),
      Station(
        id: "st2",
        name: 'Station 2',
        latitude: 43.7128,
        longitude: -71.0060,
        lineName: 'Castanha',
        reports: [
          IncidentReport(timestamp: DateTime(2024, 6, 4, 9, 0), type: IncidentType.Elevator, rate: 2),
        ],
      ),
    ];

    await tester.pumpAppWithDependencies(localStations: stations, remoteStations: stations);

    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);
    expect(find.textContaining('Station 1'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria destacar 'Station 1' como a estação com mais incidentes");
  });

  testWidgets('Dashboard - Offline - Apresenta dados das estacoes locais', (WidgetTester tester) async {
    final stations = [
      Station(
        id: "st1",
        name: 'Station 1',
        latitude: 40.7128,
        longitude: -74.0060,
        lineName: 'Rosa',
        reports: [
          IncidentReport(timestamp: DateTime(2024, 6, 2, 14, 30), type: IncidentType.Elevator, rate: 3),
        ],
      ),
      Station(
        id: "st2",
        name: 'Station 2',
        latitude: 43.7128,
        longitude: -71.0060,
        lineName: 'Castanha',
      ),
    ];

    await tester.pumpAppWithDependencies(localStations: stations, isOnline: false);

    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);
    expect(find.text('2'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria apresentar 2 estações em modo offline");
    expect(find.text('1'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria apresentar 1 incidente em modo offline");
  });

  testWidgets('Dashboard - Offline - Incidente submetido actualiza contadores', (WidgetTester tester) async {
    final stations = [
      Station(id: 'st1', name: 'Station 1', latitude: 38.7369, longitude: -9.1427, lineName: 'Verde'),
      Station(id: 'st2', name: 'Station 2', latitude: 43.7128, longitude: -71.0060, lineName: 'Castanha'),
    ];

    final dependencies = await tester.pumpAppWithDependencies(
      localStations: stations,
      isOnline: false,
    );
    final local = dependencies.localDataSource;

    // Verifica 0 incidentes no dashboard inicialmente
    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);
    expect(find.text('0'), findsAtLeastNWidgets(1),
        reason: 'O dashboard deveria mostrar 0 incidentes inicialmente');

    // Submete incidente
    await tester.tap(find.byKey(Key('incidents-report-bottom-bar-item')));
    await tester.pumpAndSettle();

    final stationField = tester.widget<TestableFormField<Station>>(find.byKey(Key('incident-station-selection-field')));
    final typeField = tester.widget<TestableFormField<IncidentType>>(find.byKey(Key('incident-type-selection-field')));
    final ratingField = tester.widget<TestableFormField<int>>(find.byKey(Key('incident-rating-field')));
    final dateTimeField = tester.widget<TestableFormField<DateTime>>(find.byKey(Key('incident-datetime-field')));

    stationField.setValue(local.stations.first);
    typeField.setValue(IncidentType.Elevator);
    ratingField.setValue(3);
    dateTimeField.setValue(DateTime.now().subtract(const Duration(days: 1)));

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    // Volta ao dashboard e verifica que o contador foi atualizado
    await tester.tap(find.byKey(Key('dashboard-bottom-bar-item')));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsAtLeastNWidgets(1),
        reason: 'O dashboard deveria mostrar 1 incidente após submissão');
  });

  // ─── LISTA OFFLINE ────────────────────────────────────────────────────────

  testWidgets('Lista estacoes - Offline - Apresenta estacoes guardadas localmente', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(isOnline: false);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('list-view')), findsOneWidget,
        reason: "Em modo offline com estações locais, deveria existir um ListView com a key 'list-view'");
    expect(find.text('Station 1'), findsOneWidget,
        reason: "Deveria apresentar 'Station 1' a partir dos dados locais em modo offline");
    expect(find.text('Station 2'), findsOneWidget,
        reason: "Deveria apresentar 'Station 2' a partir dos dados locais em modo offline");
  });

  testWidgets('Lista estacoes - Offline - Navega para detalhe', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(isOnline: false);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile));

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.byKey(Key('detail-screen')), findsOneWidget,
        reason: "Em modo offline, o ecrã de detalhe deveria aparecer ao clicar numa estação");
    expect(find.text('Station 1'), findsAtLeastNWidgets(1),
        reason: "O ecrã de detalhe deveria apresentar o nome da estação em modo offline");
  });

  // ─── LISTA ONLINE ─────────────────────────────────────────────────────────

  testWidgets('Lista estacoes - Online - Apresenta estacoes remotas', (WidgetTester tester) async {
    final remoteStations = [
      Station(id: "st1", name: 'Remote Station 1', latitude: 40.7128, longitude: -74.0060, lineName: 'Azul'),
    ];

    await tester.pumpAppWithDependencies(
      remoteStations: remoteStations,
      localStations: [],
      isOnline: true,
    );

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    expect(find.text('Remote Station 1'), findsOneWidget,
        reason: "Em modo online, deveria apresentar as estações remotas");
  });

  // ─── LISTA COM PESQUISA ───────────────────────────────────────────────────

  testWidgets('Lista estacoes - Filtro por nome', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Station 1');
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile));

    expect(listTilesFinder, findsOneWidget,
        reason: "Após filtrar por 'Station 1', deveria existir apenas 1 resultado");
    expect(find.text('Station 1'), findsAtLeastNWidgets(1));
    expect(find.text('Station 2'), findsNothing);
  });

  testWidgets('Lista estacoes - Filtro por linha', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Rosa');
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile));

    expect(listTilesFinder, findsOneWidget,
        reason: "Após filtrar por 'Rosa', deveria existir apenas 1 resultado");
    expect(find.text('Station 1'), findsOneWidget);
  });

  testWidgets('Lista estacoes - Filtro sem resultados', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'XYZ inexistente');
    await tester.pumpAndSettle();

    expect(find.byKey(Key('list-view')), findsNothing,
        reason: "Sem resultados, o ListView não deveria aparecer");
    expect(find.text('Sem estações disponíveis.'), findsOneWidget);
  });

  testWidgets('Lista estacoes - Offline - Filtro funciona com dados locais', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(isOnline: false);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Station 2');
    await tester.pumpAndSettle();

    final listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile));

    expect(listTilesFinder, findsOneWidget,
        reason: "O filtro deveria funcionar em modo offline");
    expect(find.text('Station 2'), findsOneWidget,
        reason: "Deveria apresentar apenas 'Station 2' após filtrar em modo offline");
    expect(find.text('Station 1'), findsNothing,
        reason: "Não deveria apresentar 'Station 1' após filtrar por 'Station 2'");
  });

  // ─── MAPA ─────────────────────────────────────────────────────────────────

  testWidgets('Mapa - Offline - Apresenta estacoes locais no mapa', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(isOnline: false);

    await tester.tap(find.byKey(Key('map-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder mapFinder = find.byType(GoogleMap);
    expect(mapFinder, findsOneWidget,
        reason: "Em modo offline, deveria existir um GoogleMap");

    final GoogleMap googleMap = tester.widget<GoogleMap>(mapFinder);
    expect(googleMap.markers.length, 2,
        reason: "Em modo offline, o mapa deve conter 2 marcadores das estações locais");
  });

  testWidgets('Mapa - Offline - Sem estacoes locais nao mostra markers', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(
      localStations: [],
      isOnline: false,
    );

    await tester.tap(find.byKey(Key('map-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder mapFinder = find.byType(GoogleMap);
    expect(mapFinder, findsOneWidget,
        reason: "Deveria existir um GoogleMap mesmo sem estações");

    final GoogleMap googleMap = tester.widget<GoogleMap>(mapFinder);
    expect(googleMap.markers.length, 0,
        reason: "Sem estações locais em modo offline, o mapa não deveria ter markers");
  });
}