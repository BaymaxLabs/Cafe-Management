// Spec: OrderState
//
// OrderState drives the live orders board — filtering, SLA ticking, completion.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderState', () {
    group('filtering', () {
      test('filter All returns all orders', () {}, skip: 'OrderState not yet built');
      test('filter Breached returns only breached orders', () {}, skip: 'OrderState not yet built');
      test('filter Urgent returns only urgent orders', () {}, skip: 'OrderState not yet built');
      test('filter OnTrack returns only on-track orders', () {}, skip: 'OrderState not yet built');
      test('filter Unassigned returns only unassigned orders', () {}, skip: 'OrderState not yet built');
    });

    group('SLA timer', () {
      test('notifies listeners every tick', () {}, skip: 'OrderState not yet built');
      test('order status updates from onTrack to urgent as time elapses', () {}, skip: 'OrderState not yet built');
      test('order status updates from urgent to breached as time elapses', () {}, skip: 'OrderState not yet built');
    });

    group('completion', () {
      test('markComplete moves order out of active list', () {}, skip: 'OrderState not yet built');
      test('markComplete adds order to completed list', () {}, skip: 'OrderState not yet built');
    });

    group('search', () {
      test('search by order ID filters correctly', () {}, skip: 'OrderState not yet built');
      test('search by table number filters correctly', () {}, skip: 'OrderState not yet built');
    });
  });
}
