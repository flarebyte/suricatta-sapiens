import '../model/widget_model.dart';

final RegExp regExpForWord = RegExp(r"[\w-._]+");

List<Message> validatorFancy(String? value) {
  if (value == null || value.isEmpty) {
    return [
      Message("Enter some text:\n- Be relevant\n- Be concise", MessageLevel.info,
          MessageCategory.syntax),
    ];
  }
  if (value.isNotEmpty && value.length < 5) {
    return [
      Message("Invalid syntax", MessageLevel.error, MessageCategory.syntax),
      Message("Misspelled word", MessageLevel.warning, MessageCategory.spelling)
    ];
  }
  return [
    Message("Looks good so far", MessageLevel.info, MessageCategory.syntax),
    Message(
        "${value.length} characters, ${regExpForWord.allMatches(value).length} words.",
        MessageLevel.info,
        MessageCategory.syntax)
  ];
}
