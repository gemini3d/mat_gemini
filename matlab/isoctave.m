%!assert(islogical(isoctave))
%!assert(isoctave)
function isoct = isoctave()

isoct = exist('OCTAVE_VERSION', 'builtin') == 5;

end
