nrfjprog -f NRF53 --program ./signed_by_b0_mcuboot.hex --sectorerase
nrfjprog -f NRF53 --program ./provision.hex --sectorerase
nrfjprog -f NRF53 --program ./b0/zephyr/zephyr.hex --sectorerase
nrfjprog -f NRF53 --program tfm_psa_template/zephyr/zephyr.signed.hex --sectorerase
nrfjprog -f NRF53 --reset
