import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yacht_master/widgets/error_boundary.dart';
import 'package:yacht_master/widgets/optimized_yacht_list.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/utils/logger.dart';

/// Component verification tests to ensure all changes work correctly
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Widget Component Tests', () {
    testWidgets('ErrorBoundary renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Container(
              key: const Key('test_child'),
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_child')), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('ErrorBoundary shows error widget on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorMessage: 'Test Error',
            child: Builder(
              builder: (context) {
                throw Exception('Test exception');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error UI instead of crashing
      expect(find.text('Test Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('OptimizedYachtList renders empty list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedYachtList(
              yachts: [],
              onYachtTap: (yacht) {},
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('OptimizedYachtList renders yacht cards', (WidgetTester tester) async {
      final testYachts = [
        YachtsModel(
          id: '1',
          name: 'Test Yacht 1',
          price: 500,
          images: ['https://example.com/image1.jpg'],
          location: YachtLocation(address: 'Test Location 1'),
        ),
        YachtsModel(
          id: '2',
          name: 'Test Yacht 2',
          price: 750,
          images: ['https://example.com/image2.jpg'],
          location: YachtLocation(address: 'Test Location 2'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedYachtList(
              yachts: testYachts,
              onYachtTap: (yacht) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Yacht 1'), findsOneWidget);
      expect(find.text('Test Yacht 2'), findsOneWidget);
      expect(find.text('\$500/day'), findsOneWidget);
      expect(find.text('\$750/day'), findsOneWidget);
    });

    testWidgets('OptimizedYachtGrid renders correctly', (WidgetTester tester) async {
      final testYachts = [
        YachtsModel(
          id: '1',
          name: 'Grid Test Yacht',
          price: 600,
          images: ['https://example.com/grid1.jpg'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedYachtGrid(
              yachts: testYachts,
              onYachtTap: (yacht) {},
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Grid Test Yacht'), findsOneWidget);
    });
  });

  group('Logger Tests', () {
    test('AppLogger initializes without error', () {
      expect(() => AppLogger.init(), returnsNormally);
    });

    test('AppLogger methods work correctly', () {
      AppLogger.init();

      expect(() => AppLogger.debug('Debug message'), returnsNormally);
      expect(() => AppLogger.info('Info message'), returnsNormally);
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
      expect(() => AppLogger.error('Error message'), returnsNormally);
    });
  });

  group('Model Tests', () {
    test('YachtsModel can be created and serialized', () {
      final yacht = YachtsModel(
        id: 'test_id',
        name: 'Test Yacht',
        price: 1000,
        description: 'A beautiful test yacht',
        images: ['image1.jpg', 'image2.jpg'],
      );

      expect(yacht.id, 'test_id');
      expect(yacht.name, 'Test Yacht');
      expect(yacht.price, 1000);
      expect(yacht.images?.length, 2);

      final json = yacht.toJson();
      expect(json['id'], 'test_id');
      expect(json['name'], 'Test Yacht');
      expect(json['price'], 1000);

      final fromJson = YachtsModel.fromJson(json);
      expect(fromJson.id, yacht.id);
      expect(fromJson.name, yacht.name);
      expect(fromJson.price, yacht.price);
    });
  });
}