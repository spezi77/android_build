# Target-specific configuration

# Populate the qcom hardware variants in the project pathmap.
define qcom-set-path-variant
$(call project-set-path-variant,qcom-$(2),TARGET_QCOM_$(1)_VARIANT,hardware/qcom/$(2))
endef
define ril-set-path-variant
$(call project-set-path-variant,ril,TARGET_RIL_VARIANT,hardware/$(1))
endef
define gps-hal-set-path-variant
$(call project-set-path-variant,gps-hal,TARGET_GPS_HAL_PATH,$(1))
endef
define loc-api-set-path-variant
$(call project-set-path-variant,loc-api,TARGET_LOC_API_PATH,$(1))
endef

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    qcom_flags := -DQCOM_HARDWARE
    qcom_flags += -DQCOM_BSP

    TARGET_USES_QCOM_BSP := true
    TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

    # Enable DirectTrack for legacy targets
    ifneq ($(filter msm7x30 msm8660 msm8960,$(TARGET_BOARD_PLATFORM)),)
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            qcom_flags += -DQCOM_DIRECTTRACK
        endif
        # Enable legacy graphics functions
        qcom_flags += -DQCOM_BSP_LEGACY
    endif

    ifneq ($(filter msm8084,$(TARGET_BOARD_PLATFORM)),)
        #This is for 8084 based platforms
        QCOM_AUDIO_VARIANT := audio-caf/msm8084
        QCOM_DISPLAY_VARIANT := display-caf/msm8084
        QCOM_MEDIA_VARIANT := media-caf/msm8084
    else ifneq ($(filter msm8610 msm8226 msm8974,$(TARGET_BOARD_PLATFORM)),)
        #This is for 8974 based (and B-family) platforms
        QCOM_AUDIO_VARIANT := audio-caf/msm8974
        QCOM_DISPLAY_VARIANT := display-caf/msm8974
        QCOM_MEDIA_VARIANT := media-caf/msm8974
    else
        QCOM_AUDIO_VARIANT := audio-caf/msm8960
        # Enables legacy repos to be handled
        ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
            QCOM_DISPLAY_VARIANT := display-legacy
        else
            QCOM_DISPLAY_VARIANT := display-caf/msm8960
        endif
        ifeq ($(BOARD_USES_LEGACY_QCOM_MEDIA),true)
            QCOM_MEDIA_VARIANT := media-legacy
        else
            QCOM_MEDIA_VARIANT := media-caf/msm8960
        endif
    endif
else
    # QSD8K doesn't use QCOM_HARDWARE flag
    ifneq ($(filter qsd8k,$(TARGET_BOARD_PLATFORM)),)
        QCOM_AUDIO_VARIANT := audio-caf/msm8960
    else
        QCOM_AUDIO_VARIANT := audio
    endif
    ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
        QCOM_DISPLAY_VARIANT := display-legacy
    else
        QCOM_DISPLAY_VARIANT := display
    endif
    ifeq ($(BOARD_USES_LEGACY_QCOM_MEDIA),true)
        QCOM_MEDIA_VARIANT := media-legacy
    else
        QCOM_MEDIA_VARIANT := media
    endif
endif
