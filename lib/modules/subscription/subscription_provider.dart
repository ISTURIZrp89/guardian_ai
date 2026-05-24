import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionState {
  final bool isSubscribed;
  final String subscriptionTier;
  final DateTime? expiresAt;
  final List<String> features;

  const SubscriptionState({
    this.isSubscribed = false,
    this.subscriptionTier = 'free',
    this.expiresAt,
    this.features = SubscriptionNotifier._freeFeatures,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    String? subscriptionTier,
    DateTime? expiresAt,
    List<String>? features,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      expiresAt: expiresAt ?? this.expiresAt,
      features: features ?? this.features,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  static const List<String> _freeFeatures = [
    'AI básico',
    '19 calculadoras',
    'Modelos locales',
  ];

  static const List<String> _premiumFeatures = [
    'IA avanzada en nube',
    '19 calculadoras',
    'Modelos premium',
    'Soporte prioritario',
  ];

  Future<void> checkStatus() async {
    // Placeholder for checking subscription status from Firestore or API
  }

  Future<bool> subscribe() async {
    try {
      state = state.copyWith(
        isSubscribed: true,
        subscriptionTier: 'premium',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        features: List.from(_premiumFeatures),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel() async {
    try {
      state = state.copyWith(
        isSubscribed: false,
        subscriptionTier: 'free',
        expiresAt: null,
        features: List.from(_freeFeatures),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
