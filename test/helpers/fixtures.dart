import 'dart:convert';
import 'dart:io';

// Les tests tournent depuis la racine du projet.
String readFixtureText(String name) =>
    File('test/fixtures/$name').readAsStringSync();

Object? readFixture(String name) => jsonDecode(readFixtureText(name));

Map<String, dynamic> readJsonObjectFixture(String name) =>
    readFixture(name)! as Map<String, dynamic>;

List<dynamic> readJsonListFixture(String name) =>
    readFixture(name)! as List<dynamic>;
