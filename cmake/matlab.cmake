# currently (August 2020) Matlab R2020b doesn't yet work due to Matlab bug.
# So search from newest to oldest known working versions.

foreach(v 9.8 9.7 9.6)
  find_package(Matlab ${v} EXACT COMPONENTS MAIN_PROGRAM)
  if(Matlab_FOUND)
    break()
  endif()
endforeach()
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

if(Matlab_VERSION AND Matlab_VERSION VERSION_LESS 9.6)
  message(STATUS "Matlab >= R2019a required for -batch mode")
  return()
endif()

add_test(NAME matlab:${test_name}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch test_gemini
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set_tests_properties(matlab:${test_name} PROPERTIES
  TIMEOUT 600)
