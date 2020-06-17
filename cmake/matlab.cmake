find_package(Matlab COMPONENTS MAIN_PROGRAM)
if(NOT Matlab_FOUND)
  return()
endif()

# other sources of info that aren't as easy to use
# * appdata\version.xml
# * appdata\prodcontents.json
# I have observed over the years that this directory name scheme is universally used.
string(REGEX MATCH "R([0-9][0-9][0-9][0-9][a-z])" Matlab_RELEASE ${Matlab_ROOT_DIR})
matlab_get_version_from_release_name(${Matlab_RELEASE} Matlab_VERSION)

if(Matlab_VERSION AND Matlab_VERSION VERSION_LESS 9.6)
  message(STATUS "Matlab >= R2019a required for -batch mode")
  return()
endif()

add_test(NAME matlab:lint COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_lint'); assert(~any(cell2mat({r.Failed})), 'fail')"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME matlab:unit COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_unit'); assert(~any(cell2mat({r.Failed})), 'fail')"
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME matlab:project COMMAND ${Matlab_MAIN_PROGRAM} -batch "setup; r=runtests('test_project'); assert(~any(cell2mat({r.Failed})), 'fail')"
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
