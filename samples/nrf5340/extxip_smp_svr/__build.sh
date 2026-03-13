rm -rf  * && cmake -GNinja -DBOARD=nrf5340dk/nrf5340/cpuapp -DFILE_SUFFIX=no_network_core_directxip -DAPP_DIR=.. -DSB_CONFIG_PARTITION_MANAGER=n ~/PM_MCUBOOT/zephyr/share/sysbuild
