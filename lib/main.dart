import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_project_5/dialogue.dart';

import 'package:uuid/uuid.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

@immutable
class Person {
  final String name;
  final int age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  Person updated([
    String? name,
    int? age,
  ]) =>
      Person(name: name ?? this.name, age: age ?? this.age, uuid: uuid);

// This is the functon that returns the display name
  String get displayName => "$name ($age years old)";

// Because we're placing these in an iterable (list), we have to make sure that they're equattable, so we know which person is which by comparing them.
  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => "Person(name : $name, age : $age, uuid : $uuid)";
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  int get count => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    final previousPerson = _people[index];
    if (previousPerson.name != updatedPerson.name ||
        previousPerson.age != updatedPerson.age) {
      _people[index] =
          previousPerson.updated(updatedPerson.name, updatedPerson.age);
    }
    notifyListeners();
  }
}

final peopleProvider = ChangeNotifierProvider((_) => DataModel());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: Consumer(builder: (context, ref, child) {
        final dataModel = ref.watch(peopleProvider);
        return ListView.builder(
          itemBuilder: (context, index) {
            final person = dataModel.people[index];
            return ListTile(
              title: GestureDetector(
                onTap: () async {
                  final updatedPerson = await createOrUpdatePerson(context, person);
                  if (updatedPerson != null) {
                    dataModel.update(updatedPerson);
                  }
                },
                child: Text(person.displayName)),
            );
          },
          itemCount: dataModel.count,
        );
      }),
      floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        final person = await createOrUpdatePerson(context);
        if (person != null) {
          final dataModel = ref.read(peopleProvider);
          dataModel.add(person);
        }
      },
      ),
    );
  }
}
