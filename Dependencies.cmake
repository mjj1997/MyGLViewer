include(cmake/CPM.cmake)

# Qt6
list(APPEND CMAKE_PREFIX_PATH "G:/src/Qt/6.10.2/msvc2022_64")
find_package(
  Qt6 REQUIRED
  COMPONENTS Core
             Gui
             Widgets
             OpenGLWidgets)

# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(MyGLViewer_setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project

endfunction()
