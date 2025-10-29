import 'dart:io';
import 'dart:convert';

class Colors {
  static const String reset = '\x1B[0m';
  static const String pink = '\x1B[38;5;213m';
  static const String softPink = '\x1B[38;5;218m';
  static const String bold = '\x1B[1m';
  static const String green = '\x1B[38;5;120m';
  static const String gray = '\x1B[38;5;246m';
  static const String white = '\x1B[97m';
}

class Task {
  String title;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TodoListManager {
  List<Task> tasks = [];
  final String filePath = 'tasks.json';

  Future<void> loadTasks() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        tasks = jsonData.map((item) => Task.fromJson(item)).toList();
      }
    } catch (e) {
      print('${Colors.gray}No previous tasks found. Starting fresh!${Colors.reset}');
    }
  }

  Future<void> saveTasks() async {
    try {
      final file = File(filePath);
      final jsonData = tasks.map((task) => task.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('${Colors.gray}Error saving tasks: $e${Colors.reset}');
    }
  }

  void addTask(String title) {
    tasks.add(Task(title: title));
    saveTasks();
    print('${Colors.green}✓ Task added successfully!${Colors.reset}');
  }

  void displayTasks() {
    if (tasks.isEmpty) {
      print('\n${Colors.softPink}📝 Your todo list is empty!${Colors.reset}');
      print('${Colors.gray}Add some tasks to get started.${Colors.reset}\n');
      return;
    }

    print('\n${Colors.pink}${Colors.bold}╔════════════════════════════════════════╗${Colors.reset}');
    print('${Colors.pink}${Colors.bold}║          💕 MY TODO LIST 💕           ║${Colors.reset}');
    print('${Colors.pink}${Colors.bold}╚════════════════════════════════════════╝${Colors.reset}\n');

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final checkbox = task.isCompleted ? '${Colors.green}☑${Colors.reset}' : '${Colors.softPink}☐${Colors.reset}';
      final textStyle = task.isCompleted ? Colors.gray : Colors.white;
      final strikethrough = task.isCompleted ? '(completed)' : '';
      
      print('${Colors.softPink}${i + 1}.${Colors.reset} $checkbox $textStyle${task.title}${Colors.reset} ${Colors.gray}$strikethrough${Colors.reset}');
    }
    print('');
  }

  void completeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks[index].isCompleted = true;
      saveTasks();
      print('${Colors.green}✓ Task marked as completed!${Colors.reset}');
    } else {
      print('${Colors.gray}Invalid task number!${Colors.reset}');
    }
  }

  void deleteTask(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
      saveTasks();
      print('${Colors.green}✓ Task deleted successfully!${Colors.reset}');
    } else {
      print('${Colors.gray}Invalid task number!${Colors.reset}');
    }
  }

  void displayStats() {
    final total = tasks.length;
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = total - completed;

    print('\n${Colors.pink}${Colors.bold}📊 STATISTICS${Colors.reset}');
    print('${Colors.softPink}Total Tasks:${Colors.reset} $total');
    print('${Colors.green}Completed:${Colors.reset} $completed');
    print('${Colors.white}Pending:${Colors.reset} $pending\n');
  }
}

void displayMenu() {
  print('${Colors.pink}${Colors.bold}╔════════════════════════════════════════╗${Colors.reset}');
  print('${Colors.pink}${Colors.bold}║              MAIN MENU                 ║${Colors.reset}');
  print('${Colors.pink}${Colors.bold}╚════════════════════════════════════════╝${Colors.reset}');
  print('${Colors.softPink}1.${Colors.reset} Add new task');
  print('${Colors.softPink}2.${Colors.reset} View all tasks');
  print('${Colors.softPink}3.${Colors.reset} Complete a task');
  print('${Colors.softPink}4.${Colors.reset} Delete a task');
  print('${Colors.softPink}5.${Colors.reset} View statistics');
  print('${Colors.softPink}6.${Colors.reset} Exit');
  print('${Colors.pink}${Colors.bold}════════════════════════════════════════${Colors.reset}');
}

void main() async {
  final todoManager = TodoListManager();
  
  await todoManager.loadTasks();

  print('\n${Colors.pink}${Colors.bold}╔════════════════════════════════════════╗${Colors.reset}');
  print('${Colors.pink}${Colors.bold}║   💕 WELCOME TO TODO LIST APP 💕      ║${Colors.reset}');
  print('${Colors.pink}${Colors.bold}╚════════════════════════════════════════╝${Colors.reset}\n');

  while (true) {
    displayMenu();
    stdout.write('\n${Colors.softPink}Choose an option (1-6):${Colors.reset} ');
    
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('\n${Colors.softPink}Enter task title:${Colors.reset} ');
        final title = stdin.readLineSync();
        if (title != null && title.isNotEmpty) {
          todoManager.addTask(title);
        } else {
          print('${Colors.gray}Task title cannot be empty!${Colors.reset}');
        }
        break;

      case '2':
        todoManager.displayTasks();
        break;

      case '3':
        todoManager.displayTasks();
        if (todoManager.tasks.isNotEmpty) {
          stdout.write('${Colors.softPink}Enter task number to complete:${Colors.reset} ');
          final input = stdin.readLineSync();
          final index = int.tryParse(input ?? '');
          if (index != null) {
            todoManager.completeTask(index - 1);
          } else {
            print('${Colors.gray}Invalid input!${Colors.reset}');
          }
        }
        break;

      case '4':
        todoManager.displayTasks();
        if (todoManager.tasks.isNotEmpty) {
          stdout.write('${Colors.softPink}Enter task number to delete:${Colors.reset} ');
          final input = stdin.readLineSync();
          final index = int.tryParse(input ?? '');
          if (index != null) {
            todoManager.deleteTask(index - 1);
          } else {
            print('${Colors.gray}Invalid input!${Colors.reset}');
          }
        }
        break;

      case '5':
        todoManager.displayStats();
        break;

      case '6':
        print('\n${Colors.pink}${Colors.bold}💕 Eak Dah Kelar Yaa Bund.. 💕${Colors.reset}');
        print('${Colors.softPink}Sehat-sehat bund..!${Colors.reset}\n');
        exit(0);

      default:
        print('${Colors.gray}Invalid option! Please choose 1-6.${Colors.reset}');
    }

    print('\n${Colors.gray}Press Enter to continue...${Colors.reset}');
    stdin.readLineSync();
    print('\n' * 2);
  }
}