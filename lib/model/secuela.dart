import 'package:firebase_ui/utils/enum_helpers.dart';
import 'package:json_annotation/json_annotation.dart';

import '../widgets/editor_lista_objetos.dart';

/// Una secula tiene una descrpción y un listado de tipos de secuela
/// Un tipo de secuela tiene - especialidad, secuela, nivel y puntos asignados por el médico
/// La siguiente tabla recoge las especialidades, secuelas, niveles y rango de puntos que se pueden asignar

const SECUELAS = {
  // TODO ver los [1,100]
  // los rangos indican [minimo, maximo]
  "1A - NEUROLOGÍA":{
    //Nervios Craneales
    "Estado vegetativo permanente - Nervios Craneales":{
      "sin graduación":[100,100]
    },
    "Tetraplejia - Nervios Craneales":{
      "Por encima o igual a C4 (Ninguna movilidad. Sujeto sometido a respirador automático)": [100,100],
      "C5-C6 (Movilidad cintura escapular)": [96,98],
      "C7-C8 (Puede utilizar miembros superiores. Posible sedestación)": [93,95],
    },
    "Tetraparesia - Nervios Craneales":{
      "Leve (Balance muscular Oxford 4)":[100,100],
      "Moderada (Balance muscular Oxford 3)":[96,98],
      "Grave (Balance muscular Oxford 0 a 2)":[93,95],
    },
    "Hemiplejia (según dominancia) - Nervios Craneales":{
    "Según compromiso funcional, motor, sensitivo, nivel de marcha, manipulación, compromiso sexual, de esfínteres y dominancia.":[71,80]
  },
    "Hemiparesia (según dominancia) - Nervios Craneales":{
      "Leve (Balance muscular Oxford 4)": [15,20],
      "Moderada (Balance muscular Oxford 3)": [21,40],
      "Grave (Balance muscular Oxford 0 a 2)": [41,60]
    },
    "Paraplejia - Nervios Craneales":{
      "Paraplejia D1": [90,90],
      "Paraplejia D2-D5": [85,87],
      "Paraplejia D6-D10": [80,84],
      "Paraplejia D11-L2": [75,79]
    },
    "Síndrome Medular Transverso L3-L5 - Nervios Craneales":{
      "La marcha es posible con aparatos pero siempre teniendo el recurso de la silla de ruedas":[75,75]
    },
    "Síndrome de Hemisección Medular (Brown Sequard) - Nervios Craneales":{
      "Leve": [20,30],
      "Moderado": [31,50],
      "Grave": [51,70]
    },
    "Paraparesia de miembros superiores o inferiores - Nervios Craneales":{
      "Leve (Balance muscular Oxford 4)": [20,40],
      "Moderada (Balance muscular Oxford 3)": [41,60],
      "Grave (Balance muscular Oxford 0 a 2)": [61,70]
    },
    "Paresia de algún grupo muscular - Nervios Craneales":{
      "(Comprende aquellos casos de afectación de un grupo muscular clínicamente identificable y no contemplado en el capítulo relativo a sistema nervioso periférico).": [5,15]
    },
    "Síndrome de cola de caballo completo - Nervios Craneales":{
      "(incluye trastornos motores, sensitivos y de esfínteres)": [75,75]
    },
    "Síndrome de cola de caballo incompleto (incluye trastornos motores, sensitivos y de esfínteres) - Nervios Craneales":{
      "Alto (L1 y L2": [45,65],
      "Medio (de L3 a L5)": [25,44],
      "Bajo (de S1 a S5)": [15,24]
    },
    "Monoplejia de un miembro inferior o superior - Nervios Craneales":{
      "De miembro superior (según dominancia)": [55,60],
      "De miembro inferior": [50,50]
    },
    "Monoparesia de miembros superiores o inferiores - Nervios Craneales":{
      "Leve (Balance muscular Oxford 4)": [10,19],
      "Moderada (Balance muscular Oxford 3)": [20,29],
      "Grave (Balance muscular Oxford 0 a 2)": [30,40]
    },
    "Síndromes extrapiramidales/Síndrome Cerebeloso/Ataxia - Nervios Craneales":{
      "Leve (Posibilidad de la marcha sin ortesis)": [15,30],
      "Moderado (Posibilidad de la marcha con ortesis)": [35,55],
      "Grave (Imposibilidad de la marcha)": [70,85]
    },
    "Apraxia postraumática - Nervios Craneales":{
      "Como manifestación aislada no contemplada en otros síntomas": [10,35]
    },
    "Disartria postraumática - Nervios Craneales":{
      "Como manifestación aislada no contemplada en otros síndromes": [10,20]
    },
    "Dolores por desaferentación - Nervios Craneales":{
      "(Cuando concurre con amputaciones o en lesiones de nervios periféricos) (Son dolores excepcionales que no forman parte del cuadro clínico habitual de estos lesionados y necesitan ser acreditados con informe médico y tratamiento específico en Unidades especiales, una vez descartadas otras posibles causas objetivables de dolor)": [5,20]
    },
    "Afectación Motor ocular común - Nervios Craneales":{
      "Parálisis (diplopía, midriasis paralítica que obliga a la oclusión, ptosis)": [25,25],
      "Paresia (valorar según grado y tipo de diplopia)": [1,100]
    },
    "Afectación Motor ocular interno o patético - Nervios Craneales":{
      "Parálisis (según grado y tipo de diplopia)": [1,100],
      "Paresia (valorar según grado y tipo de diplopia) ": [1,100]
    },
    "Afectación Nervio trigémino - Nervios Craneales":{
      "Afectación de 1ª Rama: Hipo/anestesia de rama oftálmica.": [5,10],
      "Afectación de 2ª Rama: Hipo/anestesia de rama maxilar.": [5,10],
      "Afectación de 3ª Rama: Hipo/anestesia de rama dento-mandibular": [5,10],
      "Neuralgia intermitente – Dolores intermitentes": [5,15],
    "Neuralgia continua – Dolores continuos": [25,30],
    "Paralisis/Paresia del temporal o del masetero": [1,15]
    },
    "Afectación Motor ocular externo - Nervios Craneales":{
      "Parálisis (valorar según grado y tipo de diplopia)": [1,100],
      "Paresia (valorar según grado y tipo de diplopia).": [1,100]
    },
    "Afectación Nervio facial - Tronco - Nervios Craneales":{
      " Parálisis (en caso de existir obligación de oclusión permanente de globo ocular por lagoftalmos, añadir 5 puntos)": [20,20],
      "Paresia": [5,15]
    },
    "Afectación Nervio facial - Rama frontorbitaria - Nervios Craneales":{
      "Parálisis (en caso de existir obligación de oclusión permanente de globo ocular por lagoftalmos, añadir 5 puntos)": [15,15],
      "Paresia": [5,11]
    },
    "Afectación Nervio facial - Rama mandibular - Nervios Craneales":{
      "Parálisis": [15,15],
      "Paresia": [5,11],
      "Disgeusia de dos tercios anteriores de la lengua": [2,5],
      "Neuralgia": [1,8]
    },
    "Afectación Nervio glosofaríngeo: (Según trastorno funcional) - Nervios Craneales":{
      "Lesión completa bilateral": [25,25],
      "Lesión completa unilateral": [6,10],
      "Lesión incompleta - Paresia": [1,5],
      "Neuralgia ": [10,15]
    },
    "Nervio espinal":{
      "Parálisis bilateral": [20,20],
      "Parálisis unilateral (según repercusión funcional)": [10,20],
      "Paresia": [1,7]
    },
    "Nervio hipogloso":{
      "Parálisis bilateral":[20,20],
      "Parálisis unilateral":[8,12],
    "Paresia":[1,7]
    },
    // - Miembro superior
    "Monoplejia por lesión plexo braquial completa - Miembro superior":{
      "(raíces C5-D1)":[55,60]
    },
    "Plejia periférica por lesión plexo braquial - Miembro superior":{
      "(tipo Klumpke – Dejerine) (raíces C7-C8-D1)":[45,50]
    },
    "Plejia por lesión plexo braquial - Miembro superior":{
      "(tipo ERB – Duchene) (raíces C5-C6)":[30,40]
    },
    "Secuelas por lesión incompleta del plexo braquial - Miembro superior":{
      "(valorar monoparesia)":[1,100]
    },
    "Nervio Sub-Escapular - Miembro superior":{
      "Lesión completa – Parálisis":[6,10],
      "Lesión incompleta – Paresia":[2,5]
    },
    "Nervio Circunflejo - Miembro superior":{
      "Lesión completa - Parálisis":[12,15],
      "Lesión incompleta - Paresia":[2,9]
    },
    "Nervio Músculo Cutáneo - Miembro superior":{
      "Lesión completa - Parálisis":[10,12],
      "Lesión incompleta - Paresia":[2,9]
    },
    "Nervio Mediano - Lesión completa valorar según afectación de músculos flexores de carpo y dedos - Miembro superior":{
      "Parálisis a nivel del brazo":[25,30],
      "Parálisis a nivel del antebrazo":[20,24],
      "Parálisis a nivel de la muñeca":[15,19]
    },
    "Nervio Mediano - Lesión incompleta - Miembro superior":{
      "A nivel del brazo":[21,24],
      "A nivel del antebrazo":[11,20],
      "A nivel de la muñeca":[5,10]
    },
    "Nervio Radial - Lesión completa - Miembro superior":{
      "Parálisis a nivel del brazo sin/con afectación del tríceps":[20,25],
      "Parálisis a nivel del antebrazo con afectación de extensores de carpo y dedos":[15,19]
    },
    "Nervio Radial - Lesión incompleta - Miembro superior":{
      "A nivel del brazo sin/con afectación del tríceps":[15,19],
      "A nivel del antebrazo con afectación de extensores de carpo y dedos":[10,14],
      "A nivel de la muñeca sin afectación de extensores o a nivel de muñeca (solo sensitiva)":[2,4]
    },
    "Nervio Cubital - Lesión completa - Miembro superior":{
      "Parálisis a nivel del brazo":[20,25],
      "Parálisis a nivel del antebrazo. Con afectación de sus flexores subsidiarios":[15,19],
      "Parálisis a nivel del antebrazo. Sin afectación de sus flexores subsidiarios o en muñeca":[10,14]
    },
    "Nervio Cubital - Lesión incompleta - Miembro superior":{
      "A nivel del brazo":[15,18],
      "A nivel del antebrazo":[10,14],
      "A nivel de la muñeca":[2,9]
    },
    "Nervio Torácico largo - Miembro superior":{
      "Lesión completa - Parálisis":[4,5]
    },
    "Parestesias de partes acras - Miembro superior":{
      "":[1,4]
    },
    // - Miembro inferior
    "Nervio Ciático (Nervio Ciático Común) - Lesión Completa - Parálisis - Miembro inferior":{
      "Lesión proximal completa con afectación de flexores de la corva":[40,40],
      "Lesión distal completa sin afectación de flexores de la corva":[30,30]
    },
    "Nervio Ciático (Nervio Ciático Común) - Lesión incompleta - Paresia - Miembro inferior":{
      "Lesión Proximal - Grave":[31,39],
      "Lesión Proximal - Moderada":[16,30],
      "Lesión Proximal - Leve":[5,15],
      "Lesión Distal - Grave":[21,29],
      "Lesión Distal - Moderada":[11,20],
      "Lesión Distal - Leve":[2,10]
    },
    "Nervio Ciático (Nervio Ciático Común) - Neuralgia - Miembro inferior":{
      "Neuralgia":[10,30]
    },
    "Nervio Femoral (Nervio Crural) - Miembro inferior":{
      "Lesión completa – Parálisis":[25,25],
      "Lesión incompleta – Paresia":[6,12],
      "Neuralgia":[5,15]
    },
    "Nervio Obturador - Miembro inferior":{
      "Lesión completa – Parálisis":[4,4],
      "Lesión incompleta – Paresia":[2,3]
    },
    "Nervio Glúteo superior - Miembro inferior":{
      "Lesión completa – Parálisis":[4,4],
      "Lesión incompleta – Paresia":[1,3]
    },
    "Nervio Glúteo inferior - Miembro inferior":{
      "Lesión completa – Parálisis":[6,6],
      "Lesión incompleta – Paresia":[1,5]
    },
    "Nervio Peroneo común (Nervio Ciático Poplíteo Externo) - Miembro inferior":{
      "Lesión completa – Parálisis":[18,18],
      "Lesión incompleta – Paresia":[5,17]
    },
    "Nervio Peroneo superficial (Nervio Músculocutáneo) - Miembro inferior":{
      "Lesión completa – Parálisis":[5,5],
      "Lesión incompleta – Paresia":[1,3]
    },
    "Nervio Peroneo profundo (Nervio Tibial Anterior) - Miembro inferior":{
      "Lesión completa – Parálisis":[12,12],
      "Lesión incompleta – Paresia":[2,11]
    },
    "Nervio Tibial (Nervio Ciático Poplíteo Interno) - Lesión completa - Parálisis - Miembro inferior":{
      "Lesión proximal (afecta grupo muscular posterior de la pierna completo)":[22,22],
      "Lesión distal (afecta musculatura intrínseca del pie)":[12,12]
    },
    "Nervio Tibial (Nervio Ciático Poplíteo Interno) - Lesión incompleta - Paresia - Miembro inferior":{
      "Lesión Proximal - Grave":[16,21],
      "Lesión Proximal - Moderada":[8,15],
      "Lesión Proximal - Leve":[3,7],
      "Lesión Distal - Grave":[7,10],
      "Lesión Distal - Moderada":[4,6],
      "Lesión Distal - Leve":[1,3]
    },
    "Parestesias de partes acras - Miembro inferior":{
      "":[1,3]
    },
    // ----- 
    "Síndrome frontal/trastorno orgánico de la personalidad / alteración de funciones cerebrales superiores integradas.":{
      "Leve":[13,20],
      "Moderado":[21,50],
      "Grave":[51,75],
      "Muy Grave":[76,90]
    },
    "Síndrome Postconmocional / Trastorno cognoscitivo":{
      "Leve":[2,12]
    },
    "Trastornos del lenguaje - Trastornos de la comunicación":{
      "Disfasia. Alteraciones en la denominación, en la repetición. Parafasia. Comprensión conservada":[10,24],
      "Afasia motora (Broca)":[25,34],
      "Afasia sensitiva (Wernicke)":[35,50],
      "Afasia grave con jergonofasia, alexia y trastornos de la comprensión":[60,75],
    },
    "Amnesia":{
      "De fijación o anterógrada (incluida en deterioro de las Funciones Cerebrales Superiores Integradas).":[1,100], 
      "De evocación o retrógrada (incluida en el Síndrome Postconmocional) ":[1,100]
    },
    "Epilepsia sin trastorno de la conciencia ":{
      "Epilepsia parcial o focal simple":[5,15]
    },
    "Epilepsia con trastorno de la conciencia - generalizadas y parciales complejas":{
      "Epilepsia bien controlada mediante un tratamiento bien tolerado":[10,15],
      "Epilepsia no controlada completamente, con crisis (hasta tres al año)":[16,34],
      "Epilepsia difícilmente controlada, con crisis (más de tres al año)":[35,54],
      "Epilepsia no controlable, refractaria a tratamiento y objetivable mediante HolterEEG, con crisis casi semanales":[55,79],
      "Epilepsia no controlable, refractaria a tratamiento y objetivable mediante HolterEEG, con crisis casi diarias.":[80,90]
    },
    "Pérdida de sustancia ósea":{
      "Que no requiera craneoplastia":[1,5],
      "Que requiera craneoplastia":[6,15]
    },
    "Fistulas osteodurales":{
      "":[1,10]
    },
    "Sindromes extrapiramidales":{
      "valorar según alteraciones funcionales":[1,100]
    },
    "Derivación ventrículo-peritoneal, ventrículo-vascular (por hidrocefalia postraumática) según alteración funcional":{
      "":[15,25]
    },
    "Material de osteosíntesis cráneo":{
      "":[1,8]
    },
  },
  "1B - Psiquiatría y psicología clínica":{
    "Secuelas derivadas de estrés postraumático":{
      "Leve: Manifestaciones menores de forma esporádica":[1,2],
      "Moderado: Fenómenos de evocación, evitación e hiperactivación frecuentes":[3,5],
      "Grave: Síntomas recurrentes e invasivos de tipo intrusivo. Conductas de evitación sistemática, entrañando un síndrome fóbico severo. Estado de hipervigilancia en relación con los estímulos que recuerden el trauma, pudiendo acompañarse de trastornos depresivos y disociativos. Presencia de ideación suicida":[6,15],
    },
    "Trastornos Permanentes del Humor":{
      "Trastorno depresivo mayor crónico - Leve":[4,10],
      "Trastorno depresivo mayor crónico - Moderado":[11,15],
      "Trastorno depresivo mayor crónico - Grave":[16,25]
    },
    "Trastorno distímico":{
      "":[1,3]
    },
    "Agravación o desestabilización de demencia no traumática (incluye demencia senil)":{
      "":[1,25]
    },
    "Agravación o desestabilización de otros trastornos mentales":{
      "":[1,10]
    }
}

};

const SECUELAS_ALTERNATIVA = { // Los niveles son el índice
  "oftalmologia": {
    "perdida de visión": [
      [2, 6],
      [4, 8],
    ],
    "estravismo": [
      [2, 6],
      [4, 8],
      [6, 10],
    ],
  },
};

List<String> listaEspecialidades() {
  return SECUELAS.keys.toList();
}

List<String> listaSecuela(String especialidad) {
  if(SECUELAS[especialidad]!=null){
    print(SECUELAS[especialidad]!.keys.toList());
    return SECUELAS[especialidad]!.keys.toList();
  }else{
    return [];
  }
}

List<String> listaNiveles(String especialidad, String secuela) {
  if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null){ 
    print(SECUELAS[especialidad]![secuela]!.keys.toList());
    return SECUELAS[especialidad]![secuela]!.keys.toList();
  }else{
    return [];
  }
}

List rangoPuntos(String especialidad, String secuela, String nivel) {
  return [4, 6]; //TODO obtener par de valores dinámicamente.
}

@JsonSerializable(explicitToJson: true) // Por tener clase anidada
class Secuela implements ClonableVaciable{
  String? descripcion;
  List<SecuelaTipo> secuelas;

  

  Secuela({ this.descripcion, List<SecuelaTipo>? secuelas }) : secuelas = secuelas ?? [];


  clone() => Secuela(
    descripcion: descripcion,
    secuelas: secuelas
  );

  vaciar() {
    descripcion = null;
    secuelas = [];
  }

  factory Secuela.fromJson(Map<String, dynamic> json) {
    try {
      return Secuela(
          descripcion: json['descripcion'],
          secuelas: json['secuelas'] != null ? (json['secuelas'] as List).map((secuela) => SecuelaTipo.fromJson(secuela)).toList() : <SecuelaTipo>[],
      );
    } catch (e) {
      print("Error en Secuelas.fromJson");
      print(e);
      return Secuela();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'descripcion': descripcion,
      'secuelas': secuelas.map((e) => e.toJson()).toList()
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }
}


@JsonSerializable()
class SecuelaTipo implements ClonableVaciable{
  String? especialidad;  //Especialidad médica
  String? secuela;       //Descripción de la secuela
  String? nivel;         //Cada tipo de secuela tienen varios niveles
  int puntos;           //puntos asignados por el périto. Para cada indice,nivel hay un rango posible.

  static List<String> listaEspecialidades() {
    return SECUELAS.keys.toList();
  }

  static List<String> listaSecuela(String especialidad) {
    if(SECUELAS[especialidad]!=null){
      return SECUELAS[especialidad]!.keys.toList();
    }else{
      return [];
    }
  }

  static List<String> listaNiveles(String especialidad, String secuela) {
    if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null){
      return SECUELAS[especialidad]![secuela]!.keys.toList();
    }else{
      return [];
    }
  }

  static List<int> rangoPuntos(String? especialidad, String? secuela, String? nivel) {
    if(SECUELAS[especialidad]!=null && SECUELAS[especialidad]![secuela]!=null && SECUELAS[especialidad]![secuela]![nivel]!=null){
      return SECUELAS[especialidad]![secuela]![nivel]!.toList();
    }else{
      return [];
    }
  }

  SecuelaTipo({ this.especialidad, this.secuela, this.nivel, this.puntos = 0 });

  factory SecuelaTipo.fromJson(Map<String, dynamic> json) {
    try {
      return SecuelaTipo(
        especialidad: json['especialidad'],
        secuela: json['secuela'],
        nivel: json['nivel'],
        puntos: json['puntos'],
      );
    } catch (e) {
      print("Error en SecuelasTipo.fromJson");
      print(e);
      return SecuelaTipo();
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'especialidad': especialidad,
      'secuela': secuela,
      'nivel': nivel,
      'puntos': puntos,
    };
    map.removeWhere((key, value) => value == null);
    map.removeWhere((key, value) => value == "null");
    return map;
  }

   @override
  clone() => SecuelaTipo(
    especialidad: especialidad,
    nivel: nivel,
    puntos: puntos,
    secuela: secuela
  );

  @override
  vaciar() {
    especialidad = null;
    nivel = null;
    puntos = 0;
    secuela = null;
  }
}
