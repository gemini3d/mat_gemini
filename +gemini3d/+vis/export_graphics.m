function export_graphics(handle, filename, varargin)
% Matlab R2020a brought exportgraphics(), which looks great.
% use R2020a Update 5 to avoid bug:
% https://www.mathworks.com/support/bugreports/details/2195498

narginchk(2,inf)

filename = gemini3d.fileio.expanduser(filename);

if matoct.version_atleast(version, '9.8.0.1451342')
  exportgraphics(handle, filename, varargin{:})
  return
end

if nargin >= 4 && strcmpi(varargin{1}, 'resolution')
  dpi = ['-r', int2str(varargin{2})];
else
  dpi = [];
end
[~,~,ext] = fileparts(filename);
flag = printflag(ext(2:end));
% legacy figure saving function
print(handle, flag, filename, dpi)

end % function


function flag = printflag(fmt)
narginchk(1,1)
validateattributes(fmt, {'char'}, {'vector'}, mfilename, 'png or eps', 1)

switch fmt
  case 'png', flag = '-dpng';
  case 'eps', flag = '-depsc2';
  otherwise, flag = [];
end

end % function
