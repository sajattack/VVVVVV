#
# CMake toolchain file for PSP.
#
# Copyright 2019 - Wally
# Copyright 2020 - Daniel 'dbeef' Zalega

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/")

if (DEFINED PSPDEV)
    # Custom PSPDEV passed as cmake call argument.
else()
    # Determine PSP toolchain installation directory;
    # psp-config binary is guaranteed to be in path after successful installation:
    execute_process(COMMAND bash -c "psp-config --pspdev-path" OUTPUT_VARIABLE PSPDEV OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

# Assert that PSP SDK path is now defined:
if (NOT DEFINED PSPDEV)
    message(FATAL_ERROR "PSPDEV not defined. Make sure psp-config in your path or pass custom \
                        toolchain location via PSPDEV variable in cmake call.")
endif ()

# Set helper variables:
set(PSPSDK ${PSPDEV}/psp/sdk)
set(PSPBIN ${PSPDEV}/bin)
set(PSPCMAKE ${PSPDEV}/psp/share/cmake)

# Basic CMake Declarations
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER ${PSPBIN}/psp-gcc)
set(CMAKE_CXX_COMPILER ${PSPBIN}/psp-g++)
set(CMAKE_FIND_ROOT_PATH "${PSPSDK};${PSPDEV}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Set paths to PSP-specific utilities:
set(MKSFO ${PSPBIN}/mksfo)
set(MKSFOEX ${PSPBIN}/mksfoex)
set(PACK_PBP ${PSPBIN}/pack-pbp)
set(FIXUP ${PSPBIN}/psp-fixup-imports)
set(PRXGEN ${PSPBIN}/psp-prxgen)
set(ENC ${PSPBIN}/PrxEncrypter)
set(STRIP ${PSPBIN}/psp-strip)

# Include directories:
include_directories(${include_directories} ${PSPDEV}/include ${PSPSDK}/include)

add_definitions("-G0")

# Definitions that may be needed to use some libraries:
add_definitions("-D__PSP__")
add_definitions("-DHAVE_OPENGL")
add_definitions("-DPSP_FW_VERSION=500")

# Modify compile flags to change optimization level from O3 to O2
string(REGEX REPLACE "([\\/\\-]O)3" "\\12"
  CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REGEX REPLACE "([\\/\\-]O)3" "\\12"
  CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
string(REGEX REPLACE "([\\/\\-]O)3" "\\12"
  CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
string(REGEX REPLACE "([\\/\\-]O)3" "\\12"
  CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")

link_directories(
    ${PSPSDK}/lib
    ${PSPDEV}/lib
)

set (CMAKE_VERBOSE_MAKEFILE ON)

# Aggregated list of all PSP-specific libraries for convenience.
#set(PSP_LIBRARIES
#    pthread-psp
#    GL
#    z
#    stdc++
#    stdc++
#    pspaudiolib
#    pspaudio
#    m
#    c
#    c
#    pspvfpu
#    pspfpu
#    pspgum
#    pspgu
#    psprtc
#    pspdebug
#    pspdisplay
#    pspge
#    pspctrl
#    pspsdk
#    pspnet
#    pspnet_inet
#    pspnet_apctl
#    pspnet_resolver
#    psputility
#    psppower
#    pspuser
#)
# before pspuser ${PSPSDK}/lib/prxexports.o

SET(
    CMAKE_CXX_STANDARD_LIBRARIES
    "${CMAKE_CXX_STANDARD_LIBRARIES} \
    -lstdc++ \
    -lpspvram \
    -lmikmod \
    -losl \
    -lvorbisidec \
    -logg \
    -lpsphprm \
    -lpthread-psp \
    -lGL \
    -lpspaudiolib \
    -lpspaudio \
    -lm \
    -lg \
    -lc \
    -lpspvfpu \
    -lpspfpu \
    -lpspgum \
    -lpspgu \
    -lpsprtc \
    -lpspdebug \
    -lpspdisplay \
    -lpspge \
    -lpspctrl \
    -lpspsdk \
    -lc \
    -lpspnet \
    -lpspnet_inet \
    -lpspnet_apctl \
    -lpspnet_resolver \
    -lpsputility \
    -lpsppower \
    -lpspuser \
    -lpspkernel \
    -specs=/usr/psp/psp/sdk/lib/prxspecs -Wl,-T/usr/psp/psp/sdk/lib/linkfile.prx,-q \
    /usr/psp/psp/sdk/lib/prxexports.o"
)


# File defining macro outputting PSP-specific EBOOT.PBP out of passed executable target:
#include("${PSPCMAKE}/CreatePBP.cmake")
include(createpbp)

# Helper variable for multi-platform projects to identify current platform:
set(PLATFORM_PSP TRUE BOOL)
