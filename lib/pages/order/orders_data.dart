// orders_data.dart

final List<Map<String, dynamic>> orders = [];

void sortOrdersByDeadline() {
  DateTime now = DateTime.now();
  orders.sort((a, b) {
    final aDiff = (a['datetimeObj'] as DateTime).difference(now).inSeconds;
    final bDiff = (b['datetimeObj'] as DateTime).difference(now).inSeconds;
    if (aDiff >= 0 && bDiff >= 0) {
      return aDiff.compareTo(bDiff);
    } else if (aDiff >= 0) {
      return -1;
    } else if (bDiff >= 0) {
      return 1;
    } else {
      return bDiff.compareTo(aDiff);
    }
  });
}
