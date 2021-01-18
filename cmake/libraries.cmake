file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json _libj)

string(JSON gemini3d_url GET ${_libj} gemini3d url)
string(JSON gemini3d_tag GET ${_libj} gemini3d tag)

string(JSON msis2_url GET ${_libj} msis2 url)
string(JSON msis2_sha1 GET ${_libj} msis2 sha1)
