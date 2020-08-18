function export_graphics(varargin)
% Matlab R2020a brought exportgraphics(), which looks great, but
% fail to render under several conditions relevant to HPC:
% https://www.mathworks.com/support/bugreports/details/2195498
% Until this bug is fixed, we use next best factory print() function
%
% Bug description: any of these triggers R2020a exportgraphics bug:
% 1. The Renderer property of the figure is set to 'painters'
% 2. call the exportgraphics or copygraphics function inside a parfor loop
% 3. start MATLAB session with the -nodisplay option

use_print = verLessThan('matlab', '9.8') || ...
            ~gemini3d.sys.isinteractive || ...
            contains(rendererinfo(varargin{1}).GraphicsRenderer, 'Painters') || ...
            gemini3d.sys.is_parallel_worker;

if use_print
  if strcmpi(varargin{3}, 'resolution')
    dpi = ['-r', int2str(varargin{4})];
  else
    dpi = '-r150';
  end
  [~,~,ext] = fileparts(varargin{2});
  flag = printflag(ext(2:end));
  % legacy figure saving function
  print(varargin{1}, flag, varargin{2}, dpi)
else
  exportgraphics(varargin{:})
end

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
