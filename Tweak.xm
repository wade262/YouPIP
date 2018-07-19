BOOL PIP = YES;

%hook YTPlayerPIPController

- (BOOL)canInvokePictureInPicture {
	return PIP ? YES : %orig;
}

%end

%hook MLPIPController

- (BOOL)isPictureInPictureSupported {
	return YES;
}

%end

%hook YTSettings

- (void)setPictureInPictureEnabled:(BOOL)enabled {
	PIP = enabled;
	%orig(enabled);
}

%end

%hook YTIBackgroundOfflineSettingCategoryEntryRenderer

- (BOOL)isBackgroundEnabled {
	return YES;
}

%end

%hook AVPictureInPictureController

- (BOOL)isPictureInPicturePossible {
	return PIP ? YES : %orig;
}

%end

%ctor {
	%init;
}