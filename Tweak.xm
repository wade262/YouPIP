%hook YTPlayerPIPController

- (BOOL)canInvokePictureInPicture {
	return YES;
}

%end

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

/*%hook AVPictureInPictureController

- (BOOL)isPictureInPicturePossible {
	return PIP ? YES : %orig;
}

%end*/

%ctor {
	%init;
}