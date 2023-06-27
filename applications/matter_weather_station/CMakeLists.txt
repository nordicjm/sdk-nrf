#
# Copyright (c) 2021 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

cmake_minimum_required(VERSION 3.20.0)

################################################################################

# The application uses the configuration/<board> scheme for configuration files.
set(APPLICATION_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/configuration/\${BOARD}")

set(multiprotocol_rpmsg_KCONFIG_ROOT "\\\${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/config/nrfconnect/chip-module/Kconfig.multiprotocol_rpmsg.root")
set(hci_rpmsg_KCONFIG_ROOT "\\\${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/config/nrfconnect/chip-module/Kconfig.hci_rpmsg.root")

if(OVERLAY_CONFIG STREQUAL "overlay-factory_data.conf")
    set(PM_STATIC_YML_FILE ${APPLICATION_CONFIG_DIR}/pm_static_factory_data.yml)
endif()

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(matter-weather-station)

################################################################################

set(COMMON_ROOT ${ZEPHYR_NRF_MODULE_DIR}/samples/matter/common)
set(NLIO_ROOT ${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/third_party/nlio/repo)
include(${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/config/nrfconnect/app/enable-gnu-std.cmake)
include(${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/src/app/chip_data_model.cmake)

# NORDIC SDK APP START
target_include_directories(app PRIVATE
    src
    ${COMMON_ROOT}/src
    ${NLIO_ROOT}/include
    ${ZEPHYR_CONNECTEDHOMEIP_MODULE_DIR}/zzz_generated/app-common
)

target_sources(app PRIVATE
    src/app_task.cpp
    src/main.cpp
    src/battery.cpp
    src/buzzer.cpp
    src/zap-generated/IMClusterCommandHandler.cpp
    src/zap-generated/callback-stub.cpp
    ${COMMON_ROOT}/src/led_widget.cpp
    ${COMMON_ROOT}/src/dfu_over_smp.cpp
    src/mem_init.c
)

if(CONFIG_CHIP_OTA_REQUESTOR OR CONFIG_MCUMGR_TRANSPORT_BT)
    target_sources(app PRIVATE ${COMMON_ROOT}/src/ota_util.cpp)
endif()

if(CONFIG_CHIP_ICD_SUBSCRIPTION_HANDLING)
    target_sources(app PRIVATE ${COMMON_ROOT}/src/icd_util.cpp)
endif()

chip_configure_data_model(app
    INCLUDE_SERVER
    BYPASS_IDL
    GEN_DIR src/zap-generated
    ZAP_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/weather-station.zap
)
# NORDIC SDK APP END

zephyr_code_relocate(FILES
#                     src/main.cpp
                     src/app_task.cpp
                     src/battery.cpp
                     src/buzzer.cpp
                     src/zap-generated/callback-stub.cpp
                     src/zap-generated/IMClusterCommandHandler.cpp
                     LOCATION EXTFLASH_TEXT NOCOPY)

zephyr_code_relocate(FILES
#                     src/main.cpp
                     src/app_task.cpp
                     src/battery.cpp
                     src/buzzer.cpp
                     src/zap-generated/callback-stub.cpp
                     src/zap-generated/IMClusterCommandHandler.cpp
                     LOCATION RAM_DATA)

#zephyr_code_relocate(LIBRARY drivers__ieee802154 LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY drivers__sensor__adxl362 LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY drivers__sensor__bme680 LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY drivers__sensor__bmm150 LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY ..__nrf__lib__dk_buttons_and_leds LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__mgmt LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__smp LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__util LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__img_mgmt LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__os_mgmt LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__zephyr_basic LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__transport LOCATION EXTFLASH_TEXT NOCOPY)
zephyr_code_relocate(LIBRARY ..__nrf__subsys__nfc__lib LOCATION EXTFLASH_TEXT NOCOPY)

#zephyr_code_relocate(LIBRARY drivers__ieee802154 LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY drivers__sensor__adxl362 LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY drivers__sensor__bme680 LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY drivers__sensor__bmm150 LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY ..__nrf__lib__dk_buttons_and_leds LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__mgmt LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__smp LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__util LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__img_mgmt LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__os_mgmt LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__grp__zephyr_basic LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY subsys__mgmt__mcumgr__transport LOCATION RAM_DATA)
zephyr_code_relocate(LIBRARY ..__nrf__subsys__nfc__lib LOCATION RAM_DATA)
