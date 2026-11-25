import 'package:filesaverplus_example/main.dart';
import 'package:filesaverplus_example/src/app_services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('filesaverplus');
  final calls = <MethodCall>[];

  Future<void> pumpApp(WidgetTester tester) async {
    // A tall surface so every tile and result is built without scrolling.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const FileSaverPlusExampleApp());
    await tester.pumpAndSettle();
  }

  Future<void> openPage(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  List<String> lastSavedNames() {
    final save = calls.lastWhere((c) => c.method == 'saveMultipleFiles');
    final args = save.arguments as Map<Object?, Object?>;
    return (args['fileNameList']! as List<Object?>).cast<String>();
  }

  setUp(() {
    calls.clear();
    saveHistory.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'getPlatformVersion':
              return 'Test OS 1.0';
            case 'getBatteryPercentage':
              return 87;
            case 'saveMultipleFiles':
              final args = call.arguments as Map<Object?, Object?>;
              final names = (args['fileNameList']! as List<Object?>)
                  .cast<String>();
              return names.map((n) => '/downloads/$n').toList();
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('home shows status and every feature', (tester) async {
    await pumpApp(tester);

    expect(find.text('FileSaverPlus'), findsOneWidget);
    expect(find.text('Test OS 1.0'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
    expect(find.text('No permissions required'), findsOneWidget);
    for (final title in [
      'Single file',
      'Multiple files',
      'Custom file',
      'History',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('single file page saves the selected sample', (tester) async {
    await pumpApp(tester);
    await openPage(tester, 'Single file');

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save plugin_info.json'));
    await tester.pumpAndSettle();

    expect(lastSavedNames(), ['plugin_info.json']);
    expect(find.text('/downloads/plugin_info.json'), findsOneWidget);
  });

  testWidgets('multiple files page de-duplicates repeated files', (
    tester,
  ) async {
    await pumpApp(tester);
    await openPage(tester, 'Multiple files');

    await tester.tap(find.text('Save each file twice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save 6 files'));
    await tester.pumpAndSettle();

    expect(lastSavedNames(), [
      'hello.txt',
      'demo.html',
      'plugin_info.json',
      'hello_2.txt',
      'demo_2.html',
      'plugin_info_2.json',
    ]);
  });

  testWidgets('custom file page reports empty content as an error', (
    tester,
  ) async {
    await pumpApp(tester);
    await openPage(tester, 'Custom file');

    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text('Save file'));
    await tester.pumpAndSettle();

    expect(find.text('ArgumentError: Data is empty.'), findsOneWidget);
    expect(calls.where((c) => c.method == 'saveMultipleFiles'), isEmpty);
  });

  testWidgets('history lists saves from other pages', (tester) async {
    await pumpApp(tester);
    await openPage(tester, 'Single file');
    await tester.tap(find.text('Save hello.txt'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1 saves, 1 succeeded'), findsOneWidget);
    await openPage(tester, 'History');
    expect(find.text('/downloads/hello.txt'), findsOneWidget);
  });
}
