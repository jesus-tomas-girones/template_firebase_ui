class Paciente{

  int id;
  String nombre;

  Paciente(this.id,this.nombre);


  static List<Paciente> mockListaPacientes(){
    return [
      Paciente(1, "Paciente 1"),
      Paciente(2, "Paciente 2"),
      Paciente(3, "Paciente 3"),
      Paciente(4, "Paciente 4"),
      Paciente(5, "Paciente 5"),
      Paciente(6, "Paciente 6"),
    ];
  }

  ///
  /// Funcion que devuelve el paciente con el ese id asociado
  ///
  static Paciente? findPacienteById(List<Paciente>? pacientes, id){
    if(pacientes != null){
      for(Paciente p in pacientes){
        if(p.id == id){
          return p;
        }
      }
    }
    return null;
  }

}