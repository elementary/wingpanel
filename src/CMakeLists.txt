set(CLIENT_SOURCE
  Wingpanel.vala
  PanelWindow.vala
  Widgets/IndicatorEntry.vala
  Widgets/IndicatorMenuBar.vala
  Widgets/IndicatorPopover.vala
  Widgets/MenuBar.vala
  Widgets/Panel.vala
  Widgets/StyleClass.vala
  Services/IndicatorSorter.vala
  Services/PopoverManager.vala
  Services/Settings.vala
  Services/BackgroundManager.vala
)

vala_precompile (CLIENT_VALA_C ${CMAKE_PROJECT_NAME}
  ${CLIENT_SOURCE}
  PACKAGES
  ${DEPS_PACKAGES}
  OPTIONS
  ${GLOBAL_VALAC_OPTIONS}
)

set (EXEC_NAME ../${CMAKE_PROJECT_NAME})

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})
add_executable (${EXEC_NAME} ${CLIENT_VALA_C})

target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
