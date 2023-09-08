#
# Copyright (c) 2022 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

# This CMakeLists.txt is executed only by the parent application
# and generates the provision.hex file.

set_ifndef(partition_manager_target partition_manager)

set(the_keys)

if(NCS_SYSBUILD_PARTITION_MANAGER)
  # Get the main app of the domain that secure boot should handle.
  set(main_app ${DOMAIN_APP_CPUNET})
  ExternalProject_Get_Property(${main_app} BINARY_DIR)
  import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config the_keys)
set(APPLICATION_CONFIG_DIR)
set(APPLICATION_BINARY_DIR)
  sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${main_app} VAR APPLICATION_CONFIG_DIR CACHE)
  sysbuild_get(APPLICATION_BINARY_DIR IMAGE ${main_app} VAR APPLICATION_BINARY_DIR CACHE)
endif()

if (CONFIG_NCS_IS_VARIANT_IMAGE)
  # When building the variant of an image, the configuration of the variant image
  # is identical to the base image, except 'CONFIG_NCS_IS_VARIANT_IMAGE'. This file is
  # included when provisioning, which can be the case for the base
  # image. However, the logic in this file should only be performed once, for
  # the base image, not for the variant variant. Hence, we have this check to avoid
  # execution of this file for the variant image.
  return()
endif()

if(NOT CONFIG_SECURE_BOOT)
  return()
endif()

# Build and include hex file containing provisioned data for the bootloader.
set(PROVISION_HEX_NAME     provision_CPUNET.hex)
set(PROVISION_HEX          ${PROJECT_BINARY_DIR}/${PROVISION_HEX_NAME})


    if (DEFINED CONFIG_SB_MONOTONIC_COUNTER)
      set(monotonic_counter_arg
        --num-counter-slots-version ${CONFIG_SB_NUM_VER_COUNTER_SLOTS})
    endif()

    # Skip signing if MCUBoot is to be booted and its not built from source
    if ((CONFIG_SB_VALIDATE_FW_SIGNATURE OR CONFIG_SB_VALIDATE_FW_HASH) AND
       NCS_SYSBUILD_PARTITION_MANAGER)

      # Input is comma separated string, convert to CMake list type
      string(REPLACE "," ";" PUBLIC_KEY_FILES_LIST "${CONFIG_SB_PUBLIC_KEY_FILES}")

      include(${CMAKE_CURRENT_LIST_DIR}/debug_keys.cmake)
      include(${CMAKE_CURRENT_LIST_DIR}/sign.cmake)

      if (${CONFIG_SB_DEBUG_SIGNATURE_PUBLIC_KEY_LAST})
        message(WARNING
          "
      -----------------------------------------------------------------
      --- WARNING: SB_DEBUG_SIGNATURE_PUBLIC_KEY_LAST is enabled.   ---
      --- This config should only be enabled for testing/debugging. ---
      -----------------------------------------------------------------")
        list(APPEND PUBLIC_KEY_FILES ${SIGNATURE_PUBLIC_KEY_FILE})
      else()
        list(INSERT PUBLIC_KEY_FILES 0 ${SIGNATURE_PUBLIC_KEY_FILE})
      endif()

      # Convert CMake list type back to comma separated string.
      string(REPLACE ";" "," PUBLIC_KEY_FILES "${PUBLIC_KEY_FILES}")

      set(public_keys_file_arg
        --public-key-files "${PUBLIC_KEY_FILES}"
      )

      set(PROVISION_DEPENDS ${main_app}_signature_public_key_file_target)
    endif()

    # Adjustment to be able to load into sysbuild
    set(s0_arg --s0-addr $<TARGET_PROPERTY:${partition_manager_target},PM_APP_ADDRESS>)

    if (CONFIG_SB_DEBUG_NO_VERIFY_HASHES)
      set(no_verify_hashes_arg --no-verify-hashes)
    endif()

add_custom_command(
  OUTPUT
  ${PROVISION_HEX}
  COMMAND
  ${PYTHON_EXECUTABLE}
  ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/provision.py
  ${s0_arg}
  --provision-addr $<TARGET_PROPERTY:${partition_manager_target},PM_PROVISION_ADDRESS>
  ${public_keys_file_arg}
  --output ${PROVISION_HEX}
  --max-size ${CONFIG_PM_PARTITION_SIZE_PROVISION}
  ${monotonic_counter_arg}
  ${no_verify_hashes_arg}
  DEPENDS
  ${PROVISION_KEY_DEPENDS}
  ${PROVISION_DEPENDS}
  WORKING_DIRECTORY
  ${PROJECT_BINARY_DIR}
  COMMENT
  "Creating data to be provisioned to the Bootloader, storing to ${PROVISION_HEX_NAME}"
  USES_TERMINAL
  )

  add_custom_target(
    provision_CPUNET_target
    DEPENDS
    ${PROVISION_HEX}
    ${PROVISION_DEPENDS}
    )

  get_property(
    provision_set
    GLOBAL PROPERTY provision_CPUNET_PM_HEX_FILE SET
    )

  if(NOT provision_set)
    # Set hex file and target for the 'provision' placeholder partition.
    # This includes the hex file (and its corresponding target) to the build.
    set_property(
      GLOBAL PROPERTY
      provision_CPUNET_PM_HEX_FILE
      ${PROVISION_HEX}
      )

    set_property(
      GLOBAL PROPERTY
      provision_CPUNET_PM_TARGET
      provision_CPUNET_target
      )
  endif()

if(the_keys)
foreach(config ${the_keys})
  unset(${config})
endforeach()
endif()
