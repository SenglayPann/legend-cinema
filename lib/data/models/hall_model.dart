class HallModel {
  final String id;
  final String cinemaId;
  final String screenType;
  final SeatLayout seatLayout;
  final SeatLayout twinSeatLayout;
  final SeatLayout vipSeatLayout;
  final double vipSeatPrice;
  final double seatPrice;
  final double twinSeatPrice;

  HallModel({
    required this.id,
    required this.cinemaId,
    required this.screenType,
    required this.seatLayout,
    required this.twinSeatLayout,
    required this.vipSeatLayout,
    required this.seatPrice,
    required this.vipSeatPrice,
    required this.twinSeatPrice,
  });

  factory HallModel.fromMap(Map<String, dynamic> data, String id) {
    return HallModel(
      id: id,
      cinemaId: data['cinemaId'],
      screenType: data['screenType'] ?? '',
      seatLayout: SeatLayout.fromMap(data['seatLayout'] ?? {}),
      twinSeatLayout: SeatLayout.fromMap(data['twinSeatLayout'] ?? {}),
      vipSeatLayout: SeatLayout.fromMap(data['VipSeatLayout'] ?? {}),
      seatPrice: data['seatPrice'],
      vipSeatPrice: data['vipSeatPrice'],
      twinSeatPrice: data['TwinSeatPrice'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cinemaId': cinemaId,
      'screenType': screenType,
      'seatLayout': seatLayout.toMap(),
      'twinSeatLayout': twinSeatLayout.toMap(),
      'vipSeatLayout': twinSeatLayout.toMap(),
      'seatPrice': seatPrice,
      'vipSeatPrice': vipSeatPrice,
      'twinSeatPrice': twinSeatPrice,
    };
  }
}

class SeatLayout {
  final int numberOfRow;
  final int numberOfColumn;

  SeatLayout({
    required this.numberOfRow,
    required this.numberOfColumn,
  });

  factory SeatLayout.fromMap(Map<String, dynamic> data) {
    return SeatLayout(
      numberOfRow: data['numberOfRow'] ?? 0,
      numberOfColumn: data['numberOfColumn'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberOfRow': numberOfRow,
      'numberOfColumn': numberOfColumn,
    };
  }
}
