qt_standard_project_setup()

qt_add_resources(RESOURCES shader.qrc)

qt_add_executable(
  GLViewer
  main.cpp
  glwindow.cpp
  glwindow.h
  glwindow.ui
  glview.h
  glview.cpp
  ${RESOURCES}
  model.cpp
  model.h)

target_link_libraries(GLViewer PRIVATE Qt6::Widgets Qt6::OpenGLWidgets)

target_include_directories(GLViewer PRIVATE .)
