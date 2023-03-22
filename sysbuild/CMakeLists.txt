#
# Copyright (c) 2022-2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

if(SB_CONFIG_BOOTLOADER_MCUBOOT)
  set(${app_name}_CONFIG_BUILD_OUTPUT_META y CACHE STRING
      "Output build meta information"
  )
endif()

# Sysbuild function hooks used by nRF Connect SDK
function(${SYSBUILD_CURRENT_MODULE_NAME}_post_cmake)
  cmake_parse_arguments(POST_CMAKE "" "" "IMAGES" ${ARGN})

  # Run partition manager for each image before running CMake.
  set(domain ${SB_CONFIG_SECURE_BOOT_DOMAIN})
  if(DEFINED domain)
    set(partition_manager_target partition_manager_${domain})
  endif()
  add_subdirectory_ifdef(SB_CONFIG_SECURE_BOOT ${ZEPHYR_NRF_MODULE_DIR}/subsys/bootloader/image secure_bootloader)

  include(${ZEPHYR_NRF_MODULE_DIR}/cmake/extensions.cmake)
  if(SB_CONFIG_PARTITION_MANAGER)
    include(${ZEPHYR_NRF_MODULE_DIR}/cmake/sysbuild/partition_manager.cmake OPTIONAL)
  endif()

  if(SB_CONFIG_BOOTLOADER_MCUBOOT)
    # mcuboot is enabled, a firmware zip of the update files needs to be created
    include(${ZEPHYR_NRF_MODULE_DIR}/sysbuild/packager_postbuild.cmake)
  endif()
endfunction(${SYSBUILD_CURRENT_MODULE_NAME}_post_cmake)

# Enable use of partition manager with sysbuild.
# Consider if this should come through Sysbuild Kconfig flag.
set(NCS_SYSBUILD_PARTITION_MANAGER TRUE PARENT_SCOPE)

include(${CMAKE_CURRENT_LIST_DIR}/extensions.cmake)

if(SB_CONFIG_SECURE_BOOT)
if(SB_CONFIG_SECURE_BOOT_NETCORE)
  add_overlay_config(
    ${SB_CONFIG_NETCORE_HCI_RPMSG_NAME} # ToDo: Create a common Kconfig setting
                                        # which can then default to the exact
                                        # remote image selected, as to work for
                                        # hci, mpsl, thread, etc.
    "${ZEPHYR_NRF_MODULE_DIR}/subsys/bootloader/image/secure_boot.conf"
  )

  add_overlay_config(
    mcuboot
    "${ZEPHYR_NRF_MODULE_DIR}/subsys/pcd/pcd.conf"
  )
endif()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/netcore.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/secureboot.cmake)

# Append extra tools that need to run
list(APPEND SYSBUILD_EXTRA_TOOLS "${ZEPHYR_NRF_MODULE_DIR}/sysbuild/packager")
set(SYSBUILD_EXTRA_TOOLS ${SYSBUILD_EXTRA_TOOLS} PARENT_SCOPE)
