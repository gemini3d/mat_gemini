function cmake(srcdir, builddir)
% build program using CMake and default generator
% to specify generator with CMake >= 3.15 set environment variable CMAKE_GENERATOR

narginchk(2,2)

ret = system(['cmake -S', srcdir, ' -B', builddir]);
assert(ret==0, 'error configuring MSIS')

ret = system(['cmake --build ',builddir,' --parallel']);
assert(ret==0, 'error building MSIS')

end
