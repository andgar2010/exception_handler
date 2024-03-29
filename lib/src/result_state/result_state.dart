// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../exception_state/exception_state.dart';
import '../utils/utils.dart';

/// An sealed base ResultState class
/// to [TModel] represents the different states of result.
sealed class ResultState<TModel> extends CustomEquatable {
  const ResultState();
}

/// Success status with a generic value [TModel].
final class SuccessState<TModel> extends ResultState<TModel> {
  const SuccessState(this.data);

  final TModel data;

  @override
  Map<String, Object?> get namedProps => {'data': data};
}

/// Error status with a specific type of exception.
final class FailureState<TModel> extends ResultState<TModel> {
  const FailureState(this.exception);

  final ExceptionState<TModel> exception;

  @override
  Map<String, Object?> get namedProps => {'exception': exception};
}
