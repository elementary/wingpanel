find_package (PkgConfig)

pkg_check_modules (PLUGIN REQUIRED gala granite)

add_definitions (${PLUGIN_CFLAGS})
link_directories (${PLUGIN_LIBRARY_DIRS})
set (WINGPANELINTERFACE "wingpanel-interface")

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.12.0" MINIMUM)

# We need to know which version of the Mutter API is in use
pkg_check_modules(MUTTER320 QUIET libmutter>=3.19)
pkg_check_modules(MUTTER322 QUIET libmutter>=3.21)
pkg_check_modules(MUTTER324 QUIET libmutter-0>=3.23.90)
pkg_check_modules(MUTTER326 QUIET libmutter-1>=3.25.90)
pkg_check_modules(MUTTER328 QUIET libmutter-2>=3.27.91)

set (EXTRA_VALA_FLAGS "")
set (EXTRA_MUTTER_PKS cogl-1.0 clutter-1.0 libmutter)
set (EXTRA_MUTTER_PACKAGES cogl-1.0 clutter-1.0 libmutter)
if (MUTTER320_FOUND)
    set (EXTRA_VALA_FLAGS ${EXTRA_VALA_FLAGS} --define HAS_MUTTER320)
endif ()

if (MUTTER322_FOUND)
    set (EXTRA_VALA_FLAGS ${EXTRA_VALA_FLAGS} --define HAS_MUTTER322)
    set (EXTRA_MUTTER_PKS mutter-cogl-1.0 mutter-cogl-pango-1.0 mutter-cogl-path-1.0 mutter-clutter-1.0 libmutter)
    set (EXTRA_MUTTER_PACKAGES mutter-cogl-1.0 mutter-clutter-1.0)
endif ()

if (MUTTER324_FOUND)
    set (EXTRA_VALA_FLAGS ${EXTRA_VALA_FLAGS} --define HAS_MUTTER320 --define HAS_MUTTER322 --define HAS_MUTTER324)
    set (EXTRA_MUTTER_PKS mutter-cogl-0 mutter-cogl-pango-0 mutter-cogl-path-0 mutter-clutter-0 libmutter-0)
    set (EXTRA_MUTTER_PACKAGES mutter-cogl-0 mutter-clutter-0)
endif ()

if (MUTTER326_FOUND)
    set (EXTRA_VALA_FLAGS ${EXTRA_VALA_FLAGS} --define HAS_MUTTER320 --define HAS_MUTTER322 --define HAS_MUTTER324 --define HAS_MUTTER326)
    set (EXTRA_MUTTER_PKS mutter-cogl-1 mutter-cogl-pango-1 mutter-cogl-path-1 mutter-clutter-1 libmutter-1)
    set (EXTRA_MUTTER_PACKAGES mutter-cogl-1 mutter-clutter-1)
endif ()

if (MUTTER328_FOUND)
    set (EXTRA_VALA_FLAGS ${EXTRA_VALA_FLAGS} --define HAS_MUTTER320 --define HAS_MUTTER322 --define HAS_MUTTER324 --define HAS_MUTTER326 --define HAS_MUTTER328)
    set (EXTRA_MUTTER_PKS mutter-cogl-2 mutter-cogl-pango-2 mutter-cogl-path-2 mutter-clutter-2 libmutter-2)
    set (EXTRA_MUTTER_PACKAGES mutter-cogl-2 mutter-clutter-2)
endif ()

pkg_check_modules (PLUGIN_MUTTER REQUIRED ${EXTRA_MUTTER_PKS})

include (ValaPrecompile)
vala_precompile (VALA_C ${WINGPANELINTERFACE}
  Main.vala
  DBusServer.vala
  BackgroundManager.vala
  FocusManager.vala
  Settings.vala
  Utils.vala
PACKAGES
  gala
  granite
  cogl-fixes
  ${EXTRA_MUTTER_PACKAGES}
OPTIONS
  --thread
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
  ${EXTRA_VALA_FLAGS}
)

add_library (${WINGPANELINTERFACE} MODULE ${VALA_C})
target_link_libraries(${WINGPANELINTERFACE} ${PLUGIN_LIBRARIES} ${PLUGIN_MUTTER_LIBRARIES} m)

# Add -rpath ldflag if libgala is using mutter >= 3.21 to pick up libmutter-*.so
if (MUTTER328_FOUND)
  _pkgconfig_invoke("libmutter-2" MUTTER TYPELIB_DIR "" "--variable=typelibdir")
  set_target_properties(${WINGPANELINTERFACE} PROPERTIES LINK_FLAGS -Wl,-rpath,${MUTTER_TYPELIB_DIR})
elseif (MUTTER326_FOUND)
  _pkgconfig_invoke("libmutter-1" MUTTER TYPELIB_DIR "" "--variable=typelibdir")
  set_target_properties(${WINGPANELINTERFACE} PROPERTIES LINK_FLAGS -Wl,-rpath,${MUTTER_TYPELIB_DIR})
elseif (MUTTER324_FOUND)
  _pkgconfig_invoke("libmutter-0" MUTTER TYPELIB_DIR "" "--variable=typelibdir")
  set_target_properties(${WINGPANELINTERFACE} PROPERTIES LINK_FLAGS -Wl,-rpath,${MUTTER_TYPELIB_DIR})
elseif (MUTTER322_FOUND)
  _pkgconfig_invoke("libmutter" MUTTER TYPELIB_DIR "" "--variable=typelibdir")
  set_target_properties(${WINGPANELINTERFACE} PROPERTIES LINK_FLAGS -Wl,-rpath,${MUTTER_TYPELIB_DIR})
endif ()

install (TARGETS ${WINGPANELINTERFACE} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/gala/plugins)
