cmake_minimum_required(VERSION 3.20.0)

list(PREPEND CMAKE_MODULE_PATH ${ZEPHYR_BASE}/cmake/modules)
include(extensions)

set(binfiles)
foreach(dir dotconfig IN ZIP_LISTS IMAGE_BINARY_DIRS DOTCONFIGS)
  import_kconfig(CONFIG_ ${dotconfig})
  list(APPEND bin_files ${dir}/zephyr/${CONFIG_KERNEL_BIN_NAME}.bin)
endforeach()

execute_process(
      COMMAND
      ${PYTHON_EXECUTABLE}
      ${CMAKE_CURRENT_LIST_DIR}/../scripts/bootloader/generate_zip.py
      --bin-files ${bin_files}
      --output ${OUTPUT}
      --name "${APPNAME}"
      ${META_ARGUMENT}
      ${SCRIPT_PARAMS}
      "type=${TYPE}"
      "board=${BOARD}"
      "soc=${SOC}"
)

