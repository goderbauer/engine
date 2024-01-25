// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterWindowPlugin.h"
#import "FlutterEngine_Internal.h"

@interface MyWindow : NSWindow
@end
@implementation MyWindow
- (BOOL)canBecomeKeyWindow {
  return YES;
}
@end

static NSString* const kChannelName = @"flutter/window";

@interface FlutterWindowPlugin ()
- (instancetype)initWithChannel:(FlutterMethodChannel*)channel engine:(FlutterEngine*)engine;
@end

@implementation FlutterWindowPlugin {
  FlutterMethodChannel* _channel;
  FlutterEngine* _engine;
  NSMutableDictionary<NSNumber*, NSWindow*>* _windows;
}

#pragma mark - Private Methods

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel engine:(FlutterEngine*)engine {
  self = [super init];
  if (self) {
    _channel = channel;
    _engine = engine;
    _windows = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSLog(@">>> method %@", call.method);
  if ([call.method isEqualToString:@"create"]) {
    NSLog(@">>> CREATE");
    NSDictionary* windowSpec = call.arguments;
    NSLog(@">>> windowSpec %@", windowSpec);

    NSWindow* parentWindow = [[NSApplication sharedApplication] mainWindow];
    NSRect parentContentRect = [parentWindow contentRectForFrameRect:parentWindow.frame];
    NSLog(@">>> parentContentRect %@", NSStringFromRect(parentContentRect));
    double height = [windowSpec[@"height"] doubleValue];
    double width = [windowSpec[@"width"] doubleValue];
    double dy = NSMaxY(parentContentRect) - [windowSpec[@"offsetY"] doubleValue] - height;
    double dx = NSMinX(parentContentRect) + [windowSpec[@"offsetX"] doubleValue];
    NSRect graphicsRect = NSMakeRect(dx, dy, width, height);
    NSLog(@">>> rect %@", NSStringFromRect(graphicsRect));

    MyWindow* window = [[MyWindow alloc]
        initWithContentRect:graphicsRect
                  styleMask:NSWindowStyleMaskBorderless
                    //                         NSWindowStyleMaskTitled |
                    //                                                          NSWindowStyleMaskClosable
                    //                                                          |
                    //                                                          NSWindowStyleMaskMiniaturizable
                    //                                                          |
                    //                                                          NSWindowStyleMaskResizable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    NSRect windowFrame = [window frame];
    FlutterViewController* viewController = [[FlutterViewController alloc] initWithEngine:_engine
                                                                                  nibName:nil
                                                                                   bundle:nil];
    [window setContentViewController:viewController];
    [window setFrame:windowFrame display:YES];
    //    [window orderFront:nil];
    [window makeKeyAndOrderFront:self];
    [window setReleasedWhenClosed:NO];  // Do not close entire app when window is closed.
                                        //    [window setTitle:@"Hello"];
                                        //    [window setIgnoresMouseEvents:YES];
    [parentWindow addChildWindow:window ordered:NSWindowAbove];

    _windows[@(viewController.viewId)] = window;
    result(@(viewController.viewId));

    NSLog(@">>> created %lld", viewController.viewId);

  } else if ([call.method isEqualToString:@"dispose"]) {
    FlutterViewId viewId = [call.arguments longLongValue];
    NSWindow* window = _windows[@(viewId)];
    NSLog(@">>> window %@", window);
    [_windows removeObjectForKey:@(viewId)];
    [window close];
    NSLog(@">>> disposed %lld", viewId);
  }
}

#pragma mark - Public Class Methods

+ (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar
                       engine:(nonnull FlutterEngine*)engine {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:kChannelName
                                                              binaryMessenger:registrar.messenger];
  FlutterWindowPlugin* instance = [[FlutterWindowPlugin alloc] initWithChannel:channel
                                                                        engine:engine];
  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar {
  NSLog(@"ERROR CALL TO registerWithRegistrar");
}

@end
