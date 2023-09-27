# Note: this does not work, PM fails
# NCSDK-23805
if("${BOARD}" STREQUAL "nrf5340dk_nrf5340_cpunet")
  ExternalZephyrProject_Add(
    APPLICATION remote_shell
    SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/remote_shell
    BOARD nrf5340dk_nrf5340_cpuapp
  )

  list(APPEND IMAGES "remote_shell")
endif()
