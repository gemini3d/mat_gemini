find_package(Matlab COMPONENTS MAIN_PROGRAM)
if(NOT Matlab_FOUND)
  return()
endif()

# other sources of info that aren't as easy to use
# * appdata\version.xml
# * appdata\prodcontents.json
# I have observed over the years that this directory name scheme is universally used.
# NOTE: some do not put an "R" in front that is /opt/matlab/2020a/... instead of /opt/matlab/R2020a/...
#
set(Matlab_VERSION)
string(REGEX MATCH "([0-9][0-9][0-9][0-9][a-z])" Matlab_RELEASE ${Matlab_ROOT_DIR})
if(Matlab_RELEASE) # don't fail if installed in custom directory
  matlab_get_version_from_release_name(${Matlab_RELEASE} Matlab_VERSION)
endif()

if(Matlab_VERSION AND Matlab_VERSION VERSION_LESS 9.7)
  message(STATUS "Matlab >= R2019b required for this project")
  return()
endif()

add_test(NAME matlab_suite
  COMMAND ${Matlab_MAIN_PROGRAM} -batch test_gemini
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set_tests_properties(matlab_suite PROPERTIES TIMEOUT 1000)
