function fullpath = web_save(filename, url)
narginchk(2,2)

if any(exist('webread', 'file') == [2,6]) || exist('webread', 'builtin') == 5
  fullpath = websave(filename, url);
else
  fullpath = urlwrite(url, filename); %#ok<URLWR>
end

if nargout == 0, clear('fullpath'), end

end % function