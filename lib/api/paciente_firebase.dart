import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/paciente.dart';
import 'api.dart';

class PacienteFirebase implements Api<Paciente> {
  final FirebaseFirestore firestore;
  final String userId;
  final CollectionReference<Map<String, dynamic>> ref;

  PacienteFirebase(this.firestore, this.userId)
      : ref = firestore.collection('users/$userId/pacientes');

  @override
  Future<List<Paciente>> list() async {
    var querySnapshot = await ref.get();
    var pacientes = querySnapshot.docs
        .map((doc) => Paciente.fromJson(doc.data())..id = doc.id)
        .toList();
    return pacientes;
  }

  @override
  Future<Paciente> update(Paciente category, String id) async {
    var document = ref.doc(id);
    await document.update(category.toJson());
    var snapshot = await document.get();
    return Paciente.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Paciente> insert(Paciente paciente) async {
    var document = await ref.add(paciente.toJson());
    return await get(document.id);
  }

  @override
  Future<Paciente> get(String id) async {
    var document = ref.doc(id);
    var snapshot = await document.get();
    return Paciente.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Stream<List<Paciente>> subscribe() {
    var snapshots = ref.snapshots();
    var result = snapshots.map<List<Paciente>>((querySnapshot) {
      return querySnapshot.docs.map<Paciente>((snapshot) {
        return Paciente.fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });
    return result;
  }

  @override
  Future<void> delete(String id) async {
    var document = ref.doc(id);
    return document.delete();
  }
}


/*abstract class Data {
  String? id;
  static Data fromJson(Map<String, dynamic> json);
  static Map<String, dynamic> toJson(Data data);
}

abstract class ApiFirebase<Data> implements Api<Data> {
  final FirebaseFirestore firestore;
  final String userId;
  final CollectionReference<Map<String, dynamic>> ref;

  ApiFirebase(this.firestore, this.userId)
      : ref = firestore.collection('users/$userId/pacientes');

  @override
  Future<List<Data>> list() async {
    var querySnapshot = await ref.get();

    List<Data> list = querySnapshot.docs
        .map((doc) => fromJson(doc.data())..id = doc.id)
        .toList();
    return list;
  }

  @override
  Future<Data> update(Data object, String id) async {
    var document = ref.doc(id);
    await document.update(Data.toJson(object));
    var snapshot = await document.get();
    return Data.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Data> insert(Data object) async {
    var document = await ref.add(object.toJson());
    return await get(document.id);
  }

  @override
  Future<Data> get(String id) async {
    var document = ref.doc(id);
    var snapshot = await document.get();
    return Data.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Stream<List<Data>> subscribe() {
    var snapshots = ref.snapshots();
    var result = snapshots.map<List<Data>>((querySnapshot) {
      return querySnapshot.docs.map<Data>((snapshot) {
        return fromJson(snapshot.data())..id = snapshot.id;
      }).toList();
    });
    return result;
  }

  @override
  Future<void> delete(String id) async {
    var document = ref.doc(id);
    return document.delete();
  }
}*/

/*// Manipulates [Paciente] data.
abstract class PacienteApi {
  Future<List<Paciente>> list();
  Stream<List<Paciente>> subscribe();
  Future<Paciente> update(Paciente paciente, String id);
  Future<Paciente> insert(Paciente paciente);
  Future<Paciente> get(String id);
}*/


