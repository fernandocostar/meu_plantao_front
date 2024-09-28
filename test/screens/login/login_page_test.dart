// test/login_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_plantao_front/screens/auth/login/login_page.dart';
import 'package:meu_plantao_front/screens/calendar/calendar_page.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/register/register_page.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('LoginPage Tests', () {
    testWidgets('Successful login navigates to home page', (WidgetTester tester) async {
      // Create a mock HTTP client
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/login')) {
          return http.Response(jsonEncode({
            'name': 'Test User',
            'email': 'test@example.com',
            'token': 'dummyToken',
          }), 200);
        }
        return http.Response('Not Found', 404);
      });

      // Build the LoginPage with the mock HTTP client
      await tester.pumpWidget(
        MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('pt', 'BR'), // Set the locale to Brazilian Portuguese
      supportedLocales: [
        Locale('pt', 'BR'), // Brazilian Portuguese
      ],
      title: 'Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(httpClient: mockClient),
    ),
      );

      // Interact with the UI
      await tester.enterText(find.byType(AuthTextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(AuthTextField).at(1), 'password123');

      // Tap the login button
      await tester.tap(find.byType(AuthSubmitButton));
      await tester.pumpAndSettle();
      
      // Verify navigation to CalendarPage
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('Login failure shows error dialog', (WidgetTester tester) async {
      // Create a mock HTTP client that returns an error
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('/login')) {
          return http.Response(jsonEncode({'error': 'Invalid credentials'}), 401);
        }
        return http.Response('Not Found', 404);
      });

      // Build the LoginPage with the mock HTTP client
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(httpClient: mockClient),
        ),
      );

      // Interact with the UI
      await tester.enterText(find.byType(AuthTextField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(AuthTextField).at(1), 'wrongpassword');

      // Tap the login button
      await tester.tap(find.byType(AuthSubmitButton));
      await tester.pumpAndSettle();

      // Verify that error dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);

      // Verify that CalendarPage was not navigated to
      expect(find.byType(CalendarPage), findsNothing);
    });

    testWidgets('Displays all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Check for logo
      expect(find.byType(Image), findsOneWidget);

      // Check for email and password fields
      expect(find.byType(AuthTextField), findsNWidgets(2));

      // Check for login button
      expect(find.byType(AuthSubmitButton), findsOneWidget);

      // Check for 'Forgot Password' text
      expect(find.text('Esqueceu sua senha?'), findsOneWidget);

      // Check for 'Register' text
      expect(find.text('Não possui uma conta?'), findsOneWidget);
      expect(find.text('Cadastre-se já!'), findsOneWidget);
    });

    testWidgets('Navigates to RegisterPage when "Cadastre-se já!" is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Tap on the "Cadastre-se já!" text
      await tester.tap(find.text('Cadastre-se já!'));
      await tester.pumpAndSettle();

      // Verify that the RegisterPage is pushed
      expect(find.byType(RegisterPage), findsOneWidget);
    });
  });
}
