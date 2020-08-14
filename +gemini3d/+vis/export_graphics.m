function export_graphics(varargin)
% Matlab >= R2020a uses factory exportgraphics()
% otherwise, uses next best factory print() function

if verLessThan('matlab', '9.8')
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
