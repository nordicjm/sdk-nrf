#
# Copyright (c) 2022 Nordic Semiconductor ASA
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
#

# This CMakeLists.txt is executed only by the parent application
# and generates the provision.hex file.

set_ifndef(partition_manager_target partition_manager)

if(NCS_SYSBUILD_PARTITION_MANAGER)
  # Get the main app of the domain that secure boot should handle.
if(0)
  if(SB_CONFIG_SECURE_BOOT AND SB_CONFIG_SECURE_BOOT_APPCORE AND SB_CONFIG_BOOTLOADER_MCUBOOT)
    ExternalProject_Get_Property(mcuboot BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE mcuboot VAR APPLICATION_CONFIG_DIR CACHE)
  elseif(DEFINED SB_CONFIG_SECURE_BOOT_DOMAIN)
    get_property(main_app GLOBAL PROPERTY DOMAIN_APP_${SB_CONFIG_SECURE_BOOT_DOMAIN})

    if(NOT main_app)
      message(FATAL_ERROR "Secure boot is enabled on domain ${SB_CONFIG_SECURE_BOOT_DOMAIN}"
                          " but no image is selected for this domain.")
    endif()

    ExternalProject_Get_Property(${main_app} BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${main_app} VAR APPLICATION_CONFIG_DIR CACHE)
  else()
    ExternalProject_Get_Property(${DEFAULT_IMAGE} BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${DEFAULT_IMAGE} VAR APPLICATION_CONFIG_DIR CACHE)
  endif()
  endif()

set(done 0)
set(prefix_name)
if(DO_APP)
  if(SB_CONFIG_SECURE_BOOT AND SB_CONFIG_SECURE_BOOT_APPCORE AND SB_CONFIG_BOOTLOADER_MCUBOOT)
    ExternalProject_Get_Property(mcuboot BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE mcuboot VAR APPLICATION_CONFIG_DIR CACHE)
    set(done 1)
  endif()
set(prefix_name app_)
endif()

if(DO_NET)
  if(SB_CONFIG_SECURE_BOOT AND SB_CONFIG_SECURE_BOOT_NETCORE)
    get_property(main_app GLOBAL PROPERTY DOMAIN_APP_CPUNET)

    if(NOT main_app)
      message(FATAL_ERROR "Secure boot is enabled on domain CPUNET"
                          " but no image is selected for this domain.")
    endif()

    ExternalProject_Get_Property(${main_app} BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${main_app} VAR APPLICATION_CONFIG_DIR CACHE)
set(done 1)
endif()
set(prefix_name net_)
endif()

if(NOT done)
    ExternalProject_Get_Property(${DEFAULT_IMAGE} BINARY_DIR)
    import_kconfig(CONFIG_ ${BINARY_DIR}/zephyr/.config)
    sysbuild_get(APPLICATION_CONFIG_DIR IMAGE ${DEFAULT_IMAGE} VAR APPLICATION_CONFIG_DIR CACHE)
endif()
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

# Build and include hex file containing provisioned data for the bootloader.
set(PROVISION_HEX_NAME     ${prefix_name}_provision.hex)
set(PROVISION_HEX          ${PROJECT_BINARY_DIR}/${PROVISION_HEX_NAME})

if(CONFIG_SECURE_BOOT)
    if (DEFINED CONFIG_SB_MONOTONIC_COUNTER)
      set(monotonic_counter_arg
        --num-counter-slots-version ${CONFIG_SB_NUM_VER_COUNTER_SLOTS})
    endif()

    # Skip signing if MCUBoot is to be booted and its not built from source
    if ((CONFIG_SB_VALIDATE_FW_SIGNATURE OR CONFIG_SB_VALIDATE_FW_HASH) AND
       ((NOT (CONFIG_BOOTLOADER_MCUBOOT AND NOT CONFIG_MCUBOOT_BUILD_STRATEGY_FROM_SOURCE)) OR NCS_SYSBUILD_PARTITION_MANAGER))

      # Input is comma separated string, convert to CMake list type
      string(REPLACE "," ";" PUBLIC_KEY_FILES_LIST "${CONFIG_SB_PUBLIC_KEY_FILES}")

if(NOT wedone)
      include(${CMAKE_CURRENT_LIST_DIR}/debug_keys.cmake)
      include(${CMAKE_CURRENT_LIST_DIR}/sign.cmake)
set(wedone 1)
endif()

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

      set(PROVISION_DEPENDS signature_public_key_file_target)
    endif()

    # Adjustment to be able to load into sysbuild
    if (CONFIG_SOC_NRF5340_CPUNET OR "${domain}" STREQUAL "CPUNET")
      set(s0_arg --s0-addr $<TARGET_PROPERTY:${partition_manager_target},PM_APP_ADDRESS>)
    else()
      set(s0_arg --s0-addr $<TARGET_PROPERTY:${partition_manager_target},PM_S0_ADDRESS>)
      set(s1_arg --s1-addr $<TARGET_PROPERTY:${partition_manager_target},PM_S1_ADDRESS>)
    endif()

    if (CONFIG_SB_DEBUG_NO_VERIFY_HASHES)
      set(no_verify_hashes_arg --no-verify-hashes)
    endif()
endif()

if(NOT SYSBUILD AND CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION)
  set(mcuboot_counters_slots --mcuboot-counters-slots ${CONFIG_MCUBOOT_HW_DOWNGRADE_PREVENTION_COUNTER_SLOTS})
elseif(SYSBUILD AND SB_CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION)
  set(mcuboot_counters_slots --mcuboot-counters-slots ${SB_CONFIG_MCUBOOT_HW_DOWNGRADE_PREVENTION_COUNTER_SLOTS})
endif()

if(CONFIG_SECURE_BOOT)
add_custom_command(
  OUTPUT
  ${PROVISION_HEX}
  COMMAND
  ${PYTHON_EXECUTABLE}
  ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/provision.py
  ${s0_arg}
  ${s1_arg}
  --provision-addr $<TARGET_PROPERTY:${partition_manager_target},PM_PROVISION_ADDRESS>
  ${public_keys_file_arg}
  --output ${PROVISION_HEX}
  --max-size ${CONFIG_PM_PARTITION_SIZE_PROVISION}
  ${monotonic_counter_arg}
  ${no_verify_hashes_arg}
  ${mcuboot_counters_slots}
  DEPENDS
  ${PROVISION_KEY_DEPENDS}
  ${PROVISION_DEPENDS}
  WORKING_DIRECTORY
  ${PROJECT_BINARY_DIR}
  COMMENT
  "Creating data to be provisioned to the Bootloader, storing to ${PROVISION_HEX_NAME}"
  USES_TERMINAL
  )
elseif(CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION OR SB_CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION)
add_custom_command(
  OUTPUT
  ${PROVISION_HEX}
  COMMAND
  ${PYTHON_EXECUTABLE}
  ${ZEPHYR_NRF_MODULE_DIR}/scripts/bootloader/provision.py
  --mcuboot-only
  --provision-addr $<TARGET_PROPERTY:partition_manager,PM_PROVISION_ADDRESS>
  --output ${PROVISION_HEX}
  --max-size ${CONFIG_PM_PARTITION_SIZE_PROVISION}
  ${mcuboot_counters_num}
  ${mcuboot_counters_slots}
  DEPENDS
  ${PROVISION_KEY_DEPENDS}
  WORKING_DIRECTORY
  ${PROJECT_BINARY_DIR}
  COMMENT
  "Creating data to be provisioned to the Bootloader, storing to ${PROVISION_HEX_NAME}"
  USES_TERMINAL
  )
endif()


if(CONFIG_SECURE_BOOT OR CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION OR SB_CONFIG_MCUBOOT_HARDWARE_DOWNGRADE_PREVENTION)
  add_custom_target(
    ${prefix_name}_provision_target
    DEPENDS
    ${PROVISION_HEX}
    ${PROVISION_DEPENDS}
    )

  get_property(
    provision_set
    GLOBAL PROPERTY provision_PM_HEX_FILE SET
    )

  if(NOT provision_set)
    # Set hex file and target for the 'provision' placeholder partition.
    # This includes the hex file (and its corresponding target) to the build.
    set_property(
      GLOBAL PROPERTY
      provision_PM_HEX_FILE
      ${PROVISION_HEX}
      )

    set_property(
      GLOBAL PROPERTY
      provision_PM_TARGET
      provision_target
      )
  endif()
endif()
