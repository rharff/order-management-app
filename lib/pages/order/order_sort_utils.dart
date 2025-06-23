/// Utility function to sort orders by deadline (nearest future first)
/// Usage: sortOrdersByDeadline(listOfOrders);
void sortOrdersByDeadline(List<Map<String, dynamic>> orders) {
  DateTime now = DateTime.now();
  orders.sort((a, b) {
    final aObj = a['datetimeObj'] as DateTime?;
    final bObj = b['datetimeObj'] as DateTime?;
    if (aObj == null || bObj == null) return 0;
    final aDiff = aObj.difference(now).inSeconds;
    final bDiff = bObj.difference(now).inSeconds;
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
