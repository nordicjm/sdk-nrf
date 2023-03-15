#
# Copyright (c) 2020-2023 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

cmake_minimum_required(VERSION 3.20)
#include(/tmp/bb/zephyr/cmake/modules/extensions.cmake)
#set(zephyr_modules extensions python west root zephyr_module)
set(zephyr_modules extensions python west zephyr_module)
#sysbuild_extensions python west root zephyr_module boards shields sysbuild_kconfig)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE} COMPONENTS ${zephyr_modules})

#include(${ZEPHYR_BASE}/share/sysbuild/cmake/modules/sysbuild_extensions.cmake)

function(load_cache)
  set(single_args IMAGE BINARY_DIR)
  cmake_parse_arguments(LOAD_CACHE "" "${single_args}" "" ${ARGN})

  file(STRINGS "${LOAD_CACHE_BINARY_DIR}/CMakeCache.txt" cache_strings)
  foreach(str ${cache_strings})
    # Using a regex for matching whole 'VAR_NAME:TYPE=VALUE' will strip semi-colons
    # thus resulting in lists to become strings.
    # Therefore we first fetch VAR_NAME and TYPE, and afterwards extract
    # remaining of string into a value that populates the property.
    # This method ensures that both quoted values and ;-separated list stays intact.
    string(REGEX MATCH "([^:]*):([^=]*)=" variable_identifier ${str})
    if(NOT "${variable_identifier}" STREQUAL "")
      string(LENGTH ${variable_identifier} variable_identifier_length)
      string(SUBSTRING "${str}" ${variable_identifier_length} -1 variable_value)
#message(WARNING "-> ${CMAKE_MATCH_1}, ${CMAKE_MATCH_2}, ${variable_value}")
set(CACHE_${CMAKE_MATCH_1} ${variable_value} PARENT_SCOPE)
#      set_property(TARGET ${LOAD_CACHE_IMAGE}_cache APPEND PROPERTY "CACHE:VARIABLES" "${CMAKE_MATCH_1}")
#      set_property(TARGET ${LOAD_CACHE_IMAGE}_cache PROPERTY "${CMAKE_MATCH_1}:TYPE" "${CMAKE_MATCH_2}")
#      set_property(TARGET ${LOAD_CACHE_IMAGE}_cache PROPERTY "${CMAKE_MATCH_1}" "${variable_value}")
    endif()
  endforeach()
endfunction()


#function(generate_dfu_zip2)
#  set(oneValueArgs OUTPUT TYPE TARGET APPNAME SOC BOARD)
#  set(multiValueArgs BIN_FILES SCRIPT_PARAMS IMAGES)
#message(WARNING "wtf ${SCRIPT_PARAMS}")

#  set(oneValueArgs OUTPUT TYPE)
#  set(multiValueArgs SCRIPT_PARAMS IMAGES)
#  cmake_parse_arguments(GENZIP "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

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

#  if(CONFIG_BUILD_OUTPUT_META)
#    set(meta_info_file ${PROJECT_BINARY_DIR}/${KERNEL_META_NAME})
#    set(meta_argument --meta-info-file ${meta_info_file})
#  endif()

  set(dotconfigs)
  set(watchconfigs)
  set(depfiles)
  foreach(image ${GENZIP_IMAGES})
   load_cache(IMAGE ${image} BINARY_DIR ${image})

set(BINARY_DIR ${CACHE_${image}_BINARY_DIR})
    list(APPEND dotconfigs ${BINARY_DIR}/zephyr/.config)
    list(APPEND watchconfigs ${BINARY_DIR}/zephyr/sysbuild.watch)
set(bob)
  import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
set(bob ${CONFIG_KERNEL_BIN_NAME})

    list(APPEND depfiles ${BINARY_DIR}/zephyr/${bob}.signed.bin)
  endforeach()
#message(WARNING "watch: ${watchconfigs}")
#message(WARNING "watch2: ${depfiles}")
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${watchconfigs})

  set_property(SOURCE ${GENZIP_BIN_FILES} ${dotconfigs} ${watchconfigs} PROPERTY GENERATED TRUE)

#message(WARNING "OUTPUT ${GENZIP_OUTPUT}
#      COMMAND
#      ${PYTHON_EXECUTABLE}
#      ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/generate_zip.py
#      --bin-files ${depfiles}
#      --output /tmp/out.zip
#      --name "NA"
#      ${GENZIP_SCRIPT_PARAMS}
#      type=${GENZIP_TYPE}
#      DEPENDS ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs} ${watchconfigs}"
#  )


#  add_custom_command
#OUTPUT ${GENZIP_OUTPUT}
execute_process(
      COMMAND
      ${PYTHON_EXECUTABLE}
      ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/generate_zip.py
#      --bin-files ${GENZIP_BIN_FILES}
      --bin-files ${depfiles}
      --output ${GENZIP_OUTPUT}
#      --name "${GENZIP_APPNAME}"
      --name "NA"
#      ${meta_argument}
      ${GENZIP_SCRIPT_PARAMS}
      "type=${GENZIP_TYPE}"
#      "board=${GENZIP_BOARD}"
#      "soc=${GENZIP_SOC}"
#      DEPENDS ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs} ${watchconfigs}
  )

#message(WARNING "deps: ${meta_info_file} ${GENZIP_IMAGES} ${dotconfigs} ${watchconfigs}")

#  add_custom_target(dfu_zip ALL DEPENDS ${GENZIP_OUTPUT})
#  add_custom_target(dfu_zip ALL)
#  get_filename_component(TARGET_NAME ${GENZIP_OUTPUT} NAME)
#  string(REPLACE "." "_" TARGET_NAME ${TARGET_NAME})
#
#  add_custom_target(
#    ${TARGET_NAME}
#    ALL
#    DEPENDS ${GENZIP_OUTPUT}
#    )
#endfunction()
