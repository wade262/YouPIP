@interface GPBExtensionRegistry : NSObject
- (void)addExtension:(id)extension;
@end

@interface GoogleGlobalExtensionRegistry : NSObject
- (GPBExtensionRegistry *)extensionRegistry;
@end

@interface YTIPictureInPictureRendererRoot : NSObject
+ (id)pictureInPictureRenderer;
@end

@interface MLPIPController : NSObject
- (id)initWithPlaceholderPlayerItemResourcePath:(NSString *)placeholderPath;
- (BOOL)isPictureInPictureSupported;
- (void)setGimme:(id)gimme;
@end

@interface MLRemoteStream : NSObject
- (NSURL *)URL;
@end

@interface MLStreamingData : NSObject
- (NSArray <MLRemoteStream *> *)adaptiveStreams;
@end

@interface MLVideo : NSObject
- (MLStreamingData *)streamingData;
@end

@interface YTSingleVideo : NSObject
- (MLVideo *)video;
@end

@interface YTSingleVideoController : NSObject
- (YTSingleVideo *)videoData;
@end

@interface YTPlaybackControllerUIWrapper : NSObject
- (YTSingleVideoController *)activeVideo;
- (YTSingleVideoController *)contentVideo;
@end

@interface YTPlayerView : UIView
- (YTPlaybackControllerUIWrapper *)playerViewDelegate;
@end

@interface GIMMe
- (id)nullableInstanceForType:(id)protocol;
- (id)instanceForType:(id)protocol;
@end

@interface GIMBindingBuilder : NSObject
- (GIMBindingBuilder *)bindType:(Class)type;
- (GIMBindingBuilder *)initializedWith:(id (^)(id))block;
@end

%hook YTIBackgroundOfflineSettingCategoryEntryRenderer

- (BOOL)isBackgroundEnabled {
	return YES;
}

%end

%hook YTBackgroundabilityPolicy

- (void)updateIsBackgroundableByUserSettings {
	%orig;
	MSHookIvar<BOOL>(self, "_backgroundableByUserSettings") = YES;
}

%end

%hook YTIIosMediaHotConfig

- (BOOL)enablePictureInPicture {
	return YES;
}

%end

%hook YTIosMediaHotConfig

- (BOOL)enablePictureInPicture {
	return YES;
}

%end

%hook MLPIPController

- (BOOL)isPictureInPictureSupported {
	return YES;
}

%end

// This is where magic occurs! (cr. @PoomSmart)
// I however would leave the other hooks here just in case
%hook YTAppModule

- (void)configureWithBinder:(GIMBindingBuilder *)binder {
    %orig;
    [[[[binder bindType:NSClassFromString(@"MLPIPController")] retain] autorelease] initializedWith:^(MLPIPController *controller){
        return [controller initWithPlaceholderPlayerItemResourcePath:@"/Library/Application Support/YouPIP/PlaceholderVideo.mp4"];
    }];
}

%end

%group LateHook

%hook YTIPictureInPictureRenderer

- (BOOL)playableInPip {
	return YES;
}

%end

%hook YTIPictureInPictureSupportedRenderers

- (BOOL)hasPictureInPictureRenderer {
    return YES;
}

%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInPictureInPicture {
    return YES;
}

%end

%end

%hook YTSingleVideo

- (BOOL)isPlayableInPictureInPicture {
    return YES;
}

%end

%hook YTBaseInnerTubeService

+ (void)initialize {
    %orig;
    %init(LateHook);
}

%end

%ctor {
    %init;
}