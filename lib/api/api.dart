import '../model/informe.dart';
import '../model/paciente.dart';

/// Manipulamos una lista de objetos de la clase <C> con persistencia.
abstract class Api<C> {
  Future<List<C>> list();
  Stream<List<C>> subscribe();
  Future<C> update(C object, String id);
  Future<C> insert(C object);
  Future<C> get(String id);
  Future<void> delete(String id);
}

/// Manipulates app data,
abstract class DashboardApi {
  Api<Informe> get informes;
  Api<Paciente> get pacientes;
}
