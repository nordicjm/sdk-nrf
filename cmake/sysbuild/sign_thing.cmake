# not used, for porting purposes only
if(CONFIG_BOOTLOADER_MCUBOOT)
    if (CONFIG_BUILD_S1_VARIANT AND ("${CONFIG_S1_VARIANT_IMAGE_NAME}" STREQUAL "mcuboot"))
      # Secure Boot (B0) is enabled, and we have to build update candidates
      # for both S1 and S0.

      # We need to override some attributes of the parent slot S0/S1.
      # Which contains both the S0/S1 image and the padding/header.
      foreach(parent_slot s0;s1)
        set(slot ${parent_slot}_image)

        # Fetch the target and hex file for the current slot.
        # Note that these hex files are already signed by B0.
        get_property(${slot}_target GLOBAL PROPERTY ${slot}_PM_TARGET)
        get_property(${slot}_hex GLOBAL PROPERTY ${slot}_PM_HEX_FILE)

        # The gap from S0/S1 partition is calculated by partition manager
        # and stored in its target.
        set(slot_offset
          $<TARGET_PROPERTY:partition_manager,${parent_slot}_TO_SECONDARY>)

        set(out_path ${PROJECT_BINARY_DIR}/signed_by_mcuboot_and_b0_${slot})

        sign(
          SIGNED_BIN_FILE_IN ${${slot}_hex}
          SIGNED_HEX_FILE_NAME_PREFIX ${out_path}
          SLOT_SIZE $<TARGET_PROPERTY:partition_manager,PM_MCUBOOT_PRIMARY_SIZE>
          START_ADDRESS_OFFSET ${slot_offset}
          SIGNED_HEX_FILE_OUT signed_hex
          SIGNED_BIN_FILE_OUT signed_bin
          SIGNED_HEX_TEST_FILE_OUT signed_test_hex
          DEPENDS ${${slot}_target} ${${slot}_hex}
          )

        # We now have to override the S0/S1 partition, so use `parent_slot`
        # variable, which is "s0" and "s1" respectively. This to get partition
        # manager to override the implicitly assigned container hex files.

        # Wrapper target for the generated hex file.
        add_custom_target(signed_${parent_slot}_target
          DEPENDS ${signed_hex} ${signed_bin} ${signed_test_hex}
          )

        # Override the container hex file.
        set_property(GLOBAL PROPERTY
          ${parent_slot}_PM_HEX_FILE
          ${signed_hex}
          )

        # Override the container hex file target.
        set_property(GLOBAL PROPERTY
          ${parent_slot}_PM_TARGET
          signed_${parent_slot}_target
          )
      endforeach()

      # Generate zip file with both update candidates
      set(s0_name signed_by_mcuboot_and_b0_s0_image_update.bin)
      set(s0_bin_path ${PROJECT_BINARY_DIR}/${s0_name})
      set(s1_name signed_by_mcuboot_and_b0_s1_image_update.bin)
      set(s1_bin_path ${PROJECT_BINARY_DIR}/${s1_name})

      # Create dependency to ensure explicit build order. This is needed to have
      # a single target represent the state when both s0 and s1 imags are built.
      add_dependencies(
        signed_s1_target
        signed_s0_target
        )

      generate_dfu_zip(
        OUTPUT ${PROJECT_BINARY_DIR}/dfu_mcuboot.zip
        BIN_FILES ${s0_bin_path} ${s1_bin_path}
        TYPE mcuboot
        SCRIPT_PARAMS
        "${s0_name}load_address=$<TARGET_PROPERTY:partition_manager,PM_S0_ADDRESS>"
        "${s1_name}load_address=$<TARGET_PROPERTY:partition_manager,PM_S1_ADDRESS>"
        "version_MCUBOOT=${CONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION}"
        "version_B0=${CONFIG_FW_INFO_FIRMWARE_VERSION}"
        )
    endif()
  endif(CONFIG_SIGN_IMAGES)
endif()
