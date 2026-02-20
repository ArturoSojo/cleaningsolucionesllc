class PriceRange {
  final double min;
  final double max;

  const PriceRange(this.min, this.max);

  String get formatted => '\$${min.toInt()} - \$${max.toInt()}';

  PriceRange operator +(PriceRange other) =>
      PriceRange(min + other.min, max + other.max);

  PriceRange addFlat(double amount) => PriceRange(min + amount, max + amount);
}

enum ApartmentSize {
  small,
  medium1,
  medium2,
  medium3,
  large,
}

enum ServiceType {
  deep,
  weekly,
  biweekly,
  monthly,
}

enum ExtraService {
  makeBeds,
  doLaundry,
  laundryFullService,
  washDishes,
  insideOven,
  insideFridge,
}

class PricingConstants {
  PricingConstants._();

  static const Map<ApartmentSize, Map<ServiceType, PriceRange>> apartmentPrices = {
    ApartmentSize.small: {
      ServiceType.deep: PriceRange(110, 130),
      ServiceType.weekly: PriceRange(80, 95),
      ServiceType.biweekly: PriceRange(95, 110),
      ServiceType.monthly: PriceRange(110, 125),
    },
    ApartmentSize.medium1: {
      ServiceType.deep: PriceRange(120, 150),
      ServiceType.weekly: PriceRange(90, 105),
      ServiceType.biweekly: PriceRange(105, 120),
      ServiceType.monthly: PriceRange(120, 140),
    },
    ApartmentSize.medium2: {
      ServiceType.deep: PriceRange(140, 170),
      ServiceType.weekly: PriceRange(105, 120),
      ServiceType.biweekly: PriceRange(120, 135),
      ServiceType.monthly: PriceRange(135, 155),
    },
    ApartmentSize.medium3: {
      ServiceType.deep: PriceRange(160, 190),
      ServiceType.weekly: PriceRange(120, 140),
      ServiceType.biweekly: PriceRange(140, 160),
      ServiceType.monthly: PriceRange(160, 180),
    },
    ApartmentSize.large: {
      ServiceType.deep: PriceRange(190, 220),
      ServiceType.weekly: PriceRange(140, 165),
      ServiceType.biweekly: PriceRange(165, 190),
      ServiceType.monthly: PriceRange(190, 215),
    },
  };

  static const Map<ExtraService, PriceRange> extraPrices = {
    ExtraService.makeBeds: PriceRange(5, 5),
    ExtraService.doLaundry: PriceRange(20, 25),
    ExtraService.laundryFullService: PriceRange(35, 45),
    ExtraService.washDishes: PriceRange(15, 25),
    ExtraService.insideOven: PriceRange(25, 35),
    ExtraService.insideFridge: PriceRange(25, 35),
  };

  static PriceRange calculateTotal({
    required ApartmentSize size,
    required ServiceType service,
    required List<ExtraService> extras,
    int bedCount = 1,
  }) {
    final base = apartmentPrices[size]![service]!;
    PriceRange total = base;

    for (final extra in extras) {
      if (extra == ExtraService.makeBeds) {
        total = total.addFlat(extraPrices[extra]!.min * bedCount);
      } else {
        total = total + extraPrices[extra]!;
      }
    }

    return total;
  }
}
