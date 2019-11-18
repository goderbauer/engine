// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.engine.systemchannels;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;


import java.nio.ByteOrder;
import java.util.HashMap;
import java.util.Map;
import java.nio.ByteBuffer;

import io.flutter.Log;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.BinaryCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.StandardMethodCodec;


/**
 * TODO(mattcarroll): fill in javadoc for SystemChannel.
 */
public class InstanceStateChannel {
  private static final String TAG = "InstanceStateChannel";

  @NonNull
  public final MethodChannel channel;

  public InstanceStateChannel(@NonNull DartExecutor dartExecutor) {
    this.channel = new MethodChannel(dartExecutor, "flutter/instancestate");
    channel.setMethodCallHandler(handler);
  }

  private byte[] instanceStateFromOS;
  private byte[] instanceStateFromFlutter;

  public byte[] getInstanceState() {
    return instanceStateFromFlutter;
  }

  public void setInstanceState(byte[] buffer) {
    instanceStateFromOS = buffer;
  }

  private final MethodChannel.MethodCallHandler handler = new MethodChannel.MethodCallHandler() {
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
      String method = call.method;
      Log.v(TAG, "Received '" + method + "' message.");
      switch (method) {
        case "get":
          result.success(instanceStateFromOS);
          instanceStateFromOS = null;
          break;
        case "store":
          Log.d(TAG, "gggggg: " + call.arguments.toString());
          instanceStateFromFlutter = (byte[]) call.arguments;
          result.success(null);
          break;
        default:
          result.notImplemented();
          break;
      }
    }
  };

}
