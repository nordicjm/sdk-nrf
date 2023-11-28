#
# Copyright (c) 2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#


# RPU FW patch binaries based on the selected configuration
#if(CONFIG_NRF700X_SYSTEM_MODE)
        set (NRF70_PATCH ${OS_AGNOSTIC_BASE}/fw_bins/default/nrf70.bin)
#elseif (CONFIG_NRF700X_RADIO_TEST)
#        set (NRF70_PATCH ${OS_AGNOSTIC_BASE}/fw_bins/radio_test/nrf70.bin)
#elseif (CONFIG_NRF700X_SCAN_ONLY)
#        set (NRF70_PATCH ${OS_AGNOSTIC_BASE}/fw_bins/scan_only/nrf70.bin)
#else()
#        # Error
#        message(FATAL_ERROR "Unsupported nRF70 patch configuration")
#endif()


set(WIFI_FW_PARTITION_NAME nrf70_wifi_fw)

set(
  WIFI_FW_DATA_HEX
  ${CMAKE_BINARY_DIR}/nrf70.hex
  )

set(WIFI_FW_DATA_ADDRESS $<TARGET_PROPERTY:partition_manager,nrf70_wifi_fw_XIP_ABS_ADDR>)

add_custom_command(
  OUTPUT
  ${WIFI_FW_DATA_HEX}
  DEPENDS
  "${CMAKE_BINARY_DIR}/pm.config"
  COMMAND
  bin2hex.py  --offset ${WIFI_FW_DATA_ADDRESS} ${NRF70_PATCH} ${WIFI_FW_DATA_HEX}
  COMMENT
  "Generating WiFi firmware update data hex file"
  USES_TERMINAL
  )

add_custom_target(
  ${WIFI_FW_PARTITION_NAME}_target
  DEPENDS
  "${WIFI_FW_DATA_HEX}"
  )

set_property(
  GLOBAL PROPERTY
  ${WIFI_FW_PARTITION_NAME}_PM_HEX_FILE
  "${WIFI_FW_DATA_HEX}"
  )

set_property(
  GLOBAL PROPERTY
  ${WIFI_FW_PARTITION_NAME}_PM_TARGET
  ${WIFI_FW_PARTITION_NAME}_target
  )
