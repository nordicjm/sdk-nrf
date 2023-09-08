#
# Copyright (c) 2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause

#if(SB_CONFIG_SECURE_BOOT)
  if(SB_CONFIG_SECURE_BOOT_NETCORE)
    ExternalZephyrProject_Add(
      APPLICATION b0n
      # ToDo: which sample is used as  secure boot sample in other cases ?
      SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/netboot
      BOARD ${SB_CONFIG_SECURE_BOOT_NETBOOT_BOARD}
    )
    list(APPEND IMAGES "b0n")
    set_target_properties(b0n PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

      # Can we do this in a more clever way ?
      # Should adding of hci_rpmasg be a downstream feature, or could we perhaps
      # overload upstream image adding.
      if(NOT "CPUNET" IN_LIST PM_DOMAINS)
        list(APPEND PM_DOMAINS CPUNET)
      endif()
      list(APPEND PM_CPUNET_IMAGES
          "b0n"
      )
      set(PM_CPUNET_IMAGES
          ${PM_CPUNET_IMAGES}
          PARENT_SCOPE
      )

#    if(SB_CONFIG_SECURE_BOOT_DOMAIN_APP)
#      set(DOMAIN_APP_${SB_CONFIG_SECURE_BOOT_DOMAIN} "${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}" PARENT_SCOPE)
#    endif()
  endif()
  if(SB_CONFIG_SECURE_BOOT_APPCORE)
    ExternalZephyrProject_Add(
      APPLICATION b0
      # ToDo: which sample is used as  secure boot sample in other cases ?
      SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/bootloader
#      BOARD ${SB_CONFIG_SECURE_BOOT_BOARD}
    )
    list(APPEND IMAGES "b0")
    set_target_properties(b0 PROPERTIES
      IMAGE_CONF_SCRIPT ${CMAKE_CURRENT_LIST_DIR}/image_configurations/b0_image_default.cmake
    )

      # Can we do this in a more clever way ?
      # Should adding of hci_rpmasg be a downstream feature, or could we perhaps
      # overload upstream image adding.
      if(NOT "APP" IN_LIST PM_DOMAINS)
        list(APPEND PM_DOMAINS APP)
      endif()
      list(APPEND PM_APP_IMAGES
          "b0"
      )
      set(PM_APP_IMAGES
          ${PM_APP_IMAGES}
          PARENT_SCOPE
      )

    if(SB_CONFIG_SECURE_BOOT_DOMAIN_APP)
      set(DOMAIN_APP_${SB_CONFIG_SECURE_BOOT_DOMAIN} "${SB_CONFIG_SECURE_BOOT_IMAGE_NAME}" PARENT_SCOPE)
    endif()

  if(SB_CONFIG_SECURE_BOOT_BUILD_S1_VARIANT_IMAGE)
    set(image s1_image)

    if(SB_CONFIG_BOOTLOADER_MCUBOOT)
      set(s1_source_image mcuboot)
      set(s1_source_dir ${ZEPHYR_MCUBOOT_MODULE_DIR}/boot/zephyr/)

      # Set corresponding values in s1 variant of mcuboot
      set(${image}_CONFIG_BOOT_SIGNATURE_TYPE_${SB_CONFIG_SIGNATURE_TYPE} y CACHE STRING
          "MCUBOOT signature type" FORCE
      )
      set(${image}_CONFIG_BOOT_SIGNATURE_KEY_FILE
          \"${SB_CONFIG_BOOT_SIGNATURE_KEY_FILE}\" CACHE STRING
          "Signature key file for signing" FORCE
      )
    else()
      set(s1_source_image ${DEFAULT_IMAGE})
      set(s1_source_dir ${APP_DIR})
  endif()

  get_cmake_property(sysbuild_cache CACHE_VARIABLES)
  foreach(var_name ${sysbuild_cache})
    if("${var_name}" MATCHES "^(${s1_source_image}_.*)$")
      string(LENGTH "${s1_source_image}" tmplen)
      string(SUBSTRING "${var_name}" ${tmplen} -1 tmp)
      set(${image}${tmp} "${${var_name}}" CACHE UNINITIALIZED "" FORCE)
    endif()
  endforeach()

ExternalZephyrProject_Add(
  APPLICATION ${image}
  SOURCE_DIR ${s1_source_dir}
#  APP_TYPE MAIN
)
  list(APPEND IMAGES "${image}")
endif()
endif()

set(PM_DOMAINS ${PM_DOMAINS} PARENT_SCOPE)
set(IMAGES     ${IMAGES}     PARENT_SCOPE)
