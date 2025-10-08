class HallModel {
  final String id;
  final int hallNumber;
  final String screenType;
  final int capacity;
  final SeatLayout seatLayout;

  HallModel({
    required this.id,
    required this.hallNumber,
    required this.screenType,
    required this.capacity,
    required this.seatLayout,
  });

  factory HallModel.fromMap(Map<String, dynamic> data, String id) {
    return HallModel(
      id: id,
      hallNumber: data['hallNumber'] ?? 0,
      screenType: data['screenType'] ?? '',
      capacity: data['capacity'] ?? 0,
      seatLayout: SeatLayout.fromMap(data['seatLayout'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hallNumber': hallNumber,
      'screenType': screenType,
      'capacity': capacity,
      'seatLayout': seatLayout.toMap(),
    };
  }
}

class SeatLayout {
  final List<String> rows;
  final int seatsPerRow;
  final List<String> vipRows;
  final List<String> disabledSeats;

  SeatLayout({
    required this.rows,
    required this.seatsPerRow,
    required this.vipRows,
    required this.disabledSeats,
  });

  factory SeatLayout.fromMap(Map<String, dynamic> data) {
    return SeatLayout(
      rows: List<String>.from(data['rows'] ?? []),
      seatsPerRow: data['seatsPerRow'] ?? 0,
      vipRows: List<String>.from(data['vipRows'] ?? []),
      disabledSeats: List<String>.from(data['disabledSeats'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rows': rows,
      'seatsPerRow': seatsPerRow,
      'vipRows': vipRows,
      'disabledSeats': disabledSeats,
    };
  }
}
