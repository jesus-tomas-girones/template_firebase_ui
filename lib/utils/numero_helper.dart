
import 'package:intl/intl.dart';


///
/// formatea un numero entero a un string con formato XXX.XXX.XXX
///
String formatoMoneda(int n){
    var formatter = NumberFormat('#,###');
    return formatter.format(n).replaceAll(',', '.');
}