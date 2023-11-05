import '../model/widget_model.dart';

final RegExp regExpForWord = RegExp(r"[\w-._]+");

List<Message> validatorFancy(String? value) {
  if (value == null || value.isEmpty) {
    return [
      Message("Enter some text:\n- Be relevant\n- Be concise", Level.info,
          Category.syntax),
    ];
  }
  if (value.isNotEmpty && value.length < 5) {
    return [
      Message("Invalid syntax", Level.error, Category.syntax),
      Message("Misspelled word", Level.warning, Category.spelling)
    ];
  }
  return [
    Message("Looks good so far", Level.info, Category.syntax),
    Message(
        "${value.length} characters, ${regExpForWord.allMatches(value).length} words.",
        Level.info,
        Category.syntax)
  ];
}
