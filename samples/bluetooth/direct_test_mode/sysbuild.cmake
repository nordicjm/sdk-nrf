# Note: this does not work, PM fails
# NCSDK-23805

if("${BOARD}" STREQUAL "nrf5340dk_nrf5340_cpunet")
  ExternalZephyrProject_Add(
    APPLICATION remote_shell
    SOURCE_DIR ${ZEPHYR_NRF_MODULE_DIR}/samples/nrf5340/remote_shell
    BOARD nrf5340dk_nrf5340_cpuapp
  )

  # Add remote project
  set_property(GLOBAL APPEND PROPERTY PM_DOMAINS CPUAPP)
  set_property(GLOBAL APPEND PROPERTY PM_CPUAPP_IMAGES remote)
  set_property(GLOBAL PROPERTY DOMAIN_APP_CPUNET remote_shell)
  set(CPUAPP_PM_DOMAIN_DYNAMIC_PARTITION remote_shell CACHE INTERNAL "")

  # Add a dependency so that the remote_shell sample will be built and flashed first
  add_dependencies(direct_test_mode remote_shell)
  # Add dependency so that the remote_shell image is flashed first.
  sysbuild_add_dependencies(FLASH direct_test_mode remote_shell)
endif()
