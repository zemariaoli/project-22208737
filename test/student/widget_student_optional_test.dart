import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testable_form_field/testable_form_field.dart';
import 'test_helpers.dart';

void main() {
  runWidgetTests();
}

void runWidgetTests() {

  // ─── INCIDENT SCREEN ───────────────────────────────────────────────────────────

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
    dateTimeField.setValue(DateTime.now().add(Duration(days: 1))); // futuro

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
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 365 * 4))); // mais de 3 anos

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
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 30))); // dentro do limite

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(find.textContaining('A data não pode'), findsNothing,
        reason: "Não deveria apresentar erro para data dentro do limite de 3 anos");

    expect(local.stations.first.reports.isNotEmpty, true,
        reason: "Com data válida, o incidente deveria ser inserido");
  });


  testWidgets('Incidentes - Validacao nao submete com rating invalido', (WidgetTester tester) async {
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
    ratingField.setValue(0); // inválido — fora do intervalo 1-5
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 1)));

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Preencha a avaliação'), findsOneWidget,
        reason: "Deveria apresentar erro de validação para rating inválido (0)");

    expect(local.stations.first.reports.isEmpty, true,
        reason: "Com rating inválido, não deveria ser inserido nenhum incidente");
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
    // usa data recente válida em vez de data fixa no passado longínquo
    dateTimeField.setValue(DateTime.now().subtract(Duration(days: 1)));
    notesField.setValue('Teste');

    final submitFinder = find.byKey(Key('incident-form-submit-button'));
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder);
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(local.stations.first.reports.isNotEmpty, true,
        reason: "Após submissão, deveria existir pelo menos um incidente na estação");
  });


  // ─── DASHBOARD ───────────────────────────────────────────────────────────

  testWidgets('Dashboard - Apresenta numero de estacoes', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    final Finder dashboardFinder = find.byKey(Key('dashboard-screen'));
    expect(dashboardFinder, findsOneWidget);

    expect(find.text('2'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria apresentar o número total de estações (2)");
  });

  testWidgets('Dashboard - Apresenta zero incidentes inicialmente', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);
    expect(find.text('0'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria apresentar 0 incidentes inicialmente");
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
          IncidentReport(
            timestamp: DateTime(2024, 6, 2, 14, 30),
            type: IncidentType.Elevator,
            rate: 3,
          ),
          IncidentReport(
            timestamp: DateTime(2024, 6, 3, 10, 0),
            type: IncidentType.Turnstile,
            rate: 4,
          ),
        ],
      ),
      Station(
        id: "st2",
        name: 'Station 2',
        latitude: 43.7128,
        longitude: -71.0060,
        lineName: 'Castanha',
        reports: [
          IncidentReport(
            timestamp: DateTime(2024, 6, 4, 9, 0),
            type: IncidentType.Elevator,
            rate: 2,
          ),
        ],
      ),
    ];

    await tester.pumpAppWithDependencies(localStations: stations, remoteStations: stations);

    expect(find.byKey(Key('dashboard-screen')), findsOneWidget);

    expect(find.textContaining('Station 1'), findsAtLeastNWidgets(1),
        reason: "O dashboard deveria destacar 'Station 1' como a estação com mais incidentes");
  });

  // ─── LISTA OFFLINE ────────────────────────────────────────────────────────

  testWidgets('Lista estacoes - Offline - Apresenta estacoes guardadas localmente', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies(isOnline: false);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget,
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

    final Finder listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile)
    );

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
      Station(
        id: "st1",
        name: 'Remote Station 1',
        latitude: 40.7128,
        longitude: -74.0060,
        lineName: 'Azul',
      ),
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

    final Finder textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget,
        reason: "Deveria existir um TextField para pesquisa na lista");

    await tester.enterText(textFieldFinder, 'Station 1');
    await tester.pumpAndSettle();

    final Finder listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile)
    );

    expect(listTilesFinder, findsOneWidget,
        reason: "Após filtrar por 'Station 1', deveria existir apenas 1 resultado");

    expect(find.text('Station 1'), findsAtLeastNWidgets(1),
        reason: "Deveria apresentar 'Station 1' após filtrar");
    expect(find.text('Station 2'), findsNothing,
        reason: "Não deveria apresentar 'Station 2' após filtrar por 'Station 1'");
  });

  testWidgets('Lista estacoes - Filtro por linha', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, 'Rosa');
    await tester.pumpAndSettle();

    final Finder listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile)
    );

    expect(listTilesFinder, findsOneWidget,
        reason: "Após filtrar por 'Rosa', deveria existir apenas 1 resultado");

    expect(find.text('Station 1'), findsOneWidget,
        reason: "Deveria apresentar 'Station 1' após filtrar por linha 'Rosa'");
  });

  testWidgets('Lista estacoes - Filtro sem resultados', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, 'XYZ inexistente');
    await tester.pumpAndSettle();

    expect(find.byKey(Key('list-view')), findsNothing,
        reason: "Sem resultados, o ListView não deveria aparecer");

    expect(find.text('Sem estações disponíveis.'), findsOneWidget,
        reason: "Deveria apresentar mensagem 'Sem estações disponíveis.' quando não há resultados");
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

  // ─── DETALHE ──────────────────────────────────────────────────────────────

  testWidgets('Detalhe - Sem incidentes mostra lista vazia', (WidgetTester tester) async {
    await tester.pumpAppWithDependencies();

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile)
    );

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    final Finder incidentsListFinder = find.byKey(Key('detail-screen-incidents-list'));
    expect(incidentsListFinder, findsOneWidget,
        reason: "Deveria existir sempre uma ListView com a key 'detail-screen-incidents-list'");

    expect(find.byType(ListTile), findsNothing,
        reason: "Sem incidentes, a lista deveria estar vazia");
  });

  testWidgets('Detalhe - Apresenta multiplos incidentes', (WidgetTester tester) async {
    final stations = [
      Station(
        id: "st1",
        name: 'Station 1',
        latitude: 40.7128,
        longitude: -74.0060,
        lineName: 'Rosa',
        reports: [
          IncidentReport(
            timestamp: DateTime(2024, 6, 2, 14, 30),
            type: IncidentType.Elevator,
            rate: 1,
            notes: "Elevador avariado",
          ),
          IncidentReport(
            timestamp: DateTime(2024, 6, 3, 10, 0),
            type: IncidentType.Turnstile,
            rate: 5,
            notes: "Torniquete bloqueado",
          ),
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

    await tester.pumpAppWithDependencies(localStations: stations);

    await tester.tap(find.byKey(Key('list-bottom-bar-item')));
    await tester.pumpAndSettle();

    final Finder listTilesFinder = find.descendant(
        of: find.byKey(Key('list-view')),
        matching: find.byType(ListTile)
    );

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('02/06/2024 14:30'), findsAtLeastNWidgets(1),
        reason: "Deveria apresentar a data do primeiro incidente");

    expect(find.text('03/06/2024 10:00'), findsAtLeastNWidgets(1),
        reason: "Deveria apresentar a data do segundo incidente");

    expect(find.text('Elevador avariado'), findsAtLeastNWidgets(1),
        reason: "Deveria apresentar as notas do primeiro incidente");

    expect(find.text('Torniquete bloqueado'), findsAtLeastNWidgets(1),
        reason: "Deveria apresentar as notas do segundo incidente");
  });


}
