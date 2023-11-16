#
# Copyright (c) 2023 Nordic Semiconductor
#
# SPDX-License-Identifier: LicenseRef-Nordic-5-Clause

# Include hci_ipc if enabled.
get_property(PM_DOMAINS GLOBAL PROPERTY PM_DOMAINS)
if(SB_CONFIG_NETCORE_HCI_IPC)
  ExternalZephyrProject_Add(
    APPLICATION ${SB_CONFIG_NETCORE_HCI_IPC_NAME}
    SOURCE_DIR ${ZEPHYR_BASE}/samples/bluetooth/hci_ipc
    BOARD ${SB_CONFIG_NETCORE_HCI_IPC_BOARD}
  )

  if(NOT "${SB_CONFIG_NETCORE_HCI_IPC_DOMAIN}" IN_LIST PM_DOMAINS)
    list(APPEND PM_DOMAINS ${SB_CONFIG_NETCORE_HCI_IPC_DOMAIN})
  endif()
  set_property(GLOBAL APPEND PROPERTY
               PM_${SB_CONFIG_NETCORE_HCI_IPC_DOMAIN}_IMAGES
               "${SB_CONFIG_NETCORE_HCI_IPC_NAME}"
  )

  if(SB_CONFIG_NETCORE_HCI_IPC_DOMAIN_APP)
    set_property(GLOBAL PROPERTY DOMAIN_APP_${SB_CONFIG_NETCORE_HCI_IPC_DOMAIN}
                 "${SB_CONFIG_NETCORE_HCI_IPC_NAME}"
    )
  endif()
  set(${SB_CONFIG_NETCORE_HCI_IPC_DOMAIN}_PM_DOMAIN_DYNAMIC_PARTITION
      ${SB_CONFIG_NETCORE_HCI_IPC_NAME} CACHE INTERNAL ""
  )
endif()

# Include 802154_rpmsg if enabled.
if(SB_CONFIG_NETCORE_802154_RPMSG)
  ExternalZephyrProject_Add(
    APPLICATION ${SB_CONFIG_NETCORE_802154_RPMSG_NAME}
    SOURCE_DIR ${ZEPHYR_BASE}/samples/boards/nrf/ieee802154/802154_rpmsg
    BOARD ${SB_CONFIG_NETCORE_802154_RPMSG_BOARD}
  )

  if(NOT "${SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN}" IN_LIST PM_DOMAINS)
    list(APPEND PM_DOMAINS ${SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN})
  endif()
  set_property(GLOBAL APPEND PROPERTY
               PM_${SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN}_IMAGES
               "${SB_CONFIG_NETCORE_802154_RPMSG_NAME}"
  )

  if(SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN_APP)
    set_property(GLOBAL PROPERTY DOMAIN_APP_${SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN}
                 "${SB_CONFIG_NETCORE_802154_RPMSG_NAME}"
    )
  endif()
  set(${SB_CONFIG_NETCORE_802154_RPMSG_DOMAIN}_PM_DOMAIN_DYNAMIC_PARTITION
      ${SB_CONFIG_NETCORE_802154_RPMSG_NAME} CACHE INTERNAL ""
  )
endif()

# Include empty_net_core if enabled.
if(SB_CONFIG_NETCORE_EMPTY)
  ExternalZephyrProject_Add(
    APPLICATION ${SB_CONFIG_NETCORE_EMPTY_NAME}
    SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/empty_net_core
    BOARD ${SB_CONFIG_NETCORE_EMPTY_BOARD}
  )

  if(NOT "${SB_CONFIG_NETCORE_EMPTY_DOMAIN}" IN_LIST PM_DOMAINS)
    list(APPEND PM_DOMAINS ${SB_CONFIG_NETCORE_EMPTY_DOMAIN})
  endif()
  set_property(GLOBAL APPEND PROPERTY
               PM_${SB_CONFIG_NETCORE_EMPTY_DOMAIN}_IMAGES
               "${SB_CONFIG_NETCORE_EMPTY_NAME}"
  )

  if(SB_CONFIG_NETCORE_EMPTY_DOMAIN_APP)
    set_property(GLOBAL PROPERTY DOMAIN_APP_${SB_CONFIG_NETCORE_EMPTY_DOMAIN}
                 "${SB_CONFIG_NETCORE_EMPTY_NAME}"
    )
  endif()
  set(${SB_CONFIG_NETCORE_EMPTY_DOMAIN}_PM_DOMAIN_DYNAMIC_PARTITION
      ${SB_CONFIG_NETCORE_EMPTY_NAME} CACHE INTERNAL ""
  )
endif()

set_property(GLOBAL PROPERTY PM_DOMAINS ${PM_DOMAINS})
