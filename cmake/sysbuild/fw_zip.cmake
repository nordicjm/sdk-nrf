#
# Copyright (c) 2020-2023 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

function(generate_dfu_zip)
  set(oneValueArgs OUTPUT TYPE TARGET APPNAME SOC BOARD)
  set(multiValueArgs BIN_FILES SCRIPT_PARAMS IMAGES)
  cmake_parse_arguments(GENZIP "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT(
    GENZIP_BIN_FILES AND
    GENZIP_SCRIPT_PARAMS AND
    GENZIP_OUTPUT AND
    GENZIP_TYPE AND
    GENZIP_APPNAME AND
    GENZIP_SOC AND
    GENZIP_BOARD AND
    GENZIP_IMAGES
    ))
    message(FATAL_ERROR "Missing required param")
  endif()

  if(CONFIG_BUILD_OUTPUT_META)
    set(meta_info_file ${PROJECT_BINARY_DIR}/${KERNEL_META_NAME})
    set(meta_argument --meta-info-file ${meta_info_file})
  endif()

  foreach(image ${GENZIP_IMAGES})
    add_custom_command(TARGET ${image} POST_BUILD
      COMMAND
      ${PYTHON_EXECUTABLE}
      ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/generate_zip.py
      --bin-files ${GENZIP_BIN_FILES}
      --output ${GENZIP_OUTPUT}
      --name "${GENZIP_APPNAME}"
      ${meta_argument}
      ${GENZIP_SCRIPT_PARAMS}
      "type=${GENZIP_TYPE}"
      "board=${GENZIP_BOARD}"
      "soc=${GENZIP_SOC}"
      DEPENDS ${meta_info_file} ${GENZIP_BIN_FILES}
      )
  endforeach()

#  get_filename_component(TARGET_NAME ${GENZIP_OUTPUT} NAME)
#  string(REPLACE "." "_" TARGET_NAME ${TARGET_NAME})
#
#  add_custom_target(
#    ${TARGET_NAME}
#    ALL
#    DEPENDS ${GENZIP_OUTPUT}
#    )
endfunction()
