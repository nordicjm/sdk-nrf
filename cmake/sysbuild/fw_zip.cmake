#
# Copyright (c) 2020-2023 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

function(generate_dfu_zip2)
  set(oneValueArgs OUTPUT TYPE)
  set(multiValueArgs SCRIPT_PARAMS IMAGES)
  cmake_parse_arguments(GENZIP "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT(
#    GENZIP_BIN_FILES AND
    GENZIP_SCRIPT_PARAMS AND
    GENZIP_OUTPUT AND
    GENZIP_TYPE AND
#    GENZIP_APPNAME AND
#    GENZIP_SOC AND
#    GENZIP_BOARD AND
    GENZIP_IMAGES
    ))
    message(FATAL_ERROR "Missing required param")
  endif()

  set(dotconfigs)
#  set(depfiles)
  foreach(image ${GENZIP_IMAGES})
    ExternalProject_Get_Property(${image} BINARY_DIR)
    list(APPEND dotconfigs ${BINARY_DIR}/zephyr/.config)
#set(bob)

#    list(APPEND depfiles ${BINARY_DIR}/zephyr/${bob}.signed.bin)
  endforeach()
#message(WARNING "watch2: ${depfiles}")
  set_property(SOURCE ${GENZIP_BIN_FILES} ${dotconfigs} ${GENZIP_OUTPUT} PROPERTY GENERATED TRUE)

message(WARNING "deps: ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs}")
add_custom_command(
  OUTPUT ${GENZIP_OUTPUT}
  COMMAND ${CMAKE_COMMAND} -DZEPHYR_BASE=${ZEPHYR_BASE} -DGENZIP_SCRIPT_PARAMS=${GENZIP_SCRIPT_PARAMS} -DGENZIP_OUTPUT=${GENZIP_OUTPUT} -DGENZIP_TYPE=${GENZIP_TYPE} -DGENZIP_IMAGES=${GENZIP_IMAGES}
    -P /tmp/bb/nrf/cmake/sysbuild/fw_zip2.cmake
      DEPENDS ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs}
)
  add_custom_target(dfu_zip ALL DEPENDS ${GENZIP_OUTPUT})
endfunction()
