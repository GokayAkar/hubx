import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';

part 'paywall_event.dart';
part 'paywall_state.dart';

/// Loads what is on offer and remembers which one the user is looking at.
class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  PaywallBloc(this._repository) : super(const PaywallState()) {
    on<PaywallStarted>(_onStarted);
    on<PaywallProductSelected>(_onProductSelected);
  }

  final PaywallRepository _repository;

  Future<void> _onStarted(
    PaywallStarted event,
    Emitter<PaywallState> emit,
  ) async {
    emit(state.copyWith(status: PaywallStatus.loading));

    try {
      final products = await _repository.fetchProducts();

      emit(
        PaywallState(
          status: PaywallStatus.ready,
          products: products,
          // The longest commitment is the one the design pre-selects, and the
          // one carrying the trial.
          selectedId: products.isEmpty ? null : products.last.id,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PaywallStatus.failed));
    }
  }

  void _onProductSelected(
    PaywallProductSelected event,
    Emitter<PaywallState> emit,
  ) {
    emit(state.copyWith(selectedId: event.productId));
  }
}
