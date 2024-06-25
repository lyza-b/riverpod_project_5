import 'package:flutter/material.dart';
import 'package:riverpod_project_5/main.dart';

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createOrUpdatePerson(
  BuildContext context, [
  Person? existingPerson,
]
) {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? "";
  ageController.text = age?.toString() ?? "";

  return showDialog<Person?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create a person"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Enter name here...",
                ),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: "Enter age here...",
                ),
                onChanged: (value) => age = int.tryParse(value),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (name != null && age != null) {
                  if (existingPerson != null) {
                    // There is an existing person
                    final newPerson = existingPerson.updated(
                      name,
                      age,
                    );
                    Navigator.of(context).pop(newPerson);
                  } else {
                    // No existing person. A new one is created
                      Navigator.of(context).pop(
                        Person(
                          name: name!,
                          age: age!
                        )
                      );
                    }
                } else {
                  // No name, or age, or both
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            )
          ],
        );
      });
}
