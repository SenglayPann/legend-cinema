import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/services/booking_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();

  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _historyBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Defer to after the first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    final authState = context.read<AuthState>();
    final userId = authState.currentUser?.id;

    print('userId: $userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final bookings = await _bookingService.getUserBookings(userId);

      print('bookings: $bookings');
      final now = DateTime.now();

      // Separate upcoming and history based on showDateTime
      final upcoming = <BookingModel>[];
      final history = <BookingModel>[];

      for (var booking in bookings) {
        final showDate = booking.showDateTime.toDate();
        if (showDate.isAfter(now) && booking.bookingStatus == 'confirmed') {
          upcoming.add(booking);
        } else {
          history.add(booking);
        }
      }

      // Sort upcoming by date (nearest first)
      upcoming.sort((a, b) => a.showDateTime.compareTo(b.showDateTime));
      // Sort history by date (most recent first)
      history.sort((a, b) => b.showDateTime.compareTo(a.showDateTime));

      setState(() {
        _upcomingBookings = upcoming;
        _historyBookings = history;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Tickets',
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Upcoming'),
                      if (_upcomingBookings.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_upcomingBookings.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'History'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming Tab
                      _buildBookingList(_upcomingBookings, isUpcoming: true),
                      // History Tab
                      _buildBookingList(_historyBookings, isUpcoming: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> bookings, {
    required bool isUpcoming,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.confirmation_number_outlined : Icons.history,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming tickets' : 'No booking history',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 8),
              const Text(
                'Book a movie to see your tickets here',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: Colors.red,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index], isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, {required bool isUpcoming}) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // Movie Info Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 100,
                    color: Colors.grey[800],
                    child: CachedNetworkImage(
                      imageUrl: '', // moviePosterUrl not in BookingModel
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white24,
                          size: 32,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white24,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Movie Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.movieTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.cinemaName,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.calendar_today,
                            booking.showDate,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.access_time, booking.showTime),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.chair,
                            'Hall ${booking.hallNumber}',
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.confirmation_number,
                            '${booking.seatCount} seat${booking.seatCount > 1 ? 's' : ''}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider with ticket tear effect
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),

          // Bottom Row: Booking Code & Status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Booking Code
                Row(
                  children: [
                    const Icon(Icons.qr_code, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.bookingStatus, isUpcoming),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(booking.bookingStatus, isUpcoming),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Color _getStatusColor(String status, bool isUpcoming) {
    if (isUpcoming && status == 'confirmed') {
      return Colors.green;
    }
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status, bool isUpcoming) {
    if (isUpcoming && status == 'confirmed') {
      return 'Active';
    }
    switch (status) {
      case 'confirmed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status.toUpperCase();
    }
  }
}
