message(WARNING "yes this does nothing.")
#this should throw an error

get_property(tmpvar GLOBAL PROPERTY somevar)
message(WARNING "pre: ${tmpvar}")
#set(tmpvar "$tmpvarNEW;")
set_property(GLOBAL APPEND PROPERTY somevar "next!")
get_property(tmpvar GLOBAL PROPERTY somevar)
message(WARNING "post: ${tmpvar}")

get_property(tmplist GLOBAL PROPERTY PM_IMAGES)
list(APPEND tmplist "mcuboot")
set_property(GLOBAL PROPERTY PM_IMAGES ${tmplist})


#include(../cmake/partition_manager.cmake)
#include(../CMakeLists.txt)
#add_subdirectory(../)
#add_subdirectory(/tmp/bb/nrf)

set(NRF_DIR ${CMAKE_CURRENT_LIST_DIR}/../ CACHE PATH "NCS root directory")

include(../cmake/extensions.cmake)
include(../cmake/version.cmake)
include(../cmake/multi_image.cmake)
include(../cmake/partition_manager.cmake)
