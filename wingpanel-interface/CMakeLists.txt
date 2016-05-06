find_package (PkgConfig)

pkg_check_modules (DEPS REQUIRED gala granite)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})
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
target_link_libraries(${WINGPANELINTERFACE} ${DEPS_LIBRARIES})

include (GNUInstallDirs)
install (TARGETS ${WINGPANELINTERFACE} DESTINATION "${CMAKE_INSTALL_FULL_LIBDIR}/gala/plugins")
