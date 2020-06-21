function fullpath = web_save(filename, url)
% for Octave compatibility
narginchk(2,2)

if any(exist('websave', 'file') == [2,6]) || exist('websave', 'builtin') == 5
  fullpath = websave(filename, url);
else
  fullpath = urlwrite(url, filename); %#ok<URLWR>
end

if nargout == 0, clear('fullpath'), end

end % function
