if(SYSBUILD)
  if(CONFIG_MCUBOOT_SIGNATURE_KEY_FILE)
    # Store details for zip firmware generation in cache
    set(PM_ZIP_FW_BIN_FILE  "${PROJECT_BINARY_DIR}/${CONFIG_KERNEL_BIN_NAME}.signed.bin" CACHE STRING "" FORCE)
    set(PM_ZIP_FW_LOAD_OFFSET  "${CONFIG_FLASH_LOAD_OFFSET}" CACHE STRING "" FORCE)
    set(PM_ZIP_FW_VERSION  "${CONFIG_MCUBOOT_IMAGE_VERSION}" CACHE STRING "" FORCE)
  endif()
endif()
