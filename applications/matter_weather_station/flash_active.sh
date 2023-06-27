nrfjprog -f NRF53 --sectorerase --program ./intflash_signed.hex
nrfjprog -f NRF53 --qspisectorerase --program ./qspi.hex --qspiini ../Qspi.ini --verify
nrfjprog -f NRF53 --reset
