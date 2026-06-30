//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_secure_storage/FlutterSecureStoragePlugin.h>)
#import <flutter_secure_storage/FlutterSecureStoragePlugin.h>
#else
@import flutter_secure_storage;
#endif

#if __has_include(<posthog_flutter/PosthogFlutterPlugin.h>)
#import <posthog_flutter/PosthogFlutterPlugin.h>
#else
@import posthog_flutter;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterSecureStoragePlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterSecureStoragePlugin"]];
  [PosthogFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"PosthogFlutterPlugin"]];
}

@end
