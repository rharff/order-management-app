// lib/order_sort_utils.dart

// Function to sort orders by their deadline,
// prioritizing orders with a deadline over those without,
// and then by chronological order.
void sortOrdersByDeadline(List<Map<String, dynamic>> orders) {
  orders.sort((a, b) {
    final DateTime? deadlineA = a['datetimeObj'];
    final DateTime? deadlineB = b['datetimeObj'];

    if (deadlineA == null && deadlineB == null) {
      return 0; // Both have no deadline, maintain relative order.
    } else if (deadlineA == null) {
      return 1; // A has no deadline, B has one, so B comes first.
    } else if (deadlineB == null) {
      return -1; // A has deadline, B has no, so A comes first.
    } else {
      // Both have deadlines, sort chronologically.
      return deadlineA.compareTo(deadlineB);
    }
  });
}
