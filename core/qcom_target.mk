# Target-specific configuration

# Enable DirectTrack on QCOM legacy boards
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)

    TARGET_GLOBAL_CFLAGS += -DQCOM_HARDWARE
    TARGET_GLOBAL_CPPFLAGS += -DQCOM_HARDWARE

    ifeq ($(TARGET_USES_QCOM_BSP),true)
        TARGET_GLOBAL_CFLAGS += -DQCOM_BSP
        TARGET_GLOBAL_CPPFLAGS += -DQCOM_BSP
    endif

    # Enable DirectTrack for legacy targets
    ifneq ($(filter caf caf-bfam legacy,$(TARGET_QCOM_AUDIO_VARIANT)),)
        ifeq ($(BOARD_USES_LEGACY_ALSA_AUDIO),true)
            TARGET_GLOBAL_CFLAGS += -DQCOM_DIRECTTRACK
            TARGET_GLOBAL_CPPFLAGS += -DQCOM_DIRECTTRACK
        endif
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
    $(call ril-set-path-variant,ril)
else
    # QSD8K doesn't use QCOM_HARDWARE flag
    ifneq ($(filter qsd8k,$(TARGET_BOARD_PLATFORM)),)
        QCOM_AUDIO_VARIANT := audio-caf/msm8960
    else
        QCOM_AUDIO_VARIANT := audio
    endif
    ifeq ($(BOARD_USES_LEGACY_QCOM_DISPLAY),true)
        QCOM_DISPLAY_VARIANT := display-legacy
        QCOM_MEDIA_VARIANT := media-legacy
    else
        QCOM_DISPLAY_VARIANT := display
        QCOM_MEDIA_VARIANT := media
    endif
    $(call ril-set-path-variant,ril)
endif
