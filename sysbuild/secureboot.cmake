#
# Copyright (c) 2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause

get_property(PM_DOMAINS GLOBAL PROPERTY PM_DOMAINS)
if(SB_CONFIG_SECURE_BOOT)
  if(SB_CONFIG_SECURE_BOOT_NETCORE)
    # Calculate the network board target
    string(REPLACE "/" ";" split_board_qualifiers "${BOARD_QUALIFIERS}")
    list(GET split_board_qualifiers 1 target_soc)
    list(GET split_board_qualifiers 2 target_cpucluster)

    set(board_target_netcore "${BOARD}/${target_soc}/${SB_CONFIG_SECURE_BOOT_NETWORK_BOARD_TARGET_CPUCLUSTER}")

    set(target_soc)
    set(target_cpucluster)

    set(secure_boot_source_dir ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/netboot)

    ExternalZephyrProject_Add(
      APPLICATION b0n
      SOURCE_DIR ${secure_boot_source_dir}
      BOARD ${board_target_netcore}
      BOARD_REVISION ${BOARD_REVISION}
      BUILD_ONLY true
    )
    set_target_properties(b0n PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

    if(SB_CONFIG_PARTITION_MANAGER)
      if(NOT "CPUNET" IN_LIST PM_DOMAINS)
        list(APPEND PM_DOMAINS CPUNET)
      endif()

      set_property(GLOBAL APPEND PROPERTY
        PM_CPUNET_IMAGES
        "b0n"
      )
    elseif(SB_CONFIG_NETCORE_APP_UPDATE)
      # PCD requires the offset of the s0 partition which is read from the b0n image, therefore
      # ensure that the b0n image is configured before the main application (including variant if
      # in direct-xip mode) and b0n
      sysbuild_add_dependencies(CONFIGURE ${DEFAULT_IMAGE} b0n)
      sysbuild_add_dependencies(CONFIGURE mcuboot b0n)

      if(SB_CONFIG_MCUBOOT_BUILD_DIRECT_XIP_VARIANT)
        sysbuild_add_dependencies(CONFIGURE mcuboot_secondary_app b0n)
      endif()
    endif()
  endif()

  if(SB_CONFIG_SECURE_BOOT_APPCORE)
    set(secure_boot_source_dir ${ZEPHYR_NRF_MODULE_DIR}/samples/bootloader)

    ExternalZephyrProject_Add(
      APPLICATION b0
      SOURCE_DIR ${secure_boot_source_dir}
      BUILD_ONLY true
    )
    set_target_properties(b0 PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

    if(SB_CONFIG_PARTITION_MANAGER)
      if(NOT "APP" IN_LIST PM_DOMAINS)
        list(APPEND PM_DOMAINS APP)
      endif()
      set_property(GLOBAL APPEND PROPERTY
        PM_APP_IMAGES
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

    if(SB_CONFIG_PARTITION_MANAGER)
      set_property(GLOBAL APPEND PROPERTY
        PM_APP_IMAGES
        "${image}"
      )
    endif()
  endif()
endif()

if(SB_CONFIG_PARTITION_MANAGER)
  set_property(GLOBAL PROPERTY PM_DOMAINS ${PM_DOMAINS})
endif()
