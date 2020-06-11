function export_graphics(varargin)
% Matlab >= R2020a uses factory exportgraphics()
% otherwise, uses next best factory print() function

if any(exist('exportgraphics', 'file') == [2,6]) || exist('exportgraphics', 'builtin') == 5
  exportgraphics(varargin{:})
  return
end

%% Matlab < R2020a
if strcmpi(varargin{3}, 'resolution')
  dpi = ['-r', int2str(varargin{4})];
else
  dpi = '-r150';
end
[~,~,ext] = fileparts(varargin{2});
flag = printflag(ext(2:end));
% legacy figure saving function
print(varargin{1}, flag, varargin{2}, dpi)

end % function
