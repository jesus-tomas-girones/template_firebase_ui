part of 'informe_edit.dart';

///
/// Parte de clase [_InformeEditPageState]
///
extension SectionTabGastos on _InformeEditPageState{


  // ======================================================================================
  // Tab 3 gastos
  // ======================================================================================
  Widget _TabGastos() =>
      Center(child: Text("Gastos"),);

  // Floating action button = añadir informe
  Widget _buildFab(){
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){

        }
    );
  }

}