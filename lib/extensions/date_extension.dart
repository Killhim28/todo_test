// Расширение стандартного класса DateTime
extension DateFormating on DateTime {
  // Собственный метод для форматирования дат
  String toFriendlyString() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ); // Обрезка времени, остается только дата
    final dateToCheck = DateTime(year, month, day);

    // Подсчет разницы в днях
    final difference = dateToCheck.difference(today).inDays;

    if (difference == 0) {
      return "Сегодня";
    } else if (difference == 1) {
      return "Завтра";
    } else if (difference == -1) {
      return "Вчера";
    } else if (difference == 2) {
      return "Послезавтра";
    } else if (difference == -2) {
      return "Позавчера";
    } else {
      return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
    }
  }
}
