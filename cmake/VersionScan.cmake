# test MatGemini with old and new Matlab versions
# requires "modules" to put desired Matlab version at top of PATH
# http://modules.sourceforge.net/

function(version_scan versions)
# find_program(module) does not work.

foreach(v ${versions})

  if(TEST R${v})
    continue()
  endif()

  execute_process(COMMAND sh -c "module avail matlab/${v}"
    TIMEOUT 5
    RESULT_VARIABLE err
    ERROR_VARIABLE out)
  if(NOT err EQUAL 0)
    message(FATAL_ERROR "module not working: ${err} ${out}")
  endif()

  string(FIND ${out} ${v} i)
  if(i LESS 0)
    message(STATUS "SKIP: Matlab ${v} not found by module avail")
    return()
  endif()

  execute_process(COMMAND sh -c "module load matlab/${v} && matlab -batch \"disp(version('-release'))\""
    TIMEOUT 60
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE err
    OUTPUT_VARIABLE out)
  if(NOT err EQUAL 0)
    message(STATUS "SKIP: Matlab ${v} not working: ${err}")
    return()
  endif()

  add_test(NAME ${out}
    COMMAND sh -c "module load matlab/${v} && matlab -batch TestGemini"
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
  set_tests_properties(${out} PROPERTIES TIMEOUT 900)

endforeach()

endfunction(version_scan)
