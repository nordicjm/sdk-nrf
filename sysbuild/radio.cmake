# Copyright (c) 2022 Nordic Semiconductor
#
# SPDX-License-Identifier: Apache-2.0

# Include hci_rpmsg if enabled.
if(SB_CONFIG_RADIO_HCI_RPMSG)
  # Propagate bootloader and signing settings from this system to the MCUboot and
  # application image build systems.
  if(SB_CONFIG_RADIO_BOOTLOADER_B0N)
    set(${SB_CONFIG_RADIO_HCI_RPMSG_NAME}_CONFIG_BOOTLOADER_MCUBOOT y CACHE STRING
        "B0N is enabled as bootloader" FORCE
    )
    set(${SB_CONFIG_RADIO_HCI_RPMSG_NAME}_CONFIG_MCUBOOT_SIGNATURE_KEY_FILE
        \"${SB_CONFIG_BOOT_SIGNATURE_KEY_FILE}\" CACHE STRING
        "Signature key file for signing" FORCE
    )

    set(${SB_CONFIG_RADIO_HCI_RPMSG_NAME}_CONFIG_ROM_START_OFFSET "0x200" CACHE STRING
        "Flash load offset" FORCE
    )

    # Set corresponding values in mcuboot
    set(mcuboot_CONFIG_BOOT_SIGNATURE_TYPE_${SB_CONFIG_SIGNATURE_TYPE} y CACHE STRING
        "B0N signature type" FORCE
    )
    set(mcuboot_CONFIG_BOOT_SIGNATURE_KEY_FILE
        \"${SB_CONFIG_BOOT_SIGNATURE_KEY_FILE}\" CACHE STRING
        "Signature key file for signing" FORCE
    )
  else()
    set(${SB_CONFIG_RADIO_HCI_RPMSG_NAME}_CONFIG_BOOTLOADER_MCUBOOT n CACHE STRING
        "B0N is disabled as bootloader" FORCE
    )
  endif()

  ExternalZephyrProject_Add(
    APPLICATION ${SB_CONFIG_RADIO_HCI_RPMSG_NAME}
    SOURCE_DIR ${ZEPHYR_BASE}/samples/bluetooth/hci_rpmsg
    BOARD ${SB_CONFIG_RADIO_HCI_RPMSG_BOARD}
  )
  # MCUBoot default configuration is to perform a full chip erase.
  # Placing MCUBoot first in list to ensure it is flashed before other images.
  list(APPEND IMAGES "${SB_CONFIG_RADIO_HCI_RPMSG_NAME}")

  if(NOT "${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN}" IN_LIST PM_DOMAINS)
    list(APPEND PM_DOMAINS ${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN})
  endif()
  list(APPEND PM_${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN}_IMAGES
      "${SB_CONFIG_RADIO_HCI_RPMSG_NAME}"
  )
  set(PM_${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN}_IMAGES
      ${PM_${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN}_IMAGES}
      PARENT_SCOPE
  )

  if(SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN_APP)
    set(DOMAIN_APP_${SB_CONFIG_RADIO_HCI_RPMSG_DOMAIN}
        "${SB_CONFIG_RADIO_HCI_RPMSG_NAME}" PARENT_SCOPE
    )
  endif()
endif()

# Include b0n if enabled.
if(SB_CONFIG_RADIO_BOOTLOADER_B0N)
  ExternalZephyrProject_Add(
    APPLICATION ${SB_CONFIG_RADIO_BOOTLOADER_B0N_NAME}
    SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/netboot
    BOARD ${SB_CONFIG_RADIO_BOOTLOADER_B0N_BOARD}
  )
  list(APPEND IMAGES "${SB_CONFIG_RADIO_BOOTLOADER_B0N_NAME}")

  # Can we do this in a more clever way ?
  # Should adding of hci_rpmasg be a downstream feature, or could we perhaps
  # overload upstream image adding.
  if(NOT "${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN}" IN_LIST PM_DOMAINS)
    list(APPEND PM_DOMAINS ${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN})
  endif()
  list(APPEND PM_${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN}_IMAGES
      "${SB_CONFIG_RADIO_BOOTLOADER_B0N_NAME}"
  )
  set(PM_${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN}_IMAGES
      ${PM_${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN}_IMAGES}
      PARENT_SCOPE
  )

  if(SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN_APP)
    set(DOMAIN_APP_${SB_CONFIG_RADIO_BOOTLOADER_B0N_DOMAIN} "${SB_CONFIG_RADIO_BOOTLOADER_B0N_NAME}" PARENT_SCOPE)
  endif()
endif()

set(PM_DOMAINS ${PM_DOMAINS} PARENT_SCOPE)
set(IMAGES     ${IMAGES}     PARENT_SCOPE)
