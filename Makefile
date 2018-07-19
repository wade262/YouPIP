TARGET = iphone:11.2:11.0
ARCHS = arm64
PACKAGE_VERSION = 0.0.4.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouPip
YouPip_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 YouTube"