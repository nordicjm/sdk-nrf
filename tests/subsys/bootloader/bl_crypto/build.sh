rm -rf * && cmake -GNinja -DBOARD=nrf52840dk_nrf52840 -DAPP_DIR=.. -DSB_CONFIG_SECURE_BOOT=y -DSB_CONFIG_BOOTLOADER_MCUBOOT=y -Dmcuboot_CONFIG_EXT_API_PROVIDE_EXT_API_ATLEAST_OPTIONAL=y /tmp/bb/zephyr/share/sysbuild/
