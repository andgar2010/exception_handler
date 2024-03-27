// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: prefer_expression_function_bodies, comment_references

import 'dart:async';
import 'dart:isolate';

import 'constants.dart';
import 'isolates.dart' as isolates;

export 'isolates.dart' show ComputeCallback;

/// The dart:io implementation of [isolate.compute].
@pragma('vm:prefer-inline')
Future<R> compute<M, R>(
  final isolates.ComputeCallback<M, R> callback,
  final M message, {
  String? debugLabel,
}) async {
  debugLabel ??= kReleaseMode ? 'compute' : callback.toString();

  return Isolate.run<R>(
    () {
      return callback(message);
    },
    debugName: debugLabel,
  );
}
