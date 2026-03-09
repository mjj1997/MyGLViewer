macro(MyGLViewer_configure_linker project_name)
  set(MyGLViewer_USER_LINKER_OPTION
    "DEFAULT"
      CACHE STRING "Linker to be used")
    set(MyGLViewer_USER_LINKER_OPTION_VALUES "DEFAULT" "SYSTEM" "LLD" "GOLD" "BFD" "MOLD" "SOLD" "APPLE_CLASSIC" "MSVC")
  set_property(CACHE MyGLViewer_USER_LINKER_OPTION PROPERTY STRINGS ${MyGLViewer_USER_LINKER_OPTION_VALUES})
  list(
    FIND
    MyGLViewer_USER_LINKER_OPTION_VALUES
    ${MyGLViewer_USER_LINKER_OPTION}
    MyGLViewer_USER_LINKER_OPTION_INDEX)

  if(${MyGLViewer_USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom linker: '${MyGLViewer_USER_LINKER_OPTION}', explicitly supported entries are ${MyGLViewer_USER_LINKER_OPTION_VALUES}")
  endif()

  set_target_properties(${project_name} PROPERTIES LINKER_TYPE "${MyGLViewer_USER_LINKER_OPTION}")
endmacro()
