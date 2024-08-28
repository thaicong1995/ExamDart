import 'dart:convert';
import 'dart:io';

class Course {
  String courseName;
  List<int> grades;

  Course({required this.courseName, required this.grades});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['subject'],
      grades: List<int>.from(json['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject-name': courseName,
      'score': grades,
    };
  }
}

class Student {
  String id;
  String name;
  List<Course> courses;

  Student({required this.id, required this.name, required this.courses});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      courses:
          (json['subject'] as List).map((i) => Course.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': courses.map((c) => c.toJson()).toList(),
    };
  }
}

Future<List<Student>> loadStudents() async {
  final file = File(r'C:\Users\thaic\my_dart_project\bin\Files\Student.json');

  if (!await file.exists()) {
    return [];
  }

  try {
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return [];
    }
    final List<dynamic> jsonData = jsonDecode(contents);
    return jsonData
        .map((json) => Student.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Fail!! $e');
  }
}

void displayStudents(List<Student> students) {
  if (students.isEmpty) {
    print(' Students not found.');
    return;
  }
  for (var student in students) {
    print('ID: ${student.id}');
    print('Name: ${student.name}');
    for (var course in student.courses) {
      print('Subject: ${course.courseName}');
      print('Score: ${course.grades.join(', ')}');
    }
    print('---');
  }
}

void addStudent(List<Student> students, Student newStudent) {
  students.add(newStudent);
  saveStudents(students);
}

void updateStudent(List<Student> students, String id, Student updatedStudent) {
  final index = students.indexWhere((s) => s.id == id);
  if (index != -1) {
    students[index] = updatedStudent;
    saveStudents(students);
  } else {
    print('Student not found');
  }
}

Student? findStudentById(List<Student> students, String id) {
  return students.firstWhere(
    (s) => s.id == id,
    orElse: () => throw Exception("Student not found"),
  );
}

List<Student> findStudentsByName(List<Student> students, String name) {
  return students.where((s) => s.name.contains(name)).toList();
}

Future<void> saveStudents(List<Student> students) async {
  final file = File(r'C:\Users\thaic\my_dart_project\bin\Files\Student.json');
  final jsonData = students.map((s) => s.toJson()).toList();
  await file.writeAsString(jsonEncode(jsonData), mode: FileMode.write);
}

void main() async {
  List<Student> students = await loadStudents();

  while (true) {
    print('Menu:');
    print('1. Get All');
    print('2. Add student');
    print('3. Update student');
    print('4. Find By ID');
    print('5. Fin By Name');
    print('6. Exit');
    stdout.write('Choose option: ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        displayStudents(students);
        break;

      case '2':
        // Add new student
        stdout.write('Enter ID: ');
        String? id = stdin.readLineSync();
        stdout.write('Enter name: ');
        String? name = stdin.readLineSync();
        List<Course> courses = [];
        String? addMoreCourses;
        do {
          stdout.write('Enter subject name: ');
          String? courseName = stdin.readLineSync();
          stdout.write('Enter score : ');
          String? gradesInput = stdin.readLineSync();
          if (courseName != null && gradesInput != null) {
            List<int> grades =
                gradesInput.split(',').map((e) => int.parse(e.trim())).toList();
            courses.add(Course(courseName: courseName, grades: grades));
          }
          stdout.write('Add more ? (y/n): ');
          addMoreCourses = stdin.readLineSync();
        } while (addMoreCourses == 'y');

        if (id != null && name != null) {
          Student newStudent = Student(id: id, name: name, courses: courses);
          addStudent(students, newStudent);
          print('Successfully.');
        }
        break;

      case '3':
        // Update student
        stdout.write('Enter ID : ');
        String? idToUpdate = stdin.readLineSync();
        stdout.write('Enter new name: ');
        String? newName = stdin.readLineSync();
        List<Course> newCourses = [];
        String? addMoreCourses;
        do {
          stdout.write('Enter subject name: ');
          String? courseName = stdin.readLineSync();
          stdout.write('Enter score: ');
          String? gradesInput = stdin.readLineSync();
          if (courseName != null && gradesInput != null) {
            List<int> grades =
                gradesInput.split(',').map((e) => int.parse(e.trim())).toList();
            newCourses.add(Course(courseName: courseName, grades: grades));
          }
          stdout.write('Add more? (y/n): ');
          addMoreCourses = stdin.readLineSync();
        } while (addMoreCourses == 'y');

        if (idToUpdate != null && newName != null) {
          Student updatedStudent =
              Student(id: idToUpdate, name: newName, courses: newCourses);
          updateStudent(students, idToUpdate, updatedStudent);
          print(' Successfully.');
        }
        break;

      case '4':
        // Search by ID
        stdout.write('Enter ID : ');
        String? idToSearch = stdin.readLineSync();
        if (idToSearch != null) {
          Student? studentById = findStudentById(students, idToSearch);
          if (studentById != null) {
            print('------: ${studentById.name}');
            displayStudents([studentById]);
          } else {
            print('Student not found!!');
          }
        }
        break;

      case '5':
        // Search by name
        stdout.write('Enter student name: ');
        String? nameToSearch = stdin.readLineSync();
        if (nameToSearch != null) {
          List<Student> studentsByName =
              findStudentsByName(students, nameToSearch);
          if (studentsByName.isEmpty) {
            print('Student not found!!');
          } else {
            displayStudents(studentsByName);
          }
        }
        break;

      case '6':
        print('Exit !!!.');
        return;

      default:
        print('Choose again!!');
    }
  }
}
