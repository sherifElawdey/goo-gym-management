import 'package:flutter_test/flutter_test.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';

void main() {
  test('Subscription remaining days is computed', () {
    final now = DateTime.now();
    final model = Subscription(
      id: '1',
      userId: 'u1',
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 5)),
      amount: 100,
      status: 'active',
    );
    expect(model.remainingDays >= 4, isTrue);
  });
}
