// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterWindowPlugin.h"
#import "FlutterEngine_Internal.h"

#include <map>

static NSString* const kChannelName = @"flutter/window";

@interface DemoView : NSView  // interface of DemoView class
{                             // (subclass of NSView class)
}
// - (void)drawRect:(NSRect)rect;  // instance method interface
@end

@implementation DemoView  // implementation of DemoView class

// #define X(t) (sin(t)+1) * width * 0.5     // macro for X(t)
// #define Y(t) (cos(t)+1) * height * 0.5    // macro for Y(t)

// - (void)drawRect:(NSRect)rect   // instance method implementation
// {
//     double f,g;
//     double const pi = 2 * acos(0.0);

//     int n = 12;                 // number of sides of the polygon

//     // get the size of the application's window and view objects
//     float width  = [self bounds].size.width;
//     float height = [self bounds].size.height;

//     [[NSColor whiteColor] set];   // set the drawing color to white
//     NSRectFill([self bounds]);    // fill the view with white

//     // the following statements trace two polygons with n sides
//     // and connect all of the vertices with lines

//     [[NSColor blackColor] set];   // set the drawing color to black

//     for (f=0; f<2*pi; f+=2*pi/n) {        // draw the fancy pattern
//         for (g=0; g<2*pi; g+=2*pi/n) {
//             NSPoint p1 = NSMakePoint(X(f),Y(f));
//             NSPoint p2 = NSMakePoint(X(g),Y(g));
//             [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
//         }
//     }

// } // end of drawRect: override method
@end  // end of DemoView implementation

@interface FlutterWindowPlugin ()
- (instancetype)initWithChannel:(FlutterMethodChannel*)channel engine:(FlutterEngine*)engine;
@end

@implementation FlutterWindowPlugin {
  FlutterMethodChannel* _channel;
  FlutterEngine* _engine;
}

#pragma mark - Private Methods

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel engine:(FlutterEngine*)engine {
  self = [super init];
  if (self) {
    _channel = channel;
    _engine = engine;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSLog(@">>> method %@", call.method);
  if ([call.method isEqualToString:@"new"]) {
    // dispatch_async(dispatch_get_main_queue(), ^{
    NSRect graphicsRect = NSMakeRect(100.0, 350.0, 844.0, 626.0);
    NSWindow* myWindow = [[NSWindow alloc]
        initWithContentRect:graphicsRect
                  styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask |
                            NSWindowStyleMaskResizable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    [myWindow setTitle:@"Test Test"];

    // NSView   *myView = [[DemoView alloc] initWithFrame:graphicsRect];
    // FlutterView   *myView = [_engine createFlutterView];
    // [myWindow setContentView:myView ];    // set window's view
    FlutterViewController* controller = [[FlutterViewController alloc] initWithEngine:_engine
                                                                              nibName:nil
                                                                               bundle:nil];
    [myWindow setContentViewController:controller];
    [myWindow setFrame:graphicsRect display:YES];

    // [myWindow setDelegate:*myView ];       // set window's delegate
    [myWindow makeKeyAndOrderFront:nil];  // display window
    [_engine updateWindowMetrics:controller.flutterView id:controller.id];
    NSLog(@"New view ID: %@", @(controller.id));
    // });
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
