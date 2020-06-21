%!assert(islogical(is_folder))
%!test ~is_folder('0984yr09uj8yfeaas918whfe98h41phfoiSDVarasAf8da1jflasjfdsdf');
%!test is_folder('.');

function ret = is_folder(path)
% overloading doesn't work in Octave since it is a core *library* function
% there doesn't appear to be a solution besides renaming this function.
narginchk(1,1)

path = expanduser(path);

try
  ret = isfolder(path);
catch excp
  if any(strcmp(excp.identifier, {'MATLAB:UndefinedFunction', 'Octave:undefined-function'}))
    ret = exist(path, 'dir') == 7;
  else
    rethrow(excp)
  end
end

end % function
