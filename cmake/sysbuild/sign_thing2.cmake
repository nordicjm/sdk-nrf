# Copyright (c) 2020-2023 Nordic Semiconductor ASA
# SPDX-License-Identifier: Apache-2.0

# This file includes extra build system logic that is enabled when
# CONFIG_BOOTLOADER_MCUBOOT=y.
#
# It builds signed binaries using imgtool as a post-processing step
# after zephyr/zephyr.elf is created in the build directory.
#
# Since this file is brought in via include(), we do the work in a
# function to avoid polluting the top-level scope.

#key file from SB
#encryyption file from SB

function(ncs_secure_boot_mcuboot_sign application)
  set(keyfile "${SB_CONFIG_BOOT_SIGNATURE_KEY_FILE}")
#  set(keyfile_enc "${CONFIG_}")

  # Find imgtool. Even though west is installed, imgtool might not be.
  # The user may also have a custom manifest which doesn't include
  # MCUboot.
  #
  # Therefore, go with an explicitly installed imgtool first, falling
  # back on mcuboot/scripts/imgtool.py.
  if(IMGTOOL)
    set(imgtool_path "${IMGTOOL}")
  elseif(DEFINED ZEPHYR_MCUBOOT_MODULE_DIR)
    set(IMGTOOL_PY "${ZEPHYR_MCUBOOT_MODULE_DIR}/scripts/imgtool.py")
    if(EXISTS "${IMGTOOL_PY}")
      set(imgtool_path "${IMGTOOL_PY}")
    endif()
  endif()

  # No imgtool, no signed binaries.
  if(NOT DEFINED imgtool_path)
    message(FATAL_ERROR "Can't sign images for MCUboot: can't find imgtool. To fix, install imgtool with pip3, or add the mcuboot repository to the west manifest and ensure it has a scripts/imgtool.py file.")
    return()
  endif()

    sysbuild_get(application_image_dir IMAGE ${application} VAR APPLICATION_BINARY_DIR CACHE)

message(WARNING "Dir: ${application_image_dir}")

  # Basic 'west sign' command and output format independent arguments.
#  set(west_sign ${WEST} sign --force
#    --tool imgtool
#    --tool-path "${imgtool_path}"
#    --build-dir "${mcuboot_image_dir}")
  set(west_sign ${imgtool_path} sign --version 0.0.0+0 --align 4 --slot-size 0x70000 --pad-header --header-size 0x200)


#set(imgtool_args -- --pad-header --version 1.2.3 --header-size 0x200)

  if(NOT "${keyfile}" STREQUAL "")
    set(imgtool_extra -k "${keyfile}" ${imgtool_extra})
  endif()

  # Extensionless prefix of any output file.
#  set(output ${ZEPHYR_BINARY_DIR}/${KERNEL_NAME})
  set(output ${PROJECT_BINARY_DIR}/signed_by_mcuboot_and_b0_${application})

  # List of additional build byproducts.
  set(byproducts)

  # 'west sign' arguments for confirmed, unconfirmed and encrypted images.
  set(unconfirmed_args)
  set(encrypted_args)

  # Set up .bin outputs.
#  if(CONFIG_BUILD_OUTPUT_BIN)
if(1)
    list(APPEND unconfirmed_args ${application_image_dir}/zephyr/zephyr.bin ${output}.signed.bin)
    list(APPEND byproducts ${output}.signed.bin)
#    zephyr_runner_file(bin ${output}.signed.bin)
#    set(BYPRODUCT_KERNEL_SIGNED_BIN_NAME "${output}.signed.bin"
#        CACHE FILEPATH "Signed kernel bin file" FORCE
#    )

#    if(NOT "${keyfile_enc}" STREQUAL "")
#      list(APPEND encrypted_args --bin --sbin ${output}.signed.encrypted.bin)
#      list(APPEND byproducts ${output}.signed.encrypted.bin)
#      set(BYPRODUCT_KERNEL_SIGNED_ENCRYPTED_BIN_NAME "${output}.signed.encrypted.bin"
#          CACHE FILEPATH "Signed and encrypted kernel bin file" FORCE
#      )
#    endif()

      add_custom_command(
        OUTPUT
        ${output}.signed.bin # Signed hex with IMAGE_MAGIC located at secondary slot

        COMMAND
        # Create version of test update which is located at the secondary slot.
        # Hence, if a programmer is given this hex file, it will flash it
        # to the secondary slot, and upon reboot mcuboot will swap in the
        # contents of the hex file.
    ${west_sign} ${unconfirmed_args} ${imgtool_args}

        DEPENDS
${application}_extra_byproducts
        )
  endif()

  # Set up .hex outputs.
#  if(CONFIG_BUILD_OUTPUT_HEX)
if(1)
    set(unconfirmed_args)
    list(APPEND unconfirmed_args ${application_image_dir}/zephyr/zephyr.hex ${output}.signed.hex)
    list(APPEND byproducts ${output}.signed.hex)
#    zephyr_runner_file(hex ${output}.signed.hex)

      add_custom_command(
        OUTPUT
        ${output}.signed.hex # Signed hex with IMAGE_MAGIC located at secondary slot

        COMMAND
        # Create version of test update which is located at the secondary slot.
        # Hence, if a programmer is given this hex file, it will flash it
        # to the secondary slot, and upon reboot mcuboot will swap in the
        # contents of the hex file.
    ${west_sign} ${unconfirmed_args} ${imgtool_args}

        DEPENDS
${application}_extra_byproducts
        )

#    set(BYPRODUCT_KERNEL_SIGNED_HEX_NAME "${output}.signed.hex"
#        CACHE FILEPATH "Signed kernel hex file" FORCE
#    )

#    if(NOT "${keyfile_enc}" STREQUAL "")
#      list(APPEND encrypted_args --hex --shex ${output}.signed.encrypted.hex)
#      list(APPEND byproducts ${output}.signed.encrypted.hex)
#      set(BYPRODUCT_KERNEL_SIGNED_ENCRYPTED_HEX_NAME "${output}.signed.encrypted.hex"
#          CACHE FILEPATH "Signed and encrypted kernel hex file" FORCE
#      )
#    endif()
  endif()

  # Add the west sign calls and their byproducts to the post-processing
  # steps for zephyr.elf.
  #
  # CMake guarantees that multiple COMMANDs given to
  # add_custom_command() are run in order, so adding the 'west sign'
  # calls to the "extra_post_build_commands" property ensures they run
  # after the commands which generate the unsigned versions.

add_custom_target(magic
      DEPENDS
${output}.signed.hex
${output}.signed.bin
      )

#  set_property(GLOBAL APPEND PROPERTY extra_post_build_commands COMMAND
#    ${west_sign} ${unconfirmed_args} ${imgtool_args})
#  if(confirmed_args)
#    set_property(GLOBAL APPEND PROPERTY extra_post_build_commands COMMAND
#      ${west_sign} ${confirmed_args} ${imgtool_args} --pad --confirm)
#  endif()
#  if(encrypted_args)
#    set_property(GLOBAL APPEND PROPERTY extra_post_build_commands COMMAND
#      ${west_sign} ${encrypted_args} ${imgtool_args} --encrypt "${keyfile_enc}")
#  endif()
#  set_property(GLOBAL APPEND PROPERTY extra_post_build_byproducts ${byproducts})
endfunction()

if(SB_CONFIG_BOOTLOADER_MCUBOOT AND SB_CONFIG_SECURE_BOOT_APPCORE)
#mcuboot
  ncs_secure_boot_mcuboot_sign("mcuboot")

#s1_image
#  ncs_secure_boot_mcuboot_sign("s1_image")
endif()
