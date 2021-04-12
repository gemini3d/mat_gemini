function plotfun = grid2plotfun(plotfun, xg)
arguments
  plotfun
  xg (1,1) struct
end

if isa(plotfun, "function_handle")
  return
elseif isstring(plotfun) || ischar(plotfun)
  if ~isempty(plotfun)
    plotfun = str2func("gemini3d.plot" + plotfun);
    return
  end
elseif isempty(plotfun)
else
  error('grid2plotfun:type_error',  "plotfun must be function name or function_handle")
end

%% DEFINE THE PLOTTING FUNCTION BASED ON THE TYPE OF GRID USED

minh1=min(xg.h1(:));
maxh1=max(xg.h1(:));
if (abs(minh1-1)>1e-4 || abs(maxh1-1)>1e-4)    %curvilinear grid
  if (xg.lx(2)>1 && xg.lx(3)>1)
    plotfun = @gemini3d.plot.curv3d_long;
  else
    plotfun = @gemini3d.plot.curv2d;
  end
else     %cartesian grid
  if (xg.lx(2)>1 && xg.lx(3)>1)
    plotfun = @gemini3d.plot.cart3d_long_enu;
  else
    plotfun = @gemini3d.plot.cart2d;
  end
end

end % function
