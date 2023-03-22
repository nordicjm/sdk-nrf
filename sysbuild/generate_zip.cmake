cmake_minimum_required(VERSION 3.20.0)

list(PREPEND CMAKE_MODULE_PATH ${ZEPHYR_BASE}/cmake/modules)
include(extensions)

set(current_image 0)
set(binfiles)
foreach(dir dotconfig IN ZIP_LISTS IMAGE_BINARY_DIRS DOTCONFIGS)
  import_kconfig(CONFIG_ ${dotconfig})
  list(APPEND bin_files ${dir}/zephyr/${CONFIG_KERNEL_BIN_NAME}.signed.bin)

  if(current_image EQUAL "0")
    # Application core image
    if(1)
      # Application core image only
      set(generate_script_params "version_MCUBOOT=${CONFIG_MCUBOOT_IMAGE_VERSION}")
    else()
      # Network core image also present
#        "${app_core_binary_name}load_address=$<TARGET_PROPERTY:partition_manager,PM_APP_ADDRESS>"
#        "${app_core_binary_name}image_index=0"
#        "${app_core_binary_name}slot_index_primary=1"
#        "${app_core_binary_name}slot_index_secondary=2"
#        "${app_core_binary_name}version_MCUBOOT=${CONFIG_MCUBOOT_IMAGE_VERSION}"
    endif()
  elseif(current_image EQUAL "1")
    # Network core image
#        "${net_core_binary_name}image_index=1"
#        "${net_core_binary_name}slot_index_primary=3"
#        "${net_core_binary_name}slot_index_secondary=4"
#        "${net_core_binary_name}load_address=$<TARGET_PROPERTY:partition_manager,CPUNET_PM_APP_ADDRESS>"
#        "${net_core_binary_name}board=${CONFIG_DOMAIN_CPUNET_BOARD}"
#        "${net_core_binary_name}version=${net_core_version}"
#        "${net_core_binary_name}soc=${net_core_soc}"
  endif()

  # Increment to next image
  set(current_image "${current_image} ADD 1")
endforeach()

if(META_ARGUMENT)
  set(META_ARGUMENT_PREFIX --meta-info-file)
endif()

execute_process(
      COMMAND
      ${PYTHON_EXECUTABLE}
      ${CMAKE_CURRENT_LIST_DIR}/../scripts/bootloader/generate_zip.py
      --bin-files ${bin_files}
      --output ${OUTPUT}
      --name "${APP_NAME}"
      ${META_ARGUMENT_PREFIX} ${META_ARGUMENT}
      ${SCRIPT_PARAMS} ${generate_script_params}
      "type=${TYPE}"
      "board=${BOARD}"
      "soc=${SOC}"
)

file(WRITE ${MONITOR_FILE}.tmp ${bin_files})
zephyr_file_copy(${MONITOR_FILE}.tmp ${MONITOR_FILE} ONLY_IF_DIFFERENT)
