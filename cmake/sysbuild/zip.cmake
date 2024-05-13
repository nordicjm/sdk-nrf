# Copyright (c) 2020-2023 Nordic Semiconductor ASA
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause

#if(SB_CONFIG_BOOTLOADER_MCUBOOT AND SB_CONFIG_SECURE_BOOT)
if(SB_CONFIG_DFU_ZIP)
  set(bin_files)
  set(zip_names)
  set(signed_targets)

set(CONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION "0.0.0+0")

# Application
set(generate_script_app_params
          "s0_image.binload_address=$<TARGET_PROPERTY:partition_manager,PM_APP_ADDRESS>"
          "s0_image.binimage_index=0"
          "s0_image.binslot_index_primary=1"
          "s0_image.binslot_index_secondary=2"
          "s0_image.binversion_MCUBOOT=${CONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION}"
)
list(APPEND bin_files "${DEFAULT_IMAGE}/zephyr/zephyr.signed.bin")
list(APPEND zip_names "s0_image.bin")
list(APPEND signed_targets ${DEFAULT_IMAGE}_extra_byproducts)

if(SB_CONFIG_SECURE_BOOT_BUILD_S1_VARIANT_IMAGE)
  # Application s1 image
  set(generate_script_app_params
#PM_MCUBOOT_PRIMARY_APP_ADDRESS
            "s1_image.binload_address=$<TARGET_PROPERTY:partition_manager,PM_MCUBOOT_SECONDARY_APP_ADDRESS>"
            "s1_image.binimage_index=0"
            "s1_image.binslot=1"
            "s1_image.binversion_MCUBOOT+XIP=${CONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION}"
  )

  list(APPEND bin_files "s1_image/zephyr/zephyr.signed.bin")
  list(APPEND zip_names "s1_image.bin")
  list(APPEND signed_targets s1_image_extra_byproducts)

          set(generate_script_params
            "load_address=$<TARGET_PROPERTY:partition_manager,PM_APP_ADDRESS>"
            "version_MCUBOOT=${CONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION}"
          )
endif()

if(SB_CONFIG_SUPPORT_NETCORE AND NOT SB_CONFIG_NETCORE_NONE)
  # Network core
  get_property(image_name GLOBAL PROPERTY DOMAIN_APP_CPUNET)
set(generate_script_app_params
        ${generate_script_app_params}
        "cpunet.binimage_index=1"
        "cpunet.binslot_index_primary=3"
        "cpunet.binslot_index_secondary=4"
        "cpunet.binload_address=$<TARGET_PROPERTY:partition_manager,CPUNET_PM_APP_ADDRESS>"
        "cpunet.binboard=${CONFIG_DOMAIN_CPUNET_BOARD}"
        "cpunet.binversion=${net_core_version}"
        "cpunet.binsoc=${net_core_soc}"
        )
  list(APPEND bin_files "${image_name}/zephyr/zephyr.bin")
#  list(APPEND bin_files "${image_name}/zephyr/zephyr.signed.bin")
  list(APPEND zip_names "cpunet.bin")
  list(APPEND signed_targets ${image_name}_extra_byproducts)
endif()

# wifi patch
#if(TODO)
#      # Add nrf70 update file to the existing bin files list before generating the zip file.
#      list(APPEND generate_bin_files
#        ${PROJECT_BINARY_DIR}/${nrf70_binary_name}
#      )
#
#      if(CONFIG_NRF53_UPGRADE_NETWORK_CORE)
#        list(APPEND generate_script_params
#         "${nrf70_binary_name}image_index=2"
#         "${nrf70_binary_name}slot_index_primary=5"
#         "${nrf70_binary_name}slot_index_secondary=6"
#        )
#      else()
#        list(APPEND generate_script_params
#          "${nrf70_binary_name}image_index=1"
#          "${nrf70_binary_name}slot_index_primary=3"
#          "${nrf70_binary_name}slot_index_secondary=4"
#        )
#      endif()
#endif

  if(bin_files)
    sysbuild_get(mcuboot_fw_info_firmware_version IMAGE mcuboot VAR CONFIG_FW_INFO_FIRMWARE_VERSION KCONFIG)

    include(${ZEPHYR_NRF_MODULE_DIR}/cmake/fw_zip.cmake)

    generate_dfu_zip(
      OUTPUT ${PROJECT_BINARY_DIR}/dfu_app.zip
      BIN_FILES ${bin_files}
      ZIP_NAMES ${zip_names}
      TYPE application
      SCRIPT_PARAMS ${generate_script_app_params}
      DEPENDS ${signed_targets}
      )
  endif()

  # Clear temp variables
  set(bin_files)
  set(zip_names)
  set(signed_targets)
endif()
