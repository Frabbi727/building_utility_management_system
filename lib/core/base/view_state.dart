import 'package:equatable/equatable.dart';

sealed class ViewState extends Equatable {
  const ViewState();
  @override
  List<Object?> get props => [];
}

class IdleState extends ViewState {
  const IdleState();
}

class LoadingState extends ViewState {
  const LoadingState();
}

class SuccessState<T> extends ViewState {
  final T data;
  const SuccessState(this.data);
  @override
  List<Object?> get props => [data];
}

class ErrorState extends ViewState {
  final String message;
  const ErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
