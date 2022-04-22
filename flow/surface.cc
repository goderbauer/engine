// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "flutter/flow/surface.h"

namespace flutter {

Surface::Surface(int64_t id) : id_(id) {
  FML_LOG(ERROR) << "Surface " << id_ << " " << this;
}

Surface::~Surface() = default;

std::unique_ptr<GLContextResult> Surface::MakeRenderContextCurrent() {
  return std::make_unique<GLContextDefaultResult>(true);
}

bool Surface::ClearRenderContext() {
  return false;
}

bool Surface::AllowsDrawingWhenGpuDisabled() const {
  return true;
}

bool Surface::EnableRasterCache() const {
  return true;
}

int64_t Surface::GetId() const {
  return id_;
}

}  // namespace flutter
