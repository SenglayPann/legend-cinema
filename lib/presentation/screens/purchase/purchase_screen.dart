import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/fnb_order_model.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/fnb_order_service.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';
import './booking_detail_screen.dart';
import './fnb_order_detail_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final FnbOrderService _fnbOrderService = FnbOrderService();

  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _historyBookings = [];
  List<FnbOrderModel> _activeFnbOrders = [];
  List<FnbOrderModel> _historyFnbOrders = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Defer to after the first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final authState = context.read<AuthState>();
    final userId = authState.currentUser?.id;

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch Bookings
      final bookings = await _bookingService.getUserBookings(userId);
      final now = DateTime.now();

      final upcomingBookings = <BookingModel>[];
      final historyBookings = <BookingModel>[];

      for (var booking in bookings) {
        final showDate = booking.showDateTime.toDate();
        if (showDate.isAfter(now) && booking.bookingStatus == 'confirmed') {
          upcomingBookings.add(booking);
        } else {
          historyBookings.add(booking);
        }
      }

      upcomingBookings.sort((a, b) => a.showDateTime.compareTo(b.showDateTime));
      historyBookings.sort((a, b) => b.showDateTime.compareTo(a.showDateTime));

      // Fetch F&B Orders
      final fnbOrders = await _fnbOrderService.getUserStandaloneFnbOrders(
        userId,
      );
      final activeFnb = <FnbOrderModel>[];
      final historyFnb = <FnbOrderModel>[];

      for (var order in fnbOrders) {
        if (['pending', 'preparing', 'ready'].contains(order.status)) {
          activeFnb.add(order);
        } else {
          historyFnb.add(order);
        }
      }

      if (mounted) {
        setState(() {
          _upcomingBookings = upcomingBookings;
          _historyBookings = historyBookings;
          _activeFnbOrders = activeFnb;
          _historyFnbOrders = historyFnb;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'my_tickets'.tr(),
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
                      Text('upcoming'.tr()),
                      if (_upcomingBookings.isNotEmpty ||
                          _activeFnbOrders.isNotEmpty) ...[
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
                            '${_upcomingBookings.length + _activeFnbOrders.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(text: 'history'.tr()),
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
                      _buildListContent(
                        bookings: _upcomingBookings,
                        fnbOrders: _activeFnbOrders,
                        isUpcoming: true,
                        emptyMessage: 'no_booking_order_found'.tr(),
                      ),
                      // History Tab
                      _buildListContent(
                        bookings: _historyBookings,
                        fnbOrders: _historyFnbOrders,
                        isUpcoming: false,
                        emptyMessage: 'no_history_found'.tr(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent({
    required List<BookingModel> bookings,
    required List<FnbOrderModel> fnbOrders,
    required bool isUpcoming,
    required String emptyMessage,
  }) {
    if (bookings.isEmpty && fnbOrders.isEmpty) {
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
              emptyMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Colors.red,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookings.isNotEmpty) ...[
              if (fnbOrders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                  child: Text(
                    'movie_tickets'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ...bookings
                  .map(
                    (booking) =>
                        _buildBookingCard(booking, isUpcoming: isUpcoming),
                  )
                  .toList(),
            ],

            if (bookings.isNotEmpty && fnbOrders.isNotEmpty)
              const SizedBox(height: 16),

            if (fnbOrders.isNotEmpty) ...[
              if (bookings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'fnb_orders'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ...fnbOrders.map((order) => _buildFnbOrderCard(order)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, {required bool isUpcoming}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailScreen(booking: booking),
          ),
        );
      },
      child: GlassContainer(
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
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white24,
                        size: 32,
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
                              '${'hall'.tr()} ${booking.hallNumber}',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.confirmation_number,
                              '${booking.seatCount} ${booking.seatCount > 1 ? 'seats'.tr() : 'seat'.tr()}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
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

            // Bottom Row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking Code
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        color: Colors.white54,
                        size: 16,
                      ),
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
      ),
    );
  }

  Widget _buildFnbOrderCard(FnbOrderModel order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FnbOrderDetailScreen(order: order)),
        );
      },
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.cinemaName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} ${'items'.tr()} • \$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getFnbStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      return 'active'.tr();
    }
    switch (status) {
      case 'confirmed':
        return 'completed'.tr();
      case 'cancelled':
        return 'cancelled'.tr();
      case 'pending':
        return 'pending'.tr();
      default:
        return status.toUpperCase();
    }
  }

  Color _getFnbStatusColor(String status) {
    switch (status) {
      case 'ready':
      case 'collected':
        return Colors.green;
      case 'pending':
      case 'preparing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
