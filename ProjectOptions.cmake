include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


include(CheckCXXSourceCompiles)


macro(MyGLViewer_supports_sanitizers)
  # Emscripten doesn't support sanitizers
  if(EMSCRIPTEN)
    set(SUPPORTS_UBSAN OFF)
    set(SUPPORTS_ASAN OFF)
  elseif((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)

    message(STATUS "Sanity checking UndefinedBehaviorSanitizer, it should be supported on this platform")
    set(TEST_PROGRAM "int main() { return 0; }")

    # Check if UndefinedBehaviorSanitizer works at link time
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
    check_cxx_source_compiles("${TEST_PROGRAM}" HAS_UBSAN_LINK_SUPPORT)

    if(HAS_UBSAN_LINK_SUPPORT)
      message(STATUS "UndefinedBehaviorSanitizer is supported at both compile and link time.")
      set(SUPPORTS_UBSAN ON)
    else()
      message(WARNING "UndefinedBehaviorSanitizer is NOT supported at link time.")
      set(SUPPORTS_UBSAN OFF)
    endif()
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    if (NOT WIN32)
      message(STATUS "Sanity checking AddressSanitizer, it should be supported on this platform")
      set(TEST_PROGRAM "int main() { return 0; }")

      # Check if AddressSanitizer works at link time
      set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
      check_cxx_source_compiles("${TEST_PROGRAM}" HAS_ASAN_LINK_SUPPORT)

      if(HAS_ASAN_LINK_SUPPORT)
        message(STATUS "AddressSanitizer is supported at both compile and link time.")
        set(SUPPORTS_ASAN ON)
      else()
        message(WARNING "AddressSanitizer is NOT supported at link time.")
        set(SUPPORTS_ASAN OFF)
      endif()
    else()
      set(SUPPORTS_ASAN ON)
    endif()
  endif()
endmacro()

macro(MyGLViewer_setup_options)
  option(MyGLViewer_ENABLE_HARDENING "Enable hardening" ON)
  option(MyGLViewer_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    MyGLViewer_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    MyGLViewer_ENABLE_HARDENING
    OFF)

  MyGLViewer_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR MyGLViewer_PACKAGING_MAINTAINER_MODE)
    option(MyGLViewer_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(MyGLViewer_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(MyGLViewer_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(MyGLViewer_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(MyGLViewer_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(MyGLViewer_ENABLE_PCH "Enable precompiled headers" OFF)
    option(MyGLViewer_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(MyGLViewer_ENABLE_IPO "Enable IPO/LTO" ON)
    option(MyGLViewer_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(MyGLViewer_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(MyGLViewer_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(MyGLViewer_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(MyGLViewer_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(MyGLViewer_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(MyGLViewer_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(MyGLViewer_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(MyGLViewer_ENABLE_PCH "Enable precompiled headers" OFF)
    option(MyGLViewer_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      MyGLViewer_ENABLE_IPO
      MyGLViewer_WARNINGS_AS_ERRORS
      MyGLViewer_ENABLE_SANITIZER_ADDRESS
      MyGLViewer_ENABLE_SANITIZER_LEAK
      MyGLViewer_ENABLE_SANITIZER_UNDEFINED
      MyGLViewer_ENABLE_SANITIZER_THREAD
      MyGLViewer_ENABLE_SANITIZER_MEMORY
      MyGLViewer_ENABLE_UNITY_BUILD
      MyGLViewer_ENABLE_CLANG_TIDY
      MyGLViewer_ENABLE_CPPCHECK
      MyGLViewer_ENABLE_COVERAGE
      MyGLViewer_ENABLE_PCH
      MyGLViewer_ENABLE_CACHE)
  endif()

  MyGLViewer_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (MyGLViewer_ENABLE_SANITIZER_ADDRESS OR MyGLViewer_ENABLE_SANITIZER_THREAD OR MyGLViewer_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(MyGLViewer_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(MyGLViewer_global_options)
  if(MyGLViewer_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    MyGLViewer_enable_ipo()
  endif()

  MyGLViewer_supports_sanitizers()

  if(MyGLViewer_ENABLE_HARDENING AND MyGLViewer_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR MyGLViewer_ENABLE_SANITIZER_UNDEFINED
       OR MyGLViewer_ENABLE_SANITIZER_ADDRESS
       OR MyGLViewer_ENABLE_SANITIZER_THREAD
       OR MyGLViewer_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${MyGLViewer_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${MyGLViewer_ENABLE_SANITIZER_UNDEFINED}")
    MyGLViewer_enable_hardening(MyGLViewer_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(MyGLViewer_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(MyGLViewer_warnings INTERFACE)
  add_library(MyGLViewer_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  MyGLViewer_set_project_warnings(
    MyGLViewer_warnings
    ${MyGLViewer_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  include(cmake/Linker.cmake)
  # Must configure each target with linker options, we're avoiding setting it globally for now

  if(NOT EMSCRIPTEN)
    include(cmake/Sanitizers.cmake)
    MyGLViewer_enable_sanitizers(
      MyGLViewer_options
      ${MyGLViewer_ENABLE_SANITIZER_ADDRESS}
      ${MyGLViewer_ENABLE_SANITIZER_LEAK}
      ${MyGLViewer_ENABLE_SANITIZER_UNDEFINED}
      ${MyGLViewer_ENABLE_SANITIZER_THREAD}
      ${MyGLViewer_ENABLE_SANITIZER_MEMORY})
  endif()

  set_target_properties(MyGLViewer_options PROPERTIES UNITY_BUILD ${MyGLViewer_ENABLE_UNITY_BUILD})

  if(MyGLViewer_ENABLE_PCH)
    target_precompile_headers(
      MyGLViewer_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(MyGLViewer_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    MyGLViewer_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(MyGLViewer_ENABLE_CLANG_TIDY)
    MyGLViewer_enable_clang_tidy(MyGLViewer_options ${MyGLViewer_WARNINGS_AS_ERRORS})
  endif()

  if(MyGLViewer_ENABLE_CPPCHECK)
    MyGLViewer_enable_cppcheck(${MyGLViewer_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(MyGLViewer_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    MyGLViewer_enable_coverage(MyGLViewer_options)
  endif()

  if(MyGLViewer_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(MyGLViewer_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(MyGLViewer_ENABLE_HARDENING AND NOT MyGLViewer_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR MyGLViewer_ENABLE_SANITIZER_UNDEFINED
       OR MyGLViewer_ENABLE_SANITIZER_ADDRESS
       OR MyGLViewer_ENABLE_SANITIZER_THREAD
       OR MyGLViewer_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    MyGLViewer_enable_hardening(MyGLViewer_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
