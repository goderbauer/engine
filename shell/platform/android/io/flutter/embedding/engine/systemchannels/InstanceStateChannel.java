// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.engine.systemchannels;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.nio.ByteBuffer;

import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryCodec;

/**
 * TODO(mattcarroll): fill in javadoc for SystemChannel.
 */
public class InstanceStateChannel {
  private static final String TAG = "InstanceStateChannel";

  public InstanceStateChannel(@NonNull DartExecutor dartExecutor) {
    BasicMessageChannel<ByteBuffer> channel = new BasicMessageChannel<>(dartExecutor, "flutter/instancestate", BinaryCodec.INSTANCE);
    channel.setMessageHandler(handler);
  }

  private byte[] instanceStateFromOS;
  private ByteBuffer instanceStateFromFlutter;

  public byte[] getInstanceState() {
    return instanceStateFromFlutter.array();
  }

  public void setInstanceState(byte[] buffer) {
    instanceStateFromOS = buffer;
  }

  private final BasicMessageChannel.MessageHandler<ByteBuffer> handler = new BasicMessageChannel.MessageHandler<ByteBuffer>() {
    @Override
    public void onMessage(@Nullable ByteBuffer message, @NonNull BasicMessageChannel.Reply<ByteBuffer> reply) {
      instanceStateFromFlutter = message;
      if (instanceStateFromOS != null) {
        ByteBuffer buffer = ByteBuffer.allocateDirect(instanceStateFromOS.length);
        buffer.put(instanceStateFromOS);
        reply.reply(buffer);
        instanceStateFromOS = null;
      } else {
        reply.reply(null);
      }
    }
  };
}
