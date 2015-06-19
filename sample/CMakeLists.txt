find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED gthread-2.0 gtk+-3.0 wingpanel-2.0)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})
set (SAMPLEINDICATOR "indicator-sample")

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.12.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C ${SAMPLEINDICATOR}
  SampleIndicator.vala
PACKAGES
  gtk+-3.0
  wingpanel-2.0
  granite
OPTIONS
  --thread
)

add_library (${SAMPLEINDICATOR} MODULE ${VALA_C})
target_link_libraries(${SAMPLEINDICATOR} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${SAMPLEINDICATOR} DESTINATION "${INDICATORS_DIR}/${INDICATORNAME}")
