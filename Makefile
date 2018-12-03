include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NightStand
NightStand_FILES = Tweak.xm NZ9NightStandView.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
