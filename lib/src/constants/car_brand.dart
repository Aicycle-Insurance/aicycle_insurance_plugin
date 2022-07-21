/// Các dòng xe hỗ trợ AI detection
enum CarBrandType {
  /// Kia Morning
  kiaMorning,

  /// Toyota Innova
  toyotaInnova,

  /// Toyota Cross
  toyotaCross,

  /// Mazda Cx5
  mazdaCX5,

  /// Toyota Vios
  toyotaVios,
}

class CarBrand {
  CarBrand._();

  static const Map<CarBrandType, int> carBrandIds = {
    CarBrandType.kiaMorning: 1,
    CarBrandType.toyotaInnova: 3,
    CarBrandType.toyotaCross: 4,
    CarBrandType.mazdaCX5: 6,
    CarBrandType.toyotaVios: 5,
  };
  static const Map<CarBrandType, String> carBrandNames = {
    CarBrandType.kiaMorning: 'Kia Morning',
    CarBrandType.toyotaInnova: 'Toyota Innova',
    CarBrandType.toyotaCross: 'Toyota Cross',
    CarBrandType.mazdaCX5: 'Mazda Cx5',
    CarBrandType.toyotaVios: 'Toyota Vios',
  };
}
