function exists = h5exists(filename, variable)
% check if variable exists in HDF5 filename
%
% filename: HDF5 filename
% variable: name of variable inside HDF5 file
%
% exists: boolean

narginchk(2,2)
validateattributes(variable, {'char'}, {'vector'}, 2)

exists = false;

filename = expanduser(filename);

if ~is_file(filename)
  warning([filename, ' does not exist'])
  return
end

try
  h5info(filename, variable);
  exists = true;
catch excp % variable not exist
  if ~any(strcmp(excp.identifier, {'MATLAB:imagesci:h5info:fileOpenErr', 'MATLAB:imagesci:h5info:unableToFind'}))
    rethrow(excp)
  end
end % try

end % function
