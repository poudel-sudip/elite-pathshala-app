import '../../../core/services/api_service.dart';
import '../../../core/models/booking_models.dart';

class BookingService {
  // Fetch user bookings list
  static Future<BookingListResponse> getUserBookings() async {
    try {
      final response = await ApiService.get('api/student/course/bookings');
      return BookingListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch bookings: ${e.toString()}');
    }
  }
} 