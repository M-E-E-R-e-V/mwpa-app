// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get aboutAllContributors => 'Todos los colaboradores en GitHub';

  @override
  String get aboutAppSource => 'Código fuente de la app';

  @override
  String get aboutConnection => 'Conexión';

  @override
  String get aboutContributors => 'Colaboradores';

  @override
  String get aboutDevelopment => 'Desarrollo de software';

  @override
  String get aboutImprint => 'Aviso legal';

  @override
  String get aboutLegal => 'Información legal';

  @override
  String get aboutLocalData => 'Datos en este dispositivo';

  @override
  String get aboutMapData => 'Datos del mapa';

  @override
  String get aboutMwpaProject => 'Proyecto MWPA';

  @override
  String get aboutNotSynced => 'Aún sin sincronizar';

  @override
  String get aboutPrivacy => 'Política de privacidad';

  @override
  String get aboutProject => 'Proyecto';

  @override
  String get aboutProjectText =>
      'MWPA recoge y analiza datos de la observación de ballenas y delfines. Esta app registra avistamientos y recorridos, también sin conexión, y los sincroniza con un servidor MWPA. Un proyecto de M.E.E.R. e.V.';

  @override
  String get aboutRoleDevelopment => 'Desarrollo de software';

  @override
  String get aboutServer => 'Servidor';

  @override
  String get aboutSightings => 'Avistamientos';

  @override
  String get aboutSupport => 'Soporte';

  @override
  String get aboutSupportText =>
      'Si algo no funciona, comparte el registro de la app con el equipo de MWPA (p. ej. por correo). Contiene los eventos y errores de la app, pero ninguna contraseña.';

  @override
  String get aboutSupportedApi => 'API del servidor compatible';

  @override
  String get aboutUser => 'Usuario';

  @override
  String accuracyMeters(int meters) {
    return 'Precisión: $meters m';
  }

  @override
  String get add => 'Añadir';

  @override
  String get addSighting => 'Avistamiento';

  @override
  String get addSightingHint => 'Formulario completo';

  @override
  String get addSightingTitle => 'Añadir avistamiento';

  @override
  String get addTagHint => 'Añadir etiqueta ...';

  @override
  String get addTortoise => 'Tortuga';

  @override
  String get addTortoiseHint => 'Entrada rápida';

  @override
  String get addTortoiseTitle => 'Añadir avistamiento de tortuga';

  @override
  String addedSnack(String name) {
    return 'Añadido: $name';
  }

  @override
  String get allRequiredFilled =>
      'Todos los campos obligatorios están completos';

  @override
  String animalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animales',
      one: '1 animal',
    );
    return '$_temp0';
  }

  @override
  String apiLoginChanged(String server, String accepted) {
    return 'La API de inicio de sesión ha cambiado (el servidor indica \'$server\', la app acepta $accepted). Actualiza la app, los datos no se perderán.';
  }

  @override
  String apiSyncChanged(String server, String accepted) {
    return 'La API de sincronización ha cambiado (el servidor indica \'$server\', la app acepta $accepted). Actualiza la app, los datos no se perderán.';
  }

  @override
  String get appTagline => 'Mammal watching. Processing. Analysing.';

  @override
  String get atEndOfSighting => 'Al final del avistamiento';

  @override
  String get back => 'Atrás';

  @override
  String get badgeCalves => 'Crías/recién nacidos';

  @override
  String get badgePicture => 'Imagen';

  @override
  String get badgeSubgroups => 'Subgrupos';

  @override
  String batteryLowBanner(int level) {
    return 'Batería baja ($level %): conecta un cargador, el registro del recorrido se detiene si el móvil se apaga.';
  }

  @override
  String get camera => 'Cámara';

  @override
  String get cancel => 'Cancelar';

  @override
  String get checkBeginAfterTourEnd =>
      'El avistamiento empieza después del final de la salida.';

  @override
  String get checkBeginBeforeTourStart =>
      'El avistamiento empieza antes del inicio de la salida.';

  @override
  String checkBeginFarFromTrack(String distance) {
    return 'La posición inicial está a $distance del recorrido registrado a esa hora.';
  }

  @override
  String get checkDateInFuture => 'La fecha está en el futuro.';

  @override
  String get checkEndBeforeBegin => 'El avistamiento termina antes de empezar.';

  @override
  String checkEndFarFromTrack(String distance) {
    return 'La posición final está a $distance del recorrido registrado a esa hora.';
  }

  @override
  String get checkTitle => 'Por favor, revisa';

  @override
  String get checkTourEndBeforeStart =>
      'La salida termina antes de empezar (¿pasada la medianoche?).';

  @override
  String get choiceNo => 'No';

  @override
  String get choiceUnknown => 'Desconocido';

  @override
  String get choiceYes => 'Sí';

  @override
  String get close => 'Cerrar';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get currentTour => 'Salida actual';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteSightingQuestion =>
      '¿Eliminar este avistamiento del dispositivo? Los datos ya sincronizados permanecen en el servidor.';

  @override
  String get deleteSightingTitle => 'Eliminar avistamiento';

  @override
  String get disclosureAccept => 'De acuerdo, aceptar y guardar';

  @override
  String get disclosureHeading => 'Cómo usamos tu ubicación';

  @override
  String get disclosureReject => 'No, gracias y cerrar';

  @override
  String get disclosureText1 =>
      'La app MWPA recoge datos de ubicación para rellenar automáticamente los avistamientos y registrar las rutas, incluso cuando la app está cerrada o no se usa.';

  @override
  String get disclosureText2 =>
      'La app solo puede usarse con la determinación de la posición/ubicación; de lo contrario, los datos registrados no sirven. Los datos solo se envían al portal indicado al iniciar sesión. Para más preguntas puedes contactarnos o ver el código fuente:';

  @override
  String get disclosureTitle => 'Aviso de MWPA';

  @override
  String distanceNm(String distance) {
    return '$distance mn';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get edit => 'Editar';

  @override
  String get editSightingTitle => 'Editar avistamiento';

  @override
  String get error => 'Error';

  @override
  String get fieldBeginPosition => 'Posición inicial';

  @override
  String get fieldBeginTime => 'Avistamiento desde';

  @override
  String get fieldCount => 'Número de animales';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldEndPosition => 'Posición final';

  @override
  String get fieldTourEnd => 'Fin de la salida';

  @override
  String get fieldTourStart => 'Inicio de la salida';

  @override
  String fieldsStillEmpty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos aún vacíos',
      one: '1 campo aún vacío',
    );
    return '$_temp0';
  }

  @override
  String get gallery => 'Galería';

  @override
  String get gpsOff => 'El GPS está apagado: sin posición ni registro de ruta.';

  @override
  String get gpsOffBanner =>
      'GPS apagado: sin posición, la ruta no se registra.';

  @override
  String get gpsOk => 'El GPS funciona, la ruta se registra.';

  @override
  String get gpsSearching =>
      'El GPS funciona, pero no hay posición actual (p. ej. en interiores).';

  @override
  String get gpsStatus => 'Estado del GPS';

  @override
  String get groupDispersed => 'dispersos';

  @override
  String get groupLoose => 'sueltos';

  @override
  String get groupTight => 'compactos';

  @override
  String get groupWidelyDispersed => 'muy dispersos';

  @override
  String get help => 'Ayuda';

  @override
  String get helpBattery =>
      'Por debajo del 20 % de batería aparece un aviso durante la salida; conecta un cargador o el registro se detendrá si el móvil se apaga.';

  @override
  String get helpCloudDone => 'En el servidor.';

  @override
  String get helpCloudOff => 'Aún no sincronizado.';

  @override
  String get helpCloudUpload =>
      'Modificado, se enviará con la próxima sincronización.';

  @override
  String get helpColorBlue => 'Azul oscuro: el avistamiento está completo.';

  @override
  String get helpColorGreen => 'Verde: entrada rápida de una tortuga.';

  @override
  String get helpColorRed =>
      'Rojo: falta un campo obligatorio (p. ej. el número de animales).';

  @override
  String get helpColorYellow =>
      'Amarillo: solo falta el final (fin de la salida, posición final); suele completarse más tarde.';

  @override
  String get helpColorsTitle => 'Colores y símbolos de la lista';

  @override
  String get helpGpsBackground =>
      'El recorrido también se registra en segundo plano; la notificación indica que el registro está activo.';

  @override
  String get helpGpsIcon =>
      'El símbolo de GPS arriba: verde = posición correcta, naranja = buscando, rojo = GPS apagado. Con el GPS apagado no se registra el recorrido.';

  @override
  String get helpGpsTitle => 'GPS, batería y pantalla';

  @override
  String get helpMissingHints =>
      'En el formulario, una tarjeta arriba muestra los campos obligatorios vacíos y los valores que parecen incorrectos. Toca un aviso para ir al campo. Siempre puedes guardar.';

  @override
  String get helpQuick =>
      '«Tortuga» guarda una tortuga con la posición y la hora actuales en dos toques. «Avistamiento» abre el formulario completo.';

  @override
  String get helpQuickEnd =>
      'Cuando los animales se hayan ido, toca el botón de chincheta del avistamiento en la lista para fijar la posición y la hora finales.';

  @override
  String get helpQuickTitle => 'Entrada rápida';

  @override
  String get helpScreen =>
      '«Mantener la pantalla encendida» en los ajustes de la salida mantiene la pantalla activa mientras la app está abierta.';

  @override
  String get helpShowIntro => 'Mostrar la introducción de nuevo';

  @override
  String get helpSyncAuto =>
      'La app se sincroniza sola cuando vuelve la red y cada 15 minutos. La línea superior de la pestaña de avistamientos muestra la última sincronización y lo pendiente.';

  @override
  String get helpSyncManual =>
      'Para sincronizar ya: desliza la lista hacia abajo, toca el botón de sincronizar o usa Menú → «Sincronizar con el servidor».';

  @override
  String get helpSyncMap =>
      'Las zonas del mapa que has visto se guardan y se muestran también sin conexión.';

  @override
  String get helpSyncOffline =>
      'Todo se guarda primero en el móvil. Puedes registrar avistamientos sin red; no se pierde nada.';

  @override
  String get helpSyncTitle => 'Sincronización y trabajo sin conexión';

  @override
  String get helpTourDefault =>
      'Indica barco, patrón y viento una vez al día en Menú → «Fijar salida predeterminada». Los avistamientos nuevos toman estos valores.';

  @override
  String get helpTourEnd =>
      'Sin zona base, termina la salida con el botón «Fin de salida»; después verás un resumen.';

  @override
  String get helpTourHomeArea =>
      'Con la «zona base» activada, la salida empieza automáticamente al salir del puerto y termina al volver.';

  @override
  String get helpTourRoute =>
      'La línea naranja del mapa es el recorrido registrado de la salida. La pestaña de avistamientos los agrupa por salida con duración, distancia y especies.';

  @override
  String get helpTourTitle => 'Salida y zona base';

  @override
  String get imageNotFound => 'Imagen no encontrada';

  @override
  String get info => 'Información';

  @override
  String get internalError => 'Error interno';

  @override
  String get intro1Text =>
      '«Avistamiento» abre el formulario completo, «Tortuga» guarda una tortuga en dos toques. Los colores de la lista indican lo que falta.';

  @override
  String get intro1Title => 'Registrar avistamientos';

  @override
  String get intro2Text =>
      'Fija la salida predeterminada una vez al día. La app registra el recorrido en el mapa; con zona base, la salida incluso empieza y termina sola.';

  @override
  String get intro2Title => 'Salida y recorrido';

  @override
  String get intro3Text =>
      'Todo se guarda en el móvil y se sincroniza automáticamente en cuanto hay red. Encontrarás esto y más en Menú → Ayuda.';

  @override
  String get intro3Title => 'Funciona sin conexión';

  @override
  String get introDone => '¡Vamos!';

  @override
  String get introNext => 'Siguiente';

  @override
  String get introSkip => 'Saltar';

  @override
  String get labelAllowTourEnd =>
      'Permitir el botón de fin de salida para todos los avistamientos';

  @override
  String get labelBeaufort => 'Viento/estado del mar (Beaufort)';

  @override
  String get labelBehaviour => 'Comportamiento';

  @override
  String get labelBoat => 'Barco';

  @override
  String get labelCalves => 'Crías';

  @override
  String get labelDistanceCoast => 'Distancia a la costa más cercana';

  @override
  String get labelEstimationNoGps => 'Estimación sin GPS';

  @override
  String get labelFreqBehaviour => 'Comportamientos frecuentes de individuos';

  @override
  String get labelGroupStructure => 'Estructura del grupo';

  @override
  String get labelJuveniles => 'Juveniles';

  @override
  String get labelKeepScreenOn => 'Mantener la pantalla encendida';

  @override
  String get labelNewborns => 'Recién nacidos';

  @override
  String get labelNote => 'Nota';

  @override
  String get labelOther => 'Otros';

  @override
  String get labelOtherBoats => 'Otros barcos presentes';

  @override
  String get labelOtherSpecies => 'Otras especies';

  @override
  String get labelPassword => 'Contraseña';

  @override
  String get labelPhotosTaken => 'Fotos tomadas';

  @override
  String get labelReaction => 'Reacción';

  @override
  String get labelRecAnimals => 'Animales reconocibles';

  @override
  String get labelSightingFrom => 'Duración del avistamiento: desde';

  @override
  String get labelSkipper => 'Patrón';

  @override
  String get labelSpecies => 'Especie';

  @override
  String get labelSubgroups => 'Subgrupos';

  @override
  String get labelUntil => 'hasta';

  @override
  String get labelUrl => 'URL MWPA';

  @override
  String get labelUseHomeArea =>
      'Inicio y fin automáticos de la salida mediante la zona base';

  @override
  String get labelUsername => 'Usuario / correo electrónico';

  @override
  String get language => 'Idioma';

  @override
  String get locationPermissionText =>
      'Ve a los ajustes del sistema y permite que la app acceda a la ubicación.';

  @override
  String get locationPermissionTitle => 'Se requiere permiso de ubicación';

  @override
  String logShareFailed(String error) {
    return 'No se pudo compartir el registro: $error';
  }

  @override
  String get loginServerTimeout =>
      'El servidor no respondió a tiempo. Inténtalo más tarde.';

  @override
  String get loginServerUnreachable =>
      'No hay conexión con el servidor. Comprueba la red y la URL de MWPA.';

  @override
  String get loginTitle => 'Inicio de sesión MWPA';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutQuestion => '¿Quieres cerrar la sesión?';

  @override
  String logoutUnsynced(int count) {
    return '$count avistamiento(s) aún no están sincronizados. Sincroniza antes de cerrar la sesión; si no, se subirán con el próximo inicio de sesión.\n\n¿Cerrar sesión de todos modos?';
  }

  @override
  String get mapAttribution => 'Fuente del mapa';

  @override
  String mapPositionPoints(String position, int count) {
    return '$position / Puntos: $count';
  }

  @override
  String get mapWaitForGps => 'esperando GPS ...';

  @override
  String get menu => 'Menú';

  @override
  String get myLocation => 'Mi ubicación';

  @override
  String get nauticalMilesUnit => 'mn';

  @override
  String get noGpsPositionYet => 'Aún no hay posición GPS';

  @override
  String get noImageSelected => 'Ninguna imagen seleccionada';

  @override
  String get noPosition => 'Sin posición';

  @override
  String get noPositionLower => 'sin posición';

  @override
  String get noSightingsHint => 'Pulsa «Avistamiento» para registrar uno.';

  @override
  String get noSightingsYet => 'Aún no hay avistamientos';

  @override
  String get noUserInfo =>
      '¡El servidor no ha devuelto información del usuario!';

  @override
  String get notAMember => '¿Aún no eres miembro? ';

  @override
  String get notAValidNumber => 'Número no válido';

  @override
  String get notLoggedIn => 'sin sesión iniciada';

  @override
  String get notSelected => 'sin seleccionar';

  @override
  String get notSet => 'sin definir';

  @override
  String get ok => 'Aceptar';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get positionFoundQuestion =>
      'Para esta hora hay una posición de la salida actual. ¿Usarla como posición?';

  @override
  String get positionFoundTitle => 'Posición encontrada';

  @override
  String get projectOfMeer => 'Un proyecto de la asociación M.E.E.R. e.V.';

  @override
  String get qcIncomplete => 'El código Quick Connect está incompleto.';

  @override
  String get qcInvalidPayload =>
      'El código QR no es un código Quick Connect válido.';

  @override
  String get qcPointAtCode => 'Apunta al código QR del portal web de MWPA.';

  @override
  String get qcUnsupportedVersion =>
      'Versión de Quick Connect no compatible. Actualiza la app.';

  @override
  String get quickConnect => 'Quick Connect';

  @override
  String get registerOnPortal => '¡Regístrate en tu portal MWPA!';

  @override
  String get remove => 'Quitar';

  @override
  String get removeImage => 'Quitar imagen';

  @override
  String get required => 'Obligatorio';

  @override
  String get save => 'Guardar';

  @override
  String get saveAnywayHint =>
      'Puedes guardar igualmente y completarlo más tarde.';

  @override
  String get saveDefaultTour => 'Guardar salida por defecto';

  @override
  String get saveSighting => 'Guardar avistamiento';

  @override
  String savedStillEmpty(String fields) {
    return 'Guardado. Aún vacío: $fields';
  }

  @override
  String get sectionAnimals => 'Animales';

  @override
  String get sectionBehaviour => 'Comportamiento e identificación';

  @override
  String get sectionNotes => 'Otras notas';

  @override
  String get sectionPicture => 'Imagen';

  @override
  String get sectionSettings => 'Ajustes';

  @override
  String get sectionTimePosition => 'Hora y posición';

  @override
  String get sectionTour => 'Salida';

  @override
  String get selectEmptyList => '<lista vacía>';

  @override
  String get selectPlease => '<seleccione>';

  @override
  String selectUnknownId(String id) {
    return 'ID desconocido: $id';
  }

  @override
  String get serverTimeout =>
      'El servidor no respondió a tiempo. Inténtalo más tarde. Los datos se quedan en el dispositivo y se sincronizarán más tarde.';

  @override
  String get serverUnreachable =>
      'No hay conexión con el servidor. Comprueba la red y la URL del servidor. Los datos se quedan en el dispositivo y se sincronizarán más tarde.';

  @override
  String get sessionNotStarted => '¡La sesión de usuario no se ha iniciado!';

  @override
  String get setDefaultTour => 'Definir salida por defecto';

  @override
  String get setDefaultTourFirst =>
      'Primero define la salida por defecto con fecha y hora de inicio. Hasta entonces no se puede añadir la entrada.';

  @override
  String get setEndLocation => 'Fijar posición final';

  @override
  String get setEndLocationQuestion =>
      '¿Quieres fijar la posición y la hora final de este avistamiento?';

  @override
  String get setEndLocationTitle => 'Fijar posición/hora final';

  @override
  String get settings => 'Ajustes';

  @override
  String get shareAppLog => 'Compartir registro de la app';

  @override
  String get sightingCloseQuestion =>
      '¿Cerrar el avistamiento sin guardar? ¡Se perderán todos los cambios!';

  @override
  String get sightingCloseTitle => 'Cerrar avistamiento';

  @override
  String sightingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avistamientos',
      one: '1 avistamiento',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get speciesNotFound => 'Especie no encontrada';

  @override
  String get stateEndMissing => 'Falta el final';

  @override
  String get stateIncomplete => 'Incompleto';

  @override
  String get stateUnknownSpecies => 'Especie desconocida';

  @override
  String get stillOpenAtEnd => 'Pendiente: rellenar al final';

  @override
  String get switchCamera => 'Cambiar cámara';

  @override
  String get switchToDarkTheme => 'Tema oscuro';

  @override
  String get switchToLightTheme => 'Tema claro';

  @override
  String get syncAutoStopped =>
      'Sincronización automática detenida – toca para ver detalles';

  @override
  String get syncChanged => 'Modificado, pendiente de sincronizar';

  @override
  String get syncConnecting => 'Conectando ...';

  @override
  String get syncDone => 'Sincronizado';

  @override
  String get syncFailedRetry =>
      'Error de sincronización, se reintentará – toca para ver detalles';

  @override
  String syncLastDate(String date) {
    return 'Última sincronización $date';
  }

  @override
  String syncLastHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Sincronizado hace $hours horas',
      one: 'Sincronizado hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get syncLastJustNow => 'Sincronizado ahora mismo';

  @override
  String syncLastMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Sincronizado hace $minutes minutos',
      one: 'Sincronizado hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get syncLoginRejected =>
      'El servidor rechazó el inicio de sesión (¿contraseña cambiada?). Cierra sesión y vuelve a iniciarla. Los datos se quedan en el dispositivo.';

  @override
  String get syncNotYet => 'Aún no sincronizado';

  @override
  String syncOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String get syncRunning => 'Sincronizando …';

  @override
  String get syncSignInAgain =>
      'No hay datos de acceso guardados para la sincronización. Cierra sesión y vuelve a iniciarla con tu contraseña.';

  @override
  String get syncStepBehaviouralStates => 'Estados de comportamiento';

  @override
  String get syncStepEncounterCategories => 'Categorías de encuentro';

  @override
  String get syncStepFinish => 'Terminado';

  @override
  String get syncStepImages => 'Subiendo fotos';

  @override
  String get syncStepSightings => 'Subiendo avistamientos';

  @override
  String get syncStepSpecies => 'Especies';

  @override
  String syncStepTracking(String detail) {
    return 'Subiendo recorrido $detail';
  }

  @override
  String get syncStepVehicles => 'Barcos y patrones';

  @override
  String get syncTitle => 'Sincronizando con el servidor';

  @override
  String get syncWithServer => 'Sincronizar con el servidor';

  @override
  String get tabSightings => 'Avistamientos';

  @override
  String get tabTour => 'Salida';

  @override
  String get toggleTorch => 'Linterna sí/no';

  @override
  String get tourCloseQuestion =>
      '¿Cerrar la salida sin guardar? ¡Se perderán todos los cambios!';

  @override
  String get tourCloseTitle => 'Cerrar salida';

  @override
  String get tourDateNotCurrent =>
      'La fecha de la salida no es la actual, ¡compruébala!';

  @override
  String get tourDateNotSet => 'Salida: no hay fecha por defecto';

  @override
  String get tourDateTitle => 'Fecha de la salida';

  @override
  String get tourEnd => 'Fin de la salida';

  @override
  String get tourEndQuestion =>
      '¿Actualizar la hora de fin de la salida en todos los avistamientos de la salida actual?';

  @override
  String get tourFinishedTitle => 'Salida terminada';

  @override
  String tourLabel(String date, String start) {
    return 'Salida: $date - $start';
  }

  @override
  String get tourNotStartedHomeArea =>
      'La salida aún no ha empezado (todavía en la zona base). Hasta entonces no se puede añadir la entrada.';

  @override
  String tourSince(String time) {
    return 'desde $time';
  }

  @override
  String get tourWaitingHomeArea =>
      'Salida: en la zona base, esperando el inicio';

  @override
  String get turtleGreen => 'Tortuga verde';

  @override
  String get turtleHawksbill => 'Tortuga carey';

  @override
  String get turtleLeatherback => 'Tortuga laúd';

  @override
  String get turtleLoggerhead => 'Tortuga boba';

  @override
  String get turtleSeaTurtle => 'Tortuga marina';

  @override
  String get turtleUnknown => 'Desconocida';

  @override
  String get useCurrentPosition => 'Usar la posición actual';

  @override
  String get userNeedsOrganization =>
      'Actualiza el usuario, todos los usuarios necesitan una organización.';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get waitForGps => 'Espera la señal GPS.';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Alejar';
}
