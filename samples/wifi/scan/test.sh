rm -rf * && cmake -GNinja -DBOARD=nrf5340dk_nrf5340_cpuapp -DSHIELD=nrf7002ek -DSNIPPET=nrf70-fw-patch-ext-flash -DAPP_DIR=.. /tmp/bb/zephyr/share/sysbuild/
