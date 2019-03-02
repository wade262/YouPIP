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

static MLPIPController *pipController = nil;

BOOL hooked = NO;

%hook AVPictureInPictureController

- (void)pictureInPictureProxy:(id)arg1 failedToStartPictureInPictureWithAnimationType:(NSInteger)arg2 error:(NSError *)arg3 {
    if (arg3.code == -1000) {
        return;
    }
    %orig;
}

%end

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

%hook GIMMe

- (id)nullableInstanceForType:(id)protocol {
    if ([[[protocol class] description] isEqualToString:@"MLPIPController"]) {
        if (pipController == nil)
		    pipController = [[NSClassFromString(@"MLPIPController") alloc] init];
        [pipController setGimme:self];
        return [pipController retain];
    }
    return %orig;
}

%end

BOOL override = NO;

%hook MLPIPController

- (BOOL)isPictureInPictureSupported {
	return YES;
}

- (void)initializePictureInPicture {
    override = YES;
    %orig;
    override = NO;
}

%new
- (void)pictureInPictureControllerDidStopPictureInPicture:(id)pictureInPictureController {

}

%end

%hook AVPlayerItem

+ (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
    if (override)
        return %orig([NSURL URLWithString:url.absoluteString]);
    return %orig;
}

%end

%hook YTPlaybackControllerUIWrapper

- (void)playbackController:(id)arg1 didActivateVideo:(YTSingleVideoController *)controller withPlaybackData:(id)arg3 {
    %orig;
    if (controller) {
        YTSingleVideo *video = controller.videoData;
        MLVideo *mlvideo = video.video;
        MLStreamingData *streamingData = mlvideo.streamingData;
        NSURL *url = streamingData.adaptiveStreams[0].URL;
        [pipController setValue:url.absoluteString forKey:@"_placeholderPlayerItemResourcePath"];
    }
}

%end

// YTPlayerView .playerViewDelegate (YTPlaybackControllerUIWrapper) .contentVideo or .activeVideo (YTSingleVideoController)
// .videoData (YTSingleVideo) .video (MLVideo) .streamingData (MLStreamingData) -> adaptiveStreams as array

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

// YTPlayerPIPController
//id d = [[[[[[self valueForKey:@"_singleVideo"] videoData] valueForKey:@"_playbackData"] playerResponse] playerData] playabilityStatus];
// canInvokePictureInPicture

/*%hook GPBMessage

+ (bool)resolveClassMethod:(SEL)method {
    bool orig = %orig;
    NSString *s = NSStringFromSelector(method);
    if ([@"playableInPip" isEqualToString:s] || [@"hasPictureInPictureRenderer" isEqualToString:s]) {
        %init(LateHook);
    }
    return orig;
}

%end*/

// YTInnerTubeExtensionAdditionsAddExtensions()

%hook YTBaseInnerTubeService

+ (void)initialize {
    %orig;
    /*GPBExtensionRegistry *registry = [[objc_getClass("GoogleGlobalExtensionRegistry") class] performSelector:@selector(extensionRegistry)];
    id extension = [NSClassFromString(@"YTIPictureInPictureRendererRoot") pictureInPictureRenderer];
    [registry addExtension:extension];*/
    %init(LateHook);
}

%end

%ctor {
    %init;
}