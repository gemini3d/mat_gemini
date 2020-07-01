function fullpath = web_save(filename, url)
% for Octave compatibility
narginchk(2,2)

try
  fullpath = websave(filename, url);
catch excp
  if ~any(strcmp(excp.identifier, {'MATLAB:UndefinedFunction', 'Octave:undefined-function'}))
    rethrow(excp)
  end
  fullpath = urlwrite(url, filename); %#ok<URLWR>
end

if nargout == 0, clear('fullpath'), end

end % function
