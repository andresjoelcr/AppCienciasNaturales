/// Conversiones tolerantes para valores numericos leidos desde Firestore.
///
/// Firestore puede devolver `null`, `int` o `double` para un mismo campo
/// (por ejemplo, `FieldValue.increment` o numeros escritos desde la consola
/// web), por lo que nunca se debe asumir el tipo directamente.
int toInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return fallback;
}

double toDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return fallback;
}
