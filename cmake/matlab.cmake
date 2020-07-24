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

include(ProcessorCount)
ProcessorCount(Ncpu)

function(matlab_test test_name test_cell parallel)
# with short tests, useparallel makes take longer due to long parallel pool startup time

add_test(NAME matlab:${test_name}
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests(${test_cell}, 'UseParallel', ${parallel}); assert(~any(cell2mat({r.Failed})), '${test_name} fail')"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tests)
set_tests_properties(matlab:${test_name} PROPERTIES
  PROCESSORS ${Ncpu}
  TIMEOUT 600)

endfunction(matlab_test)

matlab_test(lint "{'test_lint'}" 0)

matlab_test(unit "{'test_unit', 'test_hdf5', 'test_netcdf'}" 0)

matlab_test(project "{'test_project_hdf5', 'test_project_netcdf'}" 1)
