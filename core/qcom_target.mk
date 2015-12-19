# Target-specific configuration

# Populate the qcom hardware variants in the project pathmap.
define ril-set-path-variant
$(call project-set-path-variant,ril,TARGET_RIL_VARIANT,hardware/$(1))
endef
define wlan-set-path-variant
$(call project-set-path-variant,wlan,TARGET_WLAN_VARIANT,hardware/qcom/$(1))
endef
define bt-vendor-set-path-variant
$(call project-set-path-variant,bt-vendor,TARGET_BT_VENDOR_VARIANT,hardware/qcom/$(1))
endef

# Set device-specific HALs into project pathmap
define set-device-specific-path
$(if $(USE_DEVICE_SPECIFIC_$(1)), \
    $(if $(DEVICE_SPECIFIC_$(1)_PATH), \
        $(eval path := $(DEVICE_SPECIFIC_$(1)_PATH)), \
        $(eval path := $(TARGET_DEVICE_DIR)/$(2))), \
    $(eval path := $(3))) \
$(call project-set-path,qcom-$(2),$(strip $(path)))
endef

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    qcom_flags := -DQCOM_HARDWARE
    ifeq ($(filter qsd8k,$(TARGET_BOARD_PLATFORM)),)
        qcom_flags += -DQCOM_BSP
        qcom_flags += -DQTI_BSP

        TARGET_USES_QCOM_BSP := true
    endif

    # Tell HALs that we're compiling an AOSP build with an in-line kernel
    TARGET_COMPILE_WITH_MSM_KERNEL := true

    ifneq ($(filter msm7x27a msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
        ifneq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
            # Enable legacy graphics functions
            qcom_flags += -DQCOM_BSP_LEGACY
        endif
        # Enable legacy audio functions
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            qcom_flags += -DLEGACY_ALSA_AUDIO
        endif
    endif

    TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)
    CLANG_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    CLANG_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)

    # Multiarch needs these too..
    2ND_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    2ND_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)
    2ND_CLANG_TARGET_GLOBAL_CFLAGS += $(qcom_flags)
    2ND_CLANG_TARGET_GLOBAL_CPPFLAGS += $(qcom_flags)

    ifeq ($(QCOM_HARDWARE_VARIANT),)
        ifneq ($(filter msm8610 msm8226 msm8974,$(TARGET_BOARD_PLATFORM)),)
            QCOM_HARDWARE_VARIANT := msm8974
        else
        ifneq ($(filter msm8909 msm8916,$(TARGET_BOARD_PLATFORM)),)
            QCOM_HARDWARE_VARIANT := msm8916
        else
        ifneq ($(filter msm8953 msm8937,$(TARGET_BOARD_PLATFORM)),)
            QCOM_HARDWARE_VARIANT := msm8937
        else
        ifneq ($(filter msm8992 msm8994,$(TARGET_BOARD_PLATFORM)),)
            QCOM_HARDWARE_VARIANT := msm8994
        else
        ifneq ($(filter msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
            QCOM_HARDWARE_VARIANT := msm8960
        else
            QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM)
        endif
        endif
        endif
        endif
        endif
    endif

$(call project-set-path,qcom-audio,hardware/qcom/audio-caf/$(QCOM_HARDWARE_VARIANT))
ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
$(call project-set-path,qcom-display,hardware/qcom/display-legacy)
else
$(call project-set-path,qcom-display,hardware/qcom/display-caf/$(QCOM_HARDWARE_VARIANT))
endif
ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
$(call project-set-path,qcom-media,hardware/qcom/media-legacy)
else
$(call project-set-path,qcom-media,hardware/qcom/media-caf/$(QCOM_HARDWARE_VARIANT))
endif

$(call set-device-specific-path,CAMERA,camera,hardware/qcom/camera)
$(call set-device-specific-path,GPS,gps,hardware/qcom/gps)
$(call set-device-specific-path,SENSORS,sensors,hardware/qcom/sensors)
$(call set-device-specific-path,LOC_API,loc-api,vendor/qcom/opensource/location)

$(call ril-set-path-variant,ril)
$(call wlan-set-path-variant,wlan)
$(call bt-vendor-set-path-variant,bt)

else

# QSD8K doesn't use QCOM_HARDWARE flag
ifneq ($(filter qsd8k,$(TARGET_BOARD_PLATFORM)),)
    QCOM_AUDIO_VARIANT := audio-legacy
    QCOM_GPS_VARIANT := gps-legacy
else
    QCOM_AUDIO_VARIANT := audio
    QCOM_GPS_VARIANT := gps
endif
ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
    QCOM_DISPLAY_VARIANT := display-legacy
    QCOM_MEDIA_VARIANT := media-legacy
else
    QCOM_DISPLAY_VARIANT := display
    QCOM_MEDIA_VARIANT := media
endif

$(call project-set-path,qcom-audio,hardware/qcom/$(QCOM_AUDIO_VARIANT))
$(call project-set-path,qcom-display,hardware/qcom/$(QCOM_DISPLAY_VARIANT))
$(call project-set-path,qcom-media,hardware/qcom/$(QCOM_MEDIA_VARIANT))

ifeq ($(USE_DEVICE_SPECIFIC_CAMERA),true)
    $(call project-set-path,qcom-camera,$(TARGET_DEVICE_DIR)/camera)
else
    $(call project-set-path,CAMERA,hardware/qcom/camera)
endif
$(call project-set-path,GPS,QCOM_GPS_VARIANT)
$(call project-set-path,qcom-sensors,hardware/qcom/sensors)
$(call project-set-path,qcom-loc-api,vendor/qcom/opensource/location)

$(call ril-set-path-variant,ril)
$(call wlan-set-path-variant,wlan)
$(call bt-vendor-set-path-variant,bt)

endif
