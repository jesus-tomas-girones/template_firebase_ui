import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/informe.dart';
import '../model/paciente.dart';
import 'api.dart';
import 'informe_firebase.dart';
import 'paciente_firebase.dart';

class FirebaseDashboardApi implements DashboardApi {
  @override
  final Api<Informe> informes;

  @override
  final Api<Paciente> pacientes;

  FirebaseDashboardApi(FirebaseFirestore firestore, String userId)
      : informes = InformeFirebase(firestore, userId),
        pacientes = PacienteFirebase(firestore, userId) ;
}