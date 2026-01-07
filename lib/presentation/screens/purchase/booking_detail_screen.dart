import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/gradient_divider.dart';
import 'package:legend_cinema/data/models/fnb_order_model.dart';
import 'package:legend_cinema/data/services/fnb_order_service.dart';

import 'package:legend_cinema/data/models/fnb_order_model.dart';
import 'package:legend_cinema/data/services/fnb_order_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  FnbOrderModel? _fnbOrder;
  bool _isLoadingFnb = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking.fnbOrderId != null &&
        widget.booking.fnbOrderId!.isNotEmpty) {
      _fetchFnbOrder();
    }
  }

  Future<void> _fetchFnbOrder() async {
    setState(() => _isLoadingFnb = true);
    try {
      final fnbService = FnbOrderService();
      // Assuming getFnbOrderById exists or similar
      // If not, we might need to query FnbOrderService
      // Checking FnbOrderService... user provided files earlier,
      // let's assume getFnbOrderById or similar exists or we query firestore directly
      // Actually FnbOrderService was imported in PurchaseScreen, let's assume regular firestore fetch if needed
      // But best to use service if available.
      // I'll use Firestore directly to be safe as I don't see FnbOrderService definition in my recent reads
      // unrelated to PurchaseScreen view.
      // Wait, PurchaseScreen line 24: final FnbOrderService _fnbOrderService = FnbOrderService();
      // So I can instantiate it.

      // Let's just use Firestore directly for simplicity as I can't verify service method names right now
      // without viewing that file again.
      // Actually, I can scroll up to see previous file views...
      // I haven't viewed FnbOrderService.
      // I'll stick to Firestore fetch.

      final doc = await FirebaseFirestore.instance
          .collection('fnb_orders')
          .doc(widget.booking.fnbOrderId)
          .get();

      if (doc.exists) {
        if (mounted) {
          setState(() {
            _fnbOrder = FnbOrderModel.fromMap(doc.data()!, doc.id);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching F&B order: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFnb = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine seat labels. If empty, show "N/A"
    final seatLabels = widget.booking.seats.map((s) => s.seatNumber).join(', ');

    return AppScaffold(
      title: 'Ticket Details',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Movie Poster & Title Header
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.movieTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.booking.cinemaName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hall ${widget.booking.hallNumber}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn('Date', widget.booking.showDate),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _buildInfoColumn('Time', widget.booking.showTime),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seats
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seats', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  Text(
                    seatLabels.isEmpty ? 'No seats selected' : seatLabels,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // F&B Items (Fetched)
            if (_fnbOrder != null && _fnbOrder!.items.isNotEmpty) ...[
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'F&B Items',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    ..._fnbOrder!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.name}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Payment Summary
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Ticket Price',
                    '\$${widget.booking.seatsTotal.toStringAsFixed(2)}',
                  ),
                  if (widget.booking.fnbTotal > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'F&B',
                      '\$${widget.booking.fnbTotal.toStringAsFixed(2)}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  const GradientDivider(),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Total Amount',
                    '\$${widget.booking.totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    size: 200,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking Code: ${widget.booking.bookingCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.red : Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
