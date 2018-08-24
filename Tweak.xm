%hook MLPIPController

- (BOOL)isPictureInPictureSupported {
	return YES;
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

%hook YTIPictureInPictureRenderer

- (BOOL)playableInPip {
	return YES;
}

%end

%hook YTIosMediaHotConfig

- (BOOL)enablePictureInPicture {
	return YES;
}

%end

%ctor {
	%init;
}