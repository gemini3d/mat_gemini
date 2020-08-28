function export_graphics(handle, filename, namedargs)
% Matlab R2020a brought exportgraphics(), which looks great.
% use R2020a Update 5 to avoid bug:
% https://www.mathworks.com/support/bugreports/details/2195498
arguments
  handle (1,1)
  filename (1,1) string
  namedargs.resolution (1,1) {mustBeInteger,mustBePositive} = 150
end

filename = gemini3d.fileio.expanduser(filename);

if gemini3d.version_atleast(version, '9.8.0.1451342')
  exportgraphics(handle, filename, 'resolution', namedargs.resolution)
  return
end

dpi = "-r" + int2str(namedargs.resolution);

[~,~,ext] = fileparts(filename);
flag = printflag(extractAfter(ext, 1));
% legacy figure saving function
print(handle, flag, filename, dpi)

end % function


function flag = printflag(fmt)

switch fmt
  case 'png', flag = "-dpng";
  case 'eps', flag = "-depsc2";
  otherwise, flag = [];
end

end % function
