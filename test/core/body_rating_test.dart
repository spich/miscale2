import 'package:flutter_test/flutter_test.dart';
import 'package:miscale2/core/body/body_metrics.dart';
import 'package:miscale2/core/body/body_rating.dart';

void main() {
  final male = BodyMetrics(
    weightKg: 75.35,
    heightCm: 180,
    age: 36,
    sex: Sex.male,
    impedance: 500,
  );
  final ratings = BodyRatings.of(male);

  group('BodyRatings', () {
    test('svrstava vrijednosti u očekivane raspone', () {
      // mast 20,99 % uz pragove [15, 18, 26, 29] za muškarca od 36 godina
      expect(ratings.fatPercentage.label, 'Normalno');
      expect(ratings.fatPercentage.quality, RatingQuality.good);

      // BMI 23,26
      expect(ratings.bmi.label, 'Normalno');

      // voda 54,20 % uz donju granicu 55 % za muškarce
      expect(ratings.waterPercentage.label, 'Nedostatno');
      expect(ratings.waterPercentage.quality, RatingQuality.low);

      // mišići 56,50 kg uz pragove [49,4, 59,5] za muškarca od 180 cm
      expect(ratings.muscleMass.label, 'Normalno');

      // visceralna mast 11,96 uz pragove [10, 15]
      expect(ratings.visceralFat.label, 'Povišeno');
      expect(ratings.visceralFat.quality, RatingQuality.caution);

      // metabolička dob 29,7 naspram stvarnih 36
      expect(ratings.metabolicAge.label, 'Ispod dobi');
    });

    test('pragovi masti ovise o dobi i spolu', () {
      List<double> thresholdsFor(int age, Sex sex) => BodyRatings.of(
            BodyMetrics(
              weightKg: 70,
              heightCm: 175,
              age: age,
              sex: sex,
              impedance: 500,
            ),
          ).fatPercentage.thresholds;

      expect(thresholdsFor(25, Sex.male), [10, 15, 22, 26]);
      expect(thresholdsFor(60, Sex.male), [21, 22, 29, 33]);
      expect(thresholdsFor(25, Sex.female), [19, 24, 30, 35]);
      expect(
        thresholdsFor(30, Sex.female).first,
        greaterThan(thresholdsFor(30, Sex.male).first),
      );
    });

    test('položaj na traci je unutar pripadajućeg raspona', () {
      const rating = MetricRating(
        value: 22,
        thresholds: [10, 20, 30],
        labels: ['a', 'b', 'c', 'd'],
        qualities: [
          RatingQuality.low,
          RatingQuality.good,
          RatingQuality.caution,
          RatingQuality.bad,
        ],
      );

      expect(rating.bandIndex, 2);
      // treći od četiri raspona -> između 0,5 i 0,75
      expect(rating.position, inInclusiveRange(0.5, 0.75));
    });

    test('vrijednosti izvan svih granica ostaju na rubu trake', () {
      const low = MetricRating(
        value: 0,
        thresholds: [10, 20],
        labels: ['a', 'b', 'c'],
        qualities: [RatingQuality.low, RatingQuality.good, RatingQuality.good],
      );
      const high = MetricRating(
        value: 999,
        thresholds: [10, 20],
        labels: ['a', 'b', 'c'],
        qualities: [RatingQuality.low, RatingQuality.good, RatingQuality.good],
      );

      expect(low.position, inInclusiveRange(0.0, 0.34));
      expect(high.position, inInclusiveRange(0.66, 1.0));
    });

    test('granica bazalnog metabolizma je bazalna, ne dnevna potrošnja', () {
      // 75,35 kg * 22,3 kcal/kg za muškarca od 36 godina
      expect(ratings.basalMetabolicRate.thresholds.single, closeTo(1680.3, 0.1));
      expect(ratings.basalMetabolicRate.label, 'Nisko');
    });
  });
}
