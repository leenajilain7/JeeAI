const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatMessageTime(DateTime timestamp) {
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final period = timestamp.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String formatInboxTime(DateTime timestamp, {DateTime? now}) {
  final currentDate = now ?? DateTime.now();
  final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final daysAgo = today.difference(messageDate).inDays;

  if (daysAgo == 0) return formatMessageTime(timestamp);
  if (daysAgo == 1) return 'Yesterday';
  if (daysAgo > 1 && daysAgo < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[timestamp.weekday - 1];
  }
  return '${_monthNames[timestamp.month - 1]} ${timestamp.day}';
}
