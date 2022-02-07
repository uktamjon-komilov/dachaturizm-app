String formatNumber(int number) {
  String s = number.toString().split("").reversed.join();
  List<String> parts = [];
  for (int i = 1; i < s.length + 1; i++) {
    parts.add(s.substring(i - 1, i));
    if (i != 0 && i % 3 == 0) {
      parts.add(" ");
    }
  }
  s = parts.join("");
  return reverse(s);
}

String reverse(String text) {
  return text.split("").reversed.join();
}
