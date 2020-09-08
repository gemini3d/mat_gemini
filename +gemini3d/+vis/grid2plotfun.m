function plotfun = grid2plotfun(plotfun, xg)
arguments
  plotfun (1,1)
  xg (1,1) struct
end

import gemini3d.vis.plotfunctions.*

if isa(plotfun, "function_handle")
  return
elseif isstring(plotfun)
  if plotfun ~= ""
    plotfun = str2func(plotfun);
    return
  end
else
  error('grid2plotfun:type_error',  "plotfun must be function name or function_handle")
end

%% DEFINE THE PLOTTING FUNCTION BASED ON THE TYPE OF GRID USED

minh1=min(xg.h1(:));
maxh1=max(xg.h1(:));
if (abs(minh1-1)>1e-4 || abs(maxh1-1)>1e-4)    %curvilinear grid
  if (xg.lx(2)>1 && xg.lx(3)>1)
    plotfun=@plot3D_curv_frames_long;
  else
    plotfun=@plot2D_curv;
  end
else     %cartesian grid
  if (xg.lx(2)>1 && xg.lx(3)>1)
    plotfun=@plot3D_cart_frames_long_ENU;
  else
    plotfun=@plot2D_cart;
  end
end

end % function
