import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomeState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const WelcomeState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  WelcomeState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return WelcomeState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WelcomeController extends StateNotifier<WelcomeState> {
  WelcomeController() : super(const WelcomeState());

  Future<void> handleStartPressed(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      // Simular una carga
      await Future.delayed(const Duration(milliseconds: 1500));

      // Aquí iría la navegación a la siguiente pantalla
      if (context.mounted) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        // );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: error.toString(),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetError() {
    state = state.copyWith(hasError: false, errorMessage: null);
  }
}

final welcomeControllerProvider =
    StateNotifierProvider<WelcomeController, WelcomeState>((ref) {
      return WelcomeController();
    });
