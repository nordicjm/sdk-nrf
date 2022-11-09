if(SYSBUILD)
  # Store details for zip firmware generation in cache
  set(PM_ZIP_FW_BIN_FILE  "${PROJECT_BINARY_DIR}/${KERNEL_BIN_NAME}" CACHE STRING "" FORCE)
  set(PM_ZIP_FW_LOAD_OFFSET  "${CONFIG_FLASH_LOAD_OFFSET}" CACHE STRING "" FORCE)
#version needed also
endif()
