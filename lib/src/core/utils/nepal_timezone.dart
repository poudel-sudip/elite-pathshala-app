/// Utility class for handling Nepal timezone (UTC+5:45) conversions and formatting
class NepalTimezone {
  // Nepal Standard Time offset: UTC+5:45
  static const Duration _nepalOffset = Duration(hours: 5, minutes: 45);

  /// Convert any DateTime to Nepal time
  static DateTime toNepalTime(DateTime dateTime) {
    // If the DateTime is local, convert to UTC first
    DateTime utcTime = dateTime.isUtc ? dateTime : dateTime.toUtc();
    
    // Add Nepal offset to UTC time
    return utcTime.add(_nepalOffset);
  }

  /// Convert DateTime string to Nepal time
  static DateTime parseToNepalTime(String dateString) {
    try {
      DateTime parsedTime = DateTime.parse(dateString);
      return toNepalTime(parsedTime);
    } catch (e) {
      // If parsing fails, return current Nepal time
      return getCurrentNepalTime();
    }
  }

  /// Get current time in Nepal timezone
  static DateTime getCurrentNepalTime() {
    return toNepalTime(DateTime.now().toUtc());
  }

  /// Format date for notifications (relative format)
  static String formatNotificationDate(String dateString) {
    try {
      final nepalDateTime = parseToNepalTime(dateString);
      final now = getCurrentNepalTime();
      final difference = now.difference(nepalDateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} min ago';
        }
        return '${difference.inHours} hr ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[nepalDateTime.month - 1]} ${nepalDateTime.day}, ${nepalDateTime.year}';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  /// Format date for notification details (full format with time)
  static String formatNotificationDetailDate(String dateString) {
    try {
      final nepalDateTime = parseToNepalTime(dateString);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      final day = nepalDateTime.day;
      final month = months[nepalDateTime.month - 1];
      final year = nepalDateTime.year;
      final hour = nepalDateTime.hour;
      final minute = nepalDateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '$month $day, $year at $displayHour:$minute $period';
    } catch (e) {
      return 'Unknown date';
    }
  }

  /// Format date for videos (actual date format)
  static String formatVideoDate(String dateString) {
    try {
      final nepalDateTime = parseToNepalTime(dateString);
      // Always show actual date format "MMM dd, yyyy"
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[nepalDateTime.month - 1]} ${nepalDateTime.day}, ${nepalDateTime.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  /// Format date for video details (simple format)
  static String formatVideoDetailDate(String dateString) {
    try {
      final nepalDateTime = parseToNepalTime(dateString);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[nepalDateTime.month - 1]} ${nepalDateTime.day}, ${nepalDateTime.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  /// Format time for chat messages (12-hour format)
  static String formatChatTime(DateTime dateTime) {
    final nepalTime = toNepalTime(dateTime);
    
    final hour = nepalTime.hour;
    final minute = nepalTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  /// Format date for chat headers
  static String formatChatDate(DateTime date) {
    final nepalNow = getCurrentNepalTime();
    final nepalMessageDate = toNepalTime(date);
    
    final today = DateTime(nepalNow.year, nepalNow.month, nepalNow.day);
    final messageDate = DateTime(nepalMessageDate.year, nepalMessageDate.month, nepalMessageDate.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${nepalMessageDate.day}/${nepalMessageDate.month}/${nepalMessageDate.year}';
    }
  }

  /// Check if two dates are the same day in Nepal timezone
  static bool isSameDay(DateTime date1, DateTime date2) {
    final nepalDate1 = toNepalTime(date1);
    final nepalDate2 = toNepalTime(date2);
    
    return nepalDate1.year == nepalDate2.year &&
           nepalDate1.month == nepalDate2.month &&
           nepalDate1.day == nepalDate2.day;
  }

  /// Format time for schedules (12-hour format)
  static String formatScheduleTime(DateTime time) {
    final nepalTime = toNepalTime(time);
    int hour = nepalTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '${hour}:${nepalTime.minute.toString().padLeft(2, '0')} $period';
  }
} 