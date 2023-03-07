#
# Copyright (c) 2023 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

include(${ZEPHYR_NRF_MODULE_DIR}/cmake/sysbuild/fw_zip.cmake)
include(${ZEPHYR_NRF_MODULE_DIR}/cmake/dfu_multi_image.cmake)

# Fetch Kconfig values from default image
set(app_core_binary_name)
set(app_core_version)
set(app_core_soc)
sysbuild_get(app_core_binary_name IMAGE ${DEFAULT_IMAGE} VAR CONFIG_KERNEL_BIN_NAME KCONFIG)
sysbuild_get(app_core_version IMAGE ${DEFAULT_IMAGE} VAR CONFIG_MCUBOOT_IMAGE_VERSION KCONFIG)
sysbuild_get(app_core_soc IMAGE ${DEFAULT_IMAGE} VAR CONFIG_SOC KCONFIG)
set(app_core_binary_name ${app_core_binary_name}.signed.bin)

if(0)
  # TODO
else()
  # No network core update
  set(generate_bin_files
    ${CMAKE_BINARY_DIR}/${DEFAULT_IMAGE}/zephyr/${app_core_binary_name}
    )
  set(generate_script_params
    "load_address=$<TARGET_PROPERTY:partition_manager,PM_APP_ADDRESS>"
    "version_MCUBOOT=${app_core_version}"
    )
endif()

generate_dfu_zip(
  OUTPUT ${PROJECT_BINARY_DIR}/dfu_application.zip
  BIN_FILES ${generate_bin_files}
  TYPE application
  SCRIPT_PARAMS ${generate_script_params}
  APPNAME ${DEFAULT_IMAGE}
  SOC ${app_core_soc}
  BOARD ${BOARD}
  IMAGES ${DEFAULT_IMAGE}
  )
