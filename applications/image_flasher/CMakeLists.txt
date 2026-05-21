#
# Copyright (c) 2025 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr
  COMPONENTS zephyr_default:boards
  REQUIRED HINTS $ENV{ZEPHYR_BASE}
)

project(image_flasher LANGUAGES NONE)

# Create the runners_yaml_props_target that flash system expects
add_custom_target(runners_yaml_props_target)

# Fetch hex file to flash from sysbuild
zephyr_get(hex_file_to_flash SYSBUILD LOCAL VAR HEX_FILE)
zephyr_get(base_image SYSBUILD LOCAL VAR IMAGE_FLASHER_SPECIFIC_IMAGE)

if(NOT base_image)
  zephyr_get(base_image SYSBUILD GLOBAL VAR IMAGE_FLASHER_DEFAULT_IMAGE)
endif()

# Override the runners.yaml path to use CMAKE_CURRENT_BINARY_DIR/zephyr instead of
# PROJECT_BINARY_DIR, this ensures runners.yaml is generated at <build>/softdevice/zephyr where
# west expects it
set(PROJECT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/zephyr)

# Copy over Kconfig and dts files from the main image
set(base_image_binary_dir ${PROJECT_BINARY_DIR}/../../${base_image}/zephyr)

# No semi-colons are expected in needed Kconfig values so are not protected
file(READ ${base_image_binary_dir}/.config base_image_config)
string(REPLACE "\n" ";" base_image_config "${base_image_config}")
set(image_flasher_config)

foreach(line IN LISTS base_image_config)
  if(line MATCHES "^CONFIG_SOC_SERIES" OR line MATCHES "^CONFIG_SOC_FAMILY" OR line MATCHES "^CONFIG_SOC_NRF" OR line MATCHES "^CONFIG_BOARD_")
    list(APPEND image_flasher_config ${line})
  endif()
endforeach()

string(REPLACE ";" "\n" image_flasher_config "${image_flasher_config}")
file(WRITE ${PROJECT_BINARY_DIR}/.config.new ${image_flasher_config})
zephyr_file_copy(${PROJECT_BINARY_DIR}/.config.new ${PROJECT_BINARY_DIR}/.config
  ONLY_IF_DIFFERENT
)
zephyr_file_copy(${base_image_binary_dir}/edt.pickle ${PROJECT_BINARY_DIR}/edt.pickle
  ONLY_IF_DIFFERENT
)
import_kconfig(CONFIG_ ${PROJECT_BINARY_DIR}/.config)

# Manually include board configuration to enable automatic runners.yaml generation
foreach(dir ${BOARD_DIRECTORIES})
  include(${dir}/board.cmake OPTIONAL)
endforeach()

# Set hex_file property to point to the hex file
set_target_properties(runners_yaml_props_target PROPERTIES
  hex_file "${hex_file_to_flash}"
)

# Include flash support to automatically generate runners.yaml
include(${ZEPHYR_BASE}/cmake/flash/CMakeLists.txt)

# Silent unused variable warnings
set(EXTRA_KCONFIG_TARGETS)
set(FORCED_CONF_FILE)
