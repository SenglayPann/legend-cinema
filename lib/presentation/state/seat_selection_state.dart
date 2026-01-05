import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/fnb_model.dart';
import '../../data/models/hall_model.dart';
import '../../data/models/showtime_model.dart';
import '../../data/services/booking_service.dart';

/// Represents the status of a seat
enum SeatStatus { available, selected, occupied }

/// Represents the type of a seat
enum SeatType { regular, vip, twin }

/// Model for a single seat
class Seat {
  final String id; // e.g., "A1", "B3"
  final String row; // e.g., "A", "B"
  final int column; // e.g., 1, 2, 3
  final SeatType type;
  SeatStatus status;

  Seat({
    required this.id,
    required this.row,
    required this.column,
    required this.type,
    this.status = SeatStatus.available,
  });

  String get label => '$row$column';
}

/// State management for seat selection
class SeatSelectionState extends ChangeNotifier {
  final ShowtimeModel showtime;
  final HallModel hall;
  final BookingService _bookingService = BookingService();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Seat data
  List<List<Seat>> _regularSeats = [];
  List<List<Seat>> _vipSeats = [];
  List<List<Seat>> _twinSeats = [];

  // Booked seat IDs from Firebase
  Set<String> _bookedSeatIds = {};

  // Selected seats
  final Set<String> _selectedSeatIds = {};

  // Countdown timer
  Timer? _countdownTimer;
  int _remainingSeconds = 120; // 2 minutes
  bool _isSessionExpired = false;

  SeatSelectionState({required this.showtime, required this.hall}) {
    _initializeSeats();
  }

  // Getters
  List<List<Seat>> get regularSeats => _regularSeats;
  List<List<Seat>> get vipSeats => _vipSeats;
  List<List<Seat>> get twinSeats => _twinSeats;
  Set<String> get selectedSeatIds => _selectedSeatIds;
  int get remainingSeconds => _remainingSeconds;
  bool get isSessionExpired => _isSessionExpired;

  String get formattedCountdown {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Seat> get selectedSeats {
    final all = <Seat>[];
    for (var row in _regularSeats) {
      all.addAll(row.where((s) => _selectedSeatIds.contains(s.id)));
    }
    for (var row in _vipSeats) {
      all.addAll(row.where((s) => _selectedSeatIds.contains(s.id)));
    }
    for (var row in _twinSeats) {
      all.addAll(row.where((s) => _selectedSeatIds.contains(s.id)));
    }
    return all;
  }

  int get selectedCount => _selectedSeatIds.length;

  double get totalPrice {
    double total = 0;
    for (var seat in selectedSeats) {
      switch (seat.type) {
        case SeatType.regular:
          total += hall.seatPrice;
          break;
        case SeatType.vip:
          total += hall.vipSeatPrice;
          break;
        case SeatType.twin:
          total += hall.twinSeatPrice;
          break;
      }
    }
    return total;
  }

  // Price breakdown by type
  Map<SeatType, int> get seatCountByType {
    final counts = <SeatType, int>{
      SeatType.regular: 0,
      SeatType.vip: 0,
      SeatType.twin: 0,
    };
    for (var seat in selectedSeats) {
      counts[seat.type] = (counts[seat.type] ?? 0) + 1;
    }
    return counts;
  }

  // ============ FnB Cart ============
  final Map<String, int> _fnbQuantities = {}; // FnB id -> quantity
  final Map<String, FnbModel> _fnbItems = {}; // FnB id -> model

  Map<String, int> get fnbQuantities => Map.unmodifiable(_fnbQuantities);
  Map<String, FnbModel> get fnbItems => Map.unmodifiable(_fnbItems);

  int get fnbTotalItems =>
      _fnbQuantities.values.fold(0, (sum, qty) => sum + qty);

  double get fnbTotalPrice {
    double total = 0;
    for (var entry in _fnbQuantities.entries) {
      final item = _fnbItems[entry.key];
      if (item != null) {
        total += item.price * entry.value;
      }
    }
    return total;
  }

  double get grandTotal => totalPrice + fnbTotalPrice;

  bool get hasFnbItems => _fnbQuantities.isNotEmpty;

  int getFnbQuantity(String fnbId) => _fnbQuantities[fnbId] ?? 0;

  void addFnbItem(FnbModel item) {
    _fnbItems[item.id] = item;
    _fnbQuantities[item.id] = (_fnbQuantities[item.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeFnbItem(String fnbId) {
    final current = _fnbQuantities[fnbId] ?? 0;
    if (current > 1) {
      _fnbQuantities[fnbId] = current - 1;
    } else {
      _fnbQuantities.remove(fnbId);
      _fnbItems.remove(fnbId);
    }
    notifyListeners();
  }

  void clearFnbCart() {
    _fnbQuantities.clear();
    _fnbItems.clear();
    notifyListeners();
  }

  /// Initialize seats based on hall layout and fetch booked seats
  Future<void> _initializeSeats() async {
    // Generate seat grids first
    _regularSeats = _generateSeatGrid(
      hall.seatLayout,
      SeatType.regular,
      startRow: 'A',
    );

    if (hall.vipSeatLayout.numberOfRow > 0) {
      final startRowChar = String.fromCharCode(
        'A'.codeUnitAt(0) + hall.seatLayout.numberOfRow,
      );
      _vipSeats = _generateSeatGrid(
        hall.vipSeatLayout,
        SeatType.vip,
        startRow: startRowChar,
      );
    }

    if (hall.twinSeatLayout.numberOfRow > 0) {
      final regularRows = hall.seatLayout.numberOfRow;
      final vipRows = hall.vipSeatLayout.numberOfRow;
      final startRowChar = String.fromCharCode(
        'A'.codeUnitAt(0) + regularRows + vipRows,
      );
      _twinSeats = _generateSeatGrid(
        hall.twinSeatLayout,
        SeatType.twin,
        startRow: startRowChar,
      );
    }

    // Fetch booked seats from Firebase
    try {
      _bookedSeatIds = await _bookingService.getBookedSeatIds(showtime.id);
      print(
        'Fetched ${_bookedSeatIds.length} booked seats for showtime ${showtime.id}',
      );

      // Mark booked seats as occupied
      _markBookedSeatsAsOccupied();
    } catch (e) {
      print('Error fetching booked seats: $e');
    }

    _isLoading = false;
    _startCountdown();
    notifyListeners();
  }

  /// Mark seats that are already booked as occupied
  void _markBookedSeatsAsOccupied() {
    for (var seatId in _bookedSeatIds) {
      final seat = _findSeatById(seatId);
      if (seat != null) {
        seat.status = SeatStatus.occupied;
      }
    }
  }

  List<List<Seat>> _generateSeatGrid(
    SeatLayout layout,
    SeatType type, {
    required String startRow,
  }) {
    final grid = <List<Seat>>[];
    for (int r = 0; r < layout.numberOfRow; r++) {
      final rowChar = String.fromCharCode(startRow.codeUnitAt(0) + r);
      final row = <Seat>[];
      for (int c = 1; c <= layout.numberOfColumn; c++) {
        row.add(Seat(id: '$rowChar$c', row: rowChar, column: c, type: type));
      }
      grid.add(row);
    }
    return grid;
  }

  /// Start the 2-minute countdown
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _isSessionExpired = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// Toggle seat selection
  void toggleSeat(Seat seat) {
    if (seat.status == SeatStatus.occupied || _isSessionExpired) return;

    // For twin seats, select/deselect in pairs
    if (seat.type == SeatType.twin) {
      _toggleTwinSeatPair(seat);
    } else {
      _toggleSingleSeat(seat);
    }
    notifyListeners();
  }

  void _toggleSingleSeat(Seat seat) {
    if (_selectedSeatIds.contains(seat.id)) {
      _selectedSeatIds.remove(seat.id);
      seat.status = SeatStatus.available;
    } else {
      _selectedSeatIds.add(seat.id);
      seat.status = SeatStatus.selected;
    }
  }

  void _toggleTwinSeatPair(Seat seat) {
    // Find the pair seat (index 0,1 are pair, 2,3 are pair, etc)
    final row = seat.row;
    final col = seat.column;
    // Determine if this is an odd or even column (1-indexed)
    // Pairs are: 1-2, 3-4, 5-6, etc.
    final isFirstInPair = col % 2 == 1;
    final pairCol = isFirstInPair ? col + 1 : col - 1;
    final pairId = '$row$pairCol';

    final pairSeat = _findSeatById(pairId);
    final isSelecting = !_selectedSeatIds.contains(seat.id);

    // Check if pair seat is available (not occupied)
    if (pairSeat != null && pairSeat.status == SeatStatus.occupied) {
      // Can't select if pair is occupied, just toggle single
      _toggleSingleSeat(seat);
      return;
    }

    if (isSelecting) {
      // Select both seats
      _selectedSeatIds.add(seat.id);
      seat.status = SeatStatus.selected;
      if (pairSeat != null && pairSeat.status != SeatStatus.occupied) {
        _selectedSeatIds.add(pairSeat.id);
        pairSeat.status = SeatStatus.selected;
      }
    } else {
      // Deselect both seats
      _selectedSeatIds.remove(seat.id);
      seat.status = SeatStatus.available;
      if (pairSeat != null) {
        _selectedSeatIds.remove(pairSeat.id);
        pairSeat.status = SeatStatus.available;
      }
    }
  }

  /// Clear all selected seats
  void clearSelection() {
    for (var id in _selectedSeatIds.toList()) {
      _findSeatById(id)?.status = SeatStatus.available;
    }
    _selectedSeatIds.clear();
    notifyListeners();
  }

  Seat? _findSeatById(String id) {
    for (var row in _regularSeats) {
      for (var seat in row) {
        if (seat.id == id) return seat;
      }
    }
    for (var row in _vipSeats) {
      for (var seat in row) {
        if (seat.id == id) return seat;
      }
    }
    for (var row in _twinSeats) {
      for (var seat in row) {
        if (seat.id == id) return seat;
      }
    }
    return null;
  }

  /// Reset countdown timer
  void resetCountdown() {
    _remainingSeconds = 120;
    _isSessionExpired = false;
    _countdownTimer?.cancel();
    _startCountdown();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
