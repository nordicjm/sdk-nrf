#
# Copyright (c) 2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause

get_property(PM_DOMAINS GLOBAL PROPERTY PM_DOMAINS)
if(SB_CONFIG_SECURE_BOOT)
  if(SB_CONFIG_SECURE_BOOT_NETCORE)
    set(secure_boot_source_dir ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/netboot)

    ExternalZephyrProject_Add(
#      APPLICATION ${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}
      APPLICATION b0n
      # ToDo: which sample is used as  secure boot sample in other cases ?
      SOURCE_DIR ${secure_boot_source_dir}
      BOARD ${SB_CONFIG_SECURE_BOOT_BOARD}
      BUILD_ONLY true
    )
    set_target_properties(${SB_CONFIG_SECURE_BOOT_IMAGE_NAME} PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

    # Can we do this in a more clever way ?
    # Should adding of hci_rpmasg be a downstream feature, or could we perhaps
    # overload upstream image adding.
#    if(NOT "${SB_CONFIG_SECURE_BOOT_DOMAIN}" IN_LIST PM_DOMAINS)
#      list(APPEND PM_DOMAINS ${SB_CONFIG_SECURE_BOOT_DOMAIN})
    if(NOT "CPUNET" IN_LIST PM_DOMAINS)
      list(APPEND PM_DOMAINS CPUNET)
    endif()
    set_property(GLOBAL APPEND PROPERTY
#        PM_${SB_CONFIG_SECURE_BOOT_DOMAIN}_IMAGES
#        "${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}"
        PM_CPUNET_IMAGES
        "b0n"
    )

    if(SB_CONFIG_SECURE_BOOT_DOMAIN_APP)
      set_property(GLOBAL PROPERTY DOMAIN_APP_CPUNET
                   "b0n"
      )
    endif()
endif()
  if(SB_CONFIG_SECURE_BOOT_APPCORE)
    set(secure_boot_source_dir ${ZEPHYR_NRF_MODULE_DIR}/samples/bootloader)

    ExternalZephyrProject_Add(
#      APPLICATION ${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}
      APPLICATION b0
      # ToDo: which sample is used as  secure boot sample in other cases ?
      SOURCE_DIR ${secure_boot_source_dir}
#      BOARD ${SB_CONFIG_SECURE_BOOT_BOARD}
      BUILD_ONLY true
    )
    set_target_properties(${SB_CONFIG_SECURE_BOOT_IMAGE_NAME} PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

    # Can we do this in a more clever way ?
    # Should adding of hci_rpmasg be a downstream feature, or could we perhaps
    # overload upstream image adding.
#    if(NOT "${SB_CONFIG_SECURE_BOOT_DOMAIN}" IN_LIST PM_DOMAINS)
#      list(APPEND PM_DOMAINS ${SB_CONFIG_SECURE_BOOT_DOMAIN})
    if(NOT "APP" IN_LIST PM_DOMAINS)
      list(APPEND PM_DOMAINS APP)
    endif()
    set_property(GLOBAL APPEND PROPERTY
#        PM_${SB_CONFIG_SECURE_BOOT_DOMAIN}_IMAGES
#        "${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}"
        PM_APP_IMAGES
        "b0"
    )

    if(SB_CONFIG_SECURE_BOOT_DOMAIN_APP)
      set_property(GLOBAL PROPERTY DOMAIN_APP_APP
                   "b0"
      )
    endif()
  endif()

  if(SB_CONFIG_SECURE_BOOT_BUILD_S1_VARIANT_IMAGE)
    set(image s1_image)

    if(SB_CONFIG_BOOTLOADER_MCUBOOT)
      ExternalNcsVariantProject_Add(APPLICATION mcuboot VARIANT ${image})
    else()
      ExternalNcsVariantProject_Add(APPLICATION ${DEFAULT_IMAGE} VARIANT ${image})
    endif()

    set_property(GLOBAL APPEND PROPERTY
        PM_${SB_CONFIG_SECURE_BOOT_DOMAIN}_IMAGES
        "${image}"
    )
  endif()
endif()

set_property(GLOBAL PROPERTY PM_DOMAINS ${PM_DOMAINS})
