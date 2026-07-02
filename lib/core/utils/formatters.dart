/// Formatting utilities used throughout the app.
library;

class Formatters {
  const Formatters._();

  /// Compact number: 24817 → '24.8K', 1000000 → '1M'.
  static String compact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  /// Relative date: just now, 3 minutes ago, 2 hours ago, yesterday, 4 days ago, Jan 3.
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    }
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.day}';
  }

  /// Zero-padded two-digit number.
  static String twoDigit(int n) => n.toString().padLeft(2, '0');

  /// Duration in MM:SS format.
  static String duration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${twoDigit(minutes)}:${twoDigit(seconds)}';
  }

  /// Percentage: 0.7452 → '74%'.
  static String percent(double v) => '${(v * 100).round()}%';
}
