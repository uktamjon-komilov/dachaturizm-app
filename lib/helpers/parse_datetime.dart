String parseDateTime(DateTime datetime) {
  return "${datetime.year}-${datetime.month}-${datetime.day}";
}

String formatDateTime(DateTime? datetime) {
  return "${datetime!.day}.${datetime.month}.${datetime.year}  ${datetime.hour}:${datetime.minute}";
}
