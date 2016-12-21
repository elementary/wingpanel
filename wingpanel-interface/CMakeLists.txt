find_package (PkgConfig)

pkg_check_modules (PLUGIN REQUIRED gala granite)

add_definitions (${PLUGIN_CFLAGS})
link_directories (${PLUGIN_LIBRARY_DIRS})
set (WINGPANELINTERFACE "wingpanel-interface")

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.12.0" MINIMUM)

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
OPTIONS
  --thread
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
)

add_library (${WINGPANELINTERFACE} MODULE ${VALA_C})
target_link_libraries(${WINGPANELINTERFACE} ${PLUGIN_LIBRARIES})

# Add -rpath ldflag if libgala is using mutter >= 3.21 to pick up libmutter-*.so
pkg_check_modules(MUTTER322 QUIET libmutter>=3.21)
if (MUTTER322_FOUND)
  _pkgconfig_invoke("libmutter" MUTTER TYPELIB_DIR "" "--variable=typelibdir")
  set_target_properties(${WINGPANELINTERFACE} PROPERTIES LINK_FLAGS -Wl,-rpath,${MUTTER_TYPELIB_DIR})
endif ()

install (TARGETS ${WINGPANELINTERFACE} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/gala/plugins)
