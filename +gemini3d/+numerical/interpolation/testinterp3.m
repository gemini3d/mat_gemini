function [x1,x2,x3,f] = testinterp3(fn)
%  testinterp3('../../../gemini3d/build/src/numerical/interpolation/output3d.h5')
arguments
  fn (1,1) string
end
gemini3d.exist_or_skip(fn, 'file')

lx1 = h5read(fn, '/lx1');
lx2 = h5read(fn, '/lx2');
lx3 = h5read(fn, '/lx3');
x1 = h5read(fn, '/x1');
x2 = h5read(fn, '/x2');
x3 = h5read(fn, '/x3');
f = h5read(fn, '/f');

assert(lx1==256, int2str(size(lx1)))
assert(lx2==256, int2str(size(lx2)))
assert(lx3==256, int2str(size(lx3)))
assert(all(size(f) == [lx1,lx2,lx3]), 'array size mismatch')

if ~gemini3d.sys.isinteractive
  if ~nargout, clear, end
  return
end

%% PLOT
fg = figure();
ht = tiledlayout(fg, 1, 3);
ax1 = nexttile(ht);
imagesc(x2,x1,f(:,:,end/2), 'parent', ax1)
axis(ax1, 'xy')
xlabel(ax1, 'x_2')
ylabel(ax1, 'x_1')
c=colorbar('peer', ax1);
ylabel(c,'f')
title(ax1, '3D interp x_1-x_2')

ax2 = nexttile(ht);
imagesc(x3,x1,squeeze(f(:,end/2-10,:)), 'parent', ax2)
axis(ax2, 'xy')
xlabel(ax2, 'x_3')
ylabel(ax2, 'x_1')
c=colorbar('peer', ax2);
ylabel(c,'f')
title(ax2, '3D interp x_1-x_3')

ax3 = nexttile(ht);
imagesc(x2,x3,squeeze(f(end/2-10,:,:)), 'parent', ax3)
axis(ax3, 'xy')
xlabel(ax3, 'x_2')
ylabel(ax3, 'x_3')
c=colorbar('peer', ax3);
ylabel(c,'f')
title(ax3, '3D interp x_2-x_3')

if nargout==0, clear, end
end % function

% fid=fopen(fn,'r');

% %% LOAD DATA
% lx1=fread(fid,1,'integer*4');
% lx2=fread(fid,1,'integer*4');
% lx3=fread(fid,1,'integer*4');
% x1=fread(fid,lx1, freal);
% x2=fread(fid,lx2, freal);
% x3=fread(fid,lx3, freal);
% f=fread(fid,lx1*lx2*lx3, freal);
% f=reshape(f,[lx1,lx2,lx3]);

% fclose(fid);
