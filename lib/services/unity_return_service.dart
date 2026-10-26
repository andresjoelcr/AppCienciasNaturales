import 'package:shared_preferences/shared_preferences.dart';

class UnityReturnService {
  static const String _subtemaKey = 'unity_return_subtema';
  static const String _guardadoEnKey = 'unity_return_subtema_guardado_en';
  static const Duration _vigencia = Duration(hours: 6);

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<void> guardarSubtema(String subtemaId) async {
    await _prefs.setString(_subtemaKey, subtemaId);
    await _prefs.setInt(_guardadoEnKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> consumirSubtema({
    DateTime? soloSiGuardadoAntesDe,
  }) async {
    final subtemaId = await _prefs.getString(_subtemaKey);
    final guardadoEn = await _prefs.getInt(_guardadoEnKey);

    if (subtemaId == null || guardadoEn == null) return null;

    // No consumir un retorno guardado despues de iniciar esta pantalla: pudo
    // haberse guardado al abrir Unity y debe sobrevivir hasta que la Activity
    // se recree al volver.
    if (soloSiGuardadoAntesDe != null &&
        guardadoEn > soloSiGuardadoAntesDe.millisecondsSinceEpoch) {
      return null;
    }

    await _prefs.remove(_subtemaKey);
    await _prefs.remove(_guardadoEnKey);

    final edad = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(guardadoEn),
    );
    if (edad > _vigencia) return null;

    return subtemaId;
  }

  static Future<void> limpiar() async {
    await _prefs.remove(_subtemaKey);
    await _prefs.remove(_guardadoEnKey);
  }
}
