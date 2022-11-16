#
# Copyright (c) 2022 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

include(${CMAKE_CURRENT_LIST_DIR}/extensions.cmake)

if(SB_CONFIG_BOOTLOADER_MCUBOOT)
  add_overlay_config(
    mcuboot
     ${ZEPHYR_NRF_MODULE_DIR}/subsys/partition_manager/ext_flash_mcuboot_secondary.conf
  )
endif()


if(SB_CONFIG_SECURE_BOOT)
  add_overlay_config(
    ${SB_CONFIG_RADIO_HCI_RPMSG_NAME} # ToDo: Create a common Kconfig setting
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

include(${CMAKE_CURRENT_LIST_DIR}/radio.cmake)
