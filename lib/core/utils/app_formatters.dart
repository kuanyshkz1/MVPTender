class AppFormatters {
  const AppFormatters._();

  static String amount(num value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ' ',
    );
  }

  static String money(num value) => '${amount(value)} ₸';

  static String compactAmount(num value) {
    final amountValue = value.toDouble();
    if (amountValue >= 1000000000) {
      return '${(amountValue / 1000000000).toStringAsFixed(1)}B';
    }
    if (amountValue >= 1000000) {
      return '${(amountValue / 1000000).toStringAsFixed(1)}M';
    }
    if (amountValue >= 1000) {
      return '${(amountValue / 1000).toStringAsFixed(0)}K';
    }
    return amountValue.toInt().toString();
  }

  static String dayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  static String date(DateTime date) {
    return '${dayMonth(date)}.${date.year}';
  }

  static String time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
