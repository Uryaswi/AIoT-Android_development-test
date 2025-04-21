import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "SQlLITE Basics", home: Homescreen());
  }
}

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String sqlCreate =
      "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, gender TEXT)";

  late Database _database;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectGender = "Male";
  List<Map<String, dynamic>> _fetcheUusers = [];
  int? userID;

  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), "test.db");

    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(sqlCreate);
    });
  }

  Future<void> _insertData() async {
    String name = _nameController.text;
    String ageText = _ageController.text;
    if (name.isNotEmpty && ageText.isNotEmpty && userID == null) {
      int age = int.parse(ageText);
      String gender = _selectGender;

      await _database.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO users(name, age, gender) VALUES(?,?,?)',
            [name, age, gender]);
      });
      _nameController.clear();
      _ageController.clear();
      _fetchData();
    } else if (name.isNotEmpty && ageText.isNotEmpty && userID != null) {
      await _updateData();
      _nameController.clear();
      _ageController.clear();
    }
  }

  Future<void> _updateData() async {
    String _name = _nameController.text;
    String _ageText = _ageController.text;

    if (_name.isNotEmpty && _ageText.isNotEmpty && userID != null) {
      int _age = int.parse(_ageText);
      String gender = _selectGender;
      await _database.rawUpdate(
          'UPDATE users SET name = ?, age = ?, gender = ? WHERE id = ?',
          [_name, _age, gender, userID]);

      setState(() {
        userID = null;
      });
      _fetchData();
    }
  }

  Future<void> _deleteData(int delUserID) async {
    await _database.rawDelete('DELETE FROM users WHERE id = ?', [delUserID]);
    _fetchData();
  }

  Future<void> _fetchData({String? gender}) async {
    List<Map<String, dynamic>> allUsers;
    if (gender != null) {
      allUsers = await _database
          .rawQuery("SELECT * FROM users WHERE gender = ?", [gender]);
    } else {
      allUsers = await _database.rawQuery("SELECT * FROM users");
    }
    setState(() {
      _fetcheUusers = allUsers;
    });
  }

  Future<void> _updatedData(Map<String, dynamic> user) async {
    setState(() {
      _nameController.text = user["name"];
      _ageController.text = user["age"].toString();
      _selectGender = user["gender"];
      userID = user["id"];
    });
  }



  @override
  void initState() {
    _initDatabase();
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
          SizedBox(height: 100),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Enter Name"),
          ),
          TextField(
            controller: _ageController,
            decoration: InputDecoration(hintText: "Enter Age"),
          ),
          DropdownButton<String>(
            value: _selectGender,
            isExpanded: true,
            items: ["Male", "Female"]
                .map((gender) =>
                DropdownMenuItem(value: gender, child: Text(gender)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectGender = value!;
              });
            },
          ),
          ElevatedButton(
              onPressed: _insertData,
              child: Text(userID == null ? "Add Users" : "Update User")),
          ElevatedButton(onPressed: _fetchData, child: Text("All Users")),
          ElevatedButton(
              onPressed: () => _fetchData(gender: "Male"),
              child: Text("Male Users")),
          ElevatedButton(
              onPressed: () => _fetchData(gender: "Female"),
              child: Text("Female Users")),
          Expanded(
            child: ListView.builder(
              itemCount: _fetcheUusers.length,
              itemBuilder: (context, index) {
                final user = _fetcheUusers[index];
                return ListTile(
                  onTap: () => _updatedData(user),
                  title: Text(user["name"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${user["age"]}, ${user["gender"]}"),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _updatedData(user),
                            child: Text("Update"),
                          ),
                          TextButton(
                            onPressed: () => _deleteData(user["id"]),
                            child: Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}