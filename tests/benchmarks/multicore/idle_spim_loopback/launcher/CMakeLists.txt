# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.28.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(minimal)

target_sources(app PRIVATE ${ZEPHYR_BASE}/samples/basic/minimal/src/main.c)
