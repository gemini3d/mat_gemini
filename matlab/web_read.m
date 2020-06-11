function S = web_read(varargin)

if any(exist('webread', 'file') == [2,6]) || exist('webread', 'builtin') == 5
  S = webread(varargin{:});
else
  S = urlread(varargin{:}); %#ok<URLRD>
end

end % function