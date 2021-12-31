String clearPhoneNumber(String phone) {
  return phone
      .replaceAll(" ", "")
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("+", "");
}
