import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  RealtimeDatabaseService({FirebaseDatabase? database}) : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference ref(String path) => _database.ref(path);

  Stream<DatabaseEvent> onValue(String path) => ref(path).onValue;

  Stream<DatabaseEvent> onChildAdded(String path) => ref(path).onChildAdded;

  Stream<DatabaseEvent> onChildChanged(String path) => ref(path).onChildChanged;

  Stream<DatabaseEvent> onChildRemoved(String path) => ref(path).onChildRemoved;

  Future<DataSnapshot> get(String path) => ref(path).get();

  Future<void> set(String path, Object? value) => ref(path).set(value);

  Future<void> update(String path, Map<String, Object?> values) => ref(path).update(values);

  DatabaseReference push(String path) => ref(path).push();
}
