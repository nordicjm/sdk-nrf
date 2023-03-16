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

  set(image_binary_dirs)
  set(dotconfigs)
  foreach(image ${GENZIP_IMAGES})
    ExternalProject_Get_Property(${GENZIP_IMAGES} BINARY_DIR)
    list(APPEND image_binary_dirs ${BINARY_DIR})
    list(APPEND dotconfigs ${BINARY_DIR}/zephyr/.config)
  endforeach()

  set_property(SOURCE ${GENZIP_BIN_FILES} ${dotconfigs} PROPERTY GENERATED TRUE)


  add_custom_command(OUTPUT ${GENZIP_OUTPUT}
      COMMAND ${CMAKE_COMMAND}
      -DZEPHYR_BASE=${ZEPHYR_BASE}
      -DDOTCONFIGS=${dotconfigs}
      -DIMAGE_BINARY_DIRS=${image_binary_dirs}
      -DOUTPUT=${GENZIP_OUTPUT}
      -DAPP_NAME=${GENZIP_APPNAME}
      -DMETA_ARGUMENT=${meta_argument}
      -DSCRIPT_PARAMS=${GENZIP_SCRIPT_PARAMS}
      -DTYPE=${GENZIP_TYPE}
      -DBOARD=${GENZIP_BOARD}
      -DSOC=${GENZIP_SOC}
      -P ${CMAKE_CURRENT_LIST_DIR}/generate_zip.cmake
      DEPENDS ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs}
  )

  add_custom_target(dfu_zip ALL DEPENDS ${GENZIP_OUTPUT})
#  get_filename_component(TARGET_NAME ${GENZIP_OUTPUT} NAME)
#  string(REPLACE "." "_" TARGET_NAME ${TARGET_NAME})
#
#  add_custom_target(
#    ${TARGET_NAME}
#    ALL
#    DEPENDS ${GENZIP_OUTPUT}
#    )
endfunction()
