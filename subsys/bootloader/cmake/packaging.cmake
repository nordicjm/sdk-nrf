  # Code below is partition manager w/ child image support, thus return when
  # sysbuild is used.

  include(${ZEPHYR_BASE}/../nrf/cmake/fw_zip.cmake)
  include(${ZEPHYR_BASE}/../nrf/cmake/dfu_multi_image.cmake)

if (SB_CONFIG_DFU_MULTI_IMAGE_PACKAGE_BUILD)
# IMAGE_IDS 0;1
# IMAGE_PATHS /tmp/bb/nrf/applications/matter_weather_station/_BB/zephyr/app_update.bin;
# /tmp/bb/nrf/applications/matter_weather_station/_BB/zephyr/net_core_app_update.bin
# OUTPUT /tmp/bb/nrf/applications/matter_weather_station/_BB/zephyr/dfu_multi_image.bin

  set(dfu_multi_image_ids)
  set(dfu_multi_image_paths)
  set(dfu_multi_image_targets)

#KERNEL_BIN_NAME
#message(FATAL_ERROR "${DEFAULT_IMAGE}")
#message(FATAL_ERROR "${IMAGES}")
#    sysbuild_get(${slot}_kernel_elf IMAGE ${slot} VAR CONFIG_KERNEL_ELF_NAME KCONFIG)
#
  if(SB_CONFIG_DFU_MULTI_IMAGE_PACKAGE_APP)
    sysbuild_get(${DEFAULT_IMAGE}_image_dir IMAGE ${DEFAULT_IMAGE} VAR APPLICATION_BINARY_DIR CACHE)
    sysbuild_get(${DEFAULT_IMAGE}_kernel_name IMAGE ${DEFAULT_IMAGE} VAR CONFIG_KERNEL_BIN_NAME KCONFIG)

    list(APPEND dfu_multi_image_ids 0)
    list(APPEND dfu_multi_image_paths "${${DEFAULT_IMAGE}_image_dir}/zephyr/${${DEFAULT_IMAGE}_kernel_name}.signed.bin")
    list(APPEND dfu_multi_image_targets ${DEFAULT_IMAGE}_extra_byproducts)
  endif()

  if(SB_CONFIG_DFU_MULTI_IMAGE_PACKAGE_NET)
    list(APPEND dfu_multi_image_ids 1)
    list(APPEND dfu_multi_image_paths "${PROJECT_BINARY_DIR}/signed_by_b0_${DOMAIN_APP_CPUNET}.bin")
    list(APPEND dfu_multi_image_targets ${DOMAIN_APP_CPUNET}_extra_byproducts ${DOMAIN_APP_CPUNET}_signed_kernel_hex_target)
  endif()

#TODO:
  if (SB_CONFIG_DFU_MULTI_IMAGE_PACKAGE_MCUBOOT)
    list(APPEND dfu_multi_image_ids -2 -1)
    list(APPEND dfu_multi_image_paths "${s0_bin_path}" "${s1_bin_path}")
    list(APPEND dfu_multi_image_targets signed_s0_target signed_s1_target)
  endif()

message(WARNING " IMAGE_IDS ${dfu_multi_image_ids} IMAGE_PATHS ${dfu_multi_image_paths} OUTPUT ${PROJECT_BINARY_DIR}/dfu_multi_image.bin")

  dfu_multi_image_package(dfu_multi_image_pkg
    IMAGE_IDS ${dfu_multi_image_ids}
    IMAGE_PATHS ${dfu_multi_image_paths}
    OUTPUT ${PROJECT_BINARY_DIR}/dfu_multi_image.bin
    DEPENDS ${dfu_multi_image_targets}
    )
endif()
