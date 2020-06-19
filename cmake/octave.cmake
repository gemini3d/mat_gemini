find_package(Octave COMPONENTS Interpreter)
if(NOT Octave_FOUND)
  return()
endif()

add_test(NAME octave:unit COMMAND ${Octave_EXECUTABLE} --eval "setup; test_unit"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME octave:netcdf COMMAND ${Octave_EXECUTABLE} --eval "setup; test_netcdf"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
