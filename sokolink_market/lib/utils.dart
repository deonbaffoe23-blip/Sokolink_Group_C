import 'package:intl/intl.dart';

final NumberFormat cedis = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

String formatDateTime(DateTime d) => DateFormat('dd MMM, hh:mm a').format(d);

String formatTimeAgo(DateTime? d) {
  if (d == null) return 'Never synced';
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} day(s) ago';
}
