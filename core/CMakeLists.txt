cmake_minimum_required(VERSION 3.16)
project(OverOSCore VERSION 0.2.1 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(GNUInstallDirs)
include(CTest)

add_executable(overos-init init/overos-init.c)
target_compile_options(overos-init PRIVATE -Wall -Wextra -Wpedantic -Wconversion)

add_executable(overos-hardware-info services/hardware-info.cpp)
target_compile_options(overos-hardware-info PRIVATE -Wall -Wextra -Wpedantic)

add_executable(overos-session session/overos-session.cpp)
target_compile_options(overos-session PRIVATE -Wall -Wextra -Wpedantic)

add_executable(overosctl tools/overosctl.cpp)
target_compile_options(overosctl PRIVATE -Wall -Wextra -Wpedantic)

add_executable(overos-supervisor services/overos-supervisor.cpp)
target_compile_options(overos-supervisor PRIVATE -Wall -Wextra -Wpedantic)

# GTK4 desktop is optional for low-dependency builds, but enabled in CI.
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(GTK4 QUIET IMPORTED_TARGET gtk4)
endif()
if(GTK4_FOUND)
  add_executable(overos-desktop desktop/overos-desktop.cpp)
  target_link_libraries(overos-desktop PRIVATE PkgConfig::GTK4)
  target_compile_options(overos-desktop PRIVATE -Wall -Wextra -Wpedantic)
  install(TARGETS overos-desktop RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
  if(BUILD_TESTING)
    add_test(NAME desktop-version COMMAND overos-desktop --version)
  endif()
else()
  message(STATUS "GTK4 not found: skipping optional overos-desktop target")
endif()

install(TARGETS overos-init
  RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})
install(TARGETS overos-session
  RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})
install(TARGETS overos-hardware-info overosctl
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(TARGETS overos-supervisor
  RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})

if(BUILD_TESTING)
  add_test(NAME overosctl-help COMMAND overosctl help)
  add_test(NAME overosctl-version COMMAND overosctl version)
  add_test(NAME overosctl-status COMMAND overosctl status)
  add_test(NAME overosctl-rejects-unknown-command COMMAND overosctl __invalid_command__)
  add_test(NAME hardware-inventory COMMAND overos-hardware-info)
  add_test(NAME session-exits-cleanly COMMAND bash -c "echo 0 | $<TARGET_FILE:overos-session>")
  add_test(NAME supervisor-validates-config COMMAND overos-supervisor --check-config ${CMAKE_CURRENT_SOURCE_DIR}/tests/services.conf.example)
  add_test(NAME supervisor-rejects-empty-config COMMAND overos-supervisor --check-config ${CMAKE_CURRENT_SOURCE_DIR}/tests/services.conf.empty)
  add_test(NAME supervisor-rejects-relative-path COMMAND overos-supervisor --check-config ${CMAKE_CURRENT_SOURCE_DIR}/tests/services.conf.invalid-relative)
  add_test(NAME supervisor-rejects-duplicate-path COMMAND overos-supervisor --check-config ${CMAKE_CURRENT_SOURCE_DIR}/tests/services.conf.invalid-duplicate)
  set_tests_properties(overosctl-rejects-unknown-command supervisor-rejects-empty-config supervisor-rejects-relative-path supervisor-rejects-duplicate-path PROPERTIES WILL_FAIL TRUE)
  add_test(NAME init-refuses-non-pid1 COMMAND overos-init)
  set_tests_properties(init-refuses-non-pid1 PROPERTIES WILL_FAIL TRUE)
endif()
