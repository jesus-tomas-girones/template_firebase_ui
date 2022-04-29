import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/informe.dart';
import 'api.dart';

class InformeFirebase implements Api<Informe> {
  final FirebaseFirestore firestore;
  final String userId;
  final CollectionReference<Map<String, dynamic>> ref;

  InformeFirebase(this.firestore, this.userId)
      : ref = firestore.collection('users/$userId/informes');

  @override
  Future<List<Informe>> list() async {
    var querySnapshot = await ref.get();
    var informes = querySnapshot.docs
        .map((doc) => Informe.fromJson(doc.data())..id = doc.id)
        .toList();
    return informes;
  }

  @override
  Future<Informe> update(Informe category, String id) async {
    var document = ref.doc(id);
    await document.update(category.toJson());
    var snapshot = await document.get();
    return Informe.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Future<Informe> insert(Informe informe) async {
    var document = await ref.add(informe.toJson());
    return await get(document.id);
  }

  @override
  Future<Informe> get(String id) async {
    var document = ref.doc(id);
    var snapshot = await document.get();
    return Informe.fromJson(snapshot.data()!)..id = snapshot.id;
  }

  @override
  Stream<List<Informe>> subscribe() {
    var snapshots = ref.snapshots();
    var result = snapshots.map<List<Informe>>((querySnapshot) {
      return querySnapshot.docs.map<Informe>((snapshot) {
        return Informe.fromJson(snapshot.data())..id = snapshot.id;
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
