import 'damage_result_model.dart';

class PTIDamageSumary {
  final int sumaryPrice;
  final List<PTIDamageResult> results;

  PTIDamageSumary({
    this.sumaryPrice,
    this.results,
  });

  factory PTIDamageSumary.fromJson(Map<String, dynamic> json) {
    return PTIDamageSumary(
      results: List<PTIDamageResult>.from(
          json["result"].map((x) => PTIDamageResult.fromJson(x))),
      sumaryPrice: json['summary'],
    );
  }
}
