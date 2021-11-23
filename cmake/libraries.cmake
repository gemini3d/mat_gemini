set(_names gemini3d)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json _libj)

foreach(n ${_names})
  foreach(t url tag)
    string(JSON m GET ${_libj} ${n} ${t})
    set(${n}_${t} ${m})
  endforeach()
endforeach()
