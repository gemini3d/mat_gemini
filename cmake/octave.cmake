add_test(NAME octave:unit COMMAND ${Octave_EXECUTABLE} --eval "setup; test_unit"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
