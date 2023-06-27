rm qspi.hex intflash.hex
/opt/zephyr-sdk-0.16.1/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy --output-target=ihex -j "_EXTFLASH_TEXT_SECTION_NAME" zephyr/zephyr.elf qspi.hex
/opt/zephyr-sdk-0.16.1/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy --output-target=ihex -R "_EXTFLASH_TEXT_SECTION_NAME" zephyr/zephyr.elf intflash.hex
/usr/bin/python3.11 /tmp/bb/bootloader/mcuboot/scripts/imgtool.py sign --key /tmp/bb/bootloader/mcuboot/root-rsa-2048.pem --header-size 0x200 --align 4 --version 2.4.0+0 --pad-header --slot-size 0xe0000 /tmp/bb/nrf/applications/matter_weather_station/_AA/intflash.hex /tmp/bb/nrf/applications/matter_weather_station/_AA/intflash_signed.hex
