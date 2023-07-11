if("${BOARD}" STREQUAL "nrf5340dk_nrf5340_cpuapp")
  ExternalZephyrProject_Add(
    APPLICATION remote
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/remote
    BOARD nrf5340dk_nrf5340_cpunet
  )
  list(APPEND IMAGES "remote")
  list(APPEND PM_DOMAINS "CPUNET")
  list(APPEND PM_CPUNET_IMAGES "remote")
  set(DOMAIN_APP_CPUNET "remote")
  set(CPUNET_PM_DOMAIN_DYNAMIC_PARTITION
      "remote" CACHE INTERNAL ""
  )
endif()
