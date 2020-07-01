function S = web_read(varargin)
% GNU Octave compatible

try
  S = webread(varargin{:});
catch excp
  if ~any(strcmp(excp.identifier, {'MATLAB:UndefinedFunction', 'Octave:undefined-function'}))
    rethrow(excp)
  end
  S = urlread(varargin{:}); %#ok<URLRD>
end

end % function
