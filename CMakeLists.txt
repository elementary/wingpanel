project (wingpanel)
cmake_minimum_required (VERSION 2.8)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)

#
# Base bits
#

include (GNUInstallDirs)
set (DATADIR ${CMAKE_INSTALL_FULL_DATAROOTDIR})
set (GSETTINGSDIR "${DATADIR}/glib-2.0/schemas/")
set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
set (RELEASE_NAME "Wingpanel")
set (INDICATORS_DIR ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_PROJECT_NAME})
set (VERSION "2.0.1")
set (VERSION_INFO "Stable Release")

add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

# Comment this out to enable C compiler warnings
add_definitions (-w)

option (BUILD_SHARED_LIBS "Switch between shared and static libraries" ON)
option (BUILD_SAMPLE "Build an example that shows how it works" OFF)

if (BUILD_SHARED_LIBS)
  message ("-- Shared libraries enabled")
else ()
  message ("-- Shared libraries disabled")
endif ()

# Do not override library search path, so that indcators can be loaded to even if
# Switchboard is run from the source code tree.
# This is also required by Debian policy,
# see http://wiki.debian.org/RpathIssue for details
set (CMAKE_SKIP_BUILD_RPATH TRUE)

#
# Niceties
#

set (ARCHIVE_NAME ${CMAKE_PROJECT_NAME}-${VERSION})
add_custom_target (dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
add_custom_target (distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install -DGSETTINGS_LOCALINSTALL=ON .. -DCMAKE_MODULE_PATH=/usr/share/cmake
    && make -j8
    && make -j8 install
    && make check
    )
add_dependencies(distcheck dist)

#
# Data
#

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/${CMAKE_PROJECT_NAME}.desktop DESTINATION ${DATADIR}/applications)
add_subdirectory(po)

#
# Wingpanel
#

set (LIB_PACKAGES
  glib-2.0
  gio-2.0
  gee-0.8
  gmodule-2.0
  gtk+-3.0
)

set (LIB_PKG
  glib-2.0>=2.40
  gio-2.0
  gee-0.8
  gmodule-2.0
  gtk+-3.0>=3.14
  libnotify
)
find_package(PkgConfig)

pkg_check_modules (LIB REQUIRED ${LIB_PKG})

set (GLOBAL_VALAC_OPTIONS
  --vapidir=${CMAKE_BINARY_DIR}/lib
  --vapidir=vapi
  --target-glib=2.32
  --thread
)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.24.0" MINIMUM)
include (ValaPrecompile)

add_subdirectory (lib)

set (DEPS_PACKAGES
  ${LIB_NAME}
  ${LIB_PACKAGES} # this is needed until we provide a ${CMAKE_PROJECT_NAME}.deps file
  granite
)

set (DEPS_PKG
  granite
  gala
)

pkg_check_modules (DEPS REQUIRED ${DEPS_PKG} ${LIB_PKG})
set (DEPS_LIBRARIES ${DEPS_LIBRARIES} -lm)

# 'src' and 'plugins' depend on the core library
include_directories (${CMAKE_BINARY_DIR}/lib)
set (DEPS_LIBRARIES ${DEPS_LIBRARIES} ${LIB_NAME})
add_subdirectory (src)

add_subdirectory (wingpanel-interface)

if (BUILD_SAMPLE)
  add_subdirectory (sample)
endif ()

add_subdirectory (schemas)

# uninstall target
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/Uninstall.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake)
