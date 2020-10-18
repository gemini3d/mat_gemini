function test_potential2D(fn)
% test_potential2D('../../..\gemini3d\build\src\numerical\potential\test_potential2d.h5')
arguments
  fn (1,1) string
end

gemini3d.tests.exist_or_skip(fn, 'file')

x2 = h5read(fn, '/x2');
x3 = h5read(fn, '/x3');
Phi = h5read(fn, '/Phi');
Phi2 = h5read(fn, '/Phi2squeeze');
Phitrue = h5read(fn, '/Phitrue');


gemini3d.assert_allclose(Phi2(13, 13), 0.00032659, 'rtol', 1e-5, 'msg', 'Potential 2d accuracy')

if ~isinteractive
  return
end

%% Plot data
fg = figure();
ht = tiledlayout(fg, 1, 3);

ax1 = nexttile(ht);
imagesc(x2,x3,Phi, 'parent', ax1)
colorbar('peer', ax1)
axis(ax1, 'xy')
xlabel(ax1, 'distance (m)')
ylabel(ax1, 'distance (m)')
title(ax1, '2D potential (polarization)')

ax2 = nexttile(ht);
imagesc(x2,x3,Phi2, 'parent', ax2)
colorbar('peer', ax2)
axis(ax2, 'xy')
xlabel(ax2, 'distance (m)')
ylabel(ax2, 'distance (m)')
title(ax2, '2D potential (static)')

ax3 = nexttile(ht);
imagesc(x2,x3,Phitrue, 'parent', ax3)
colorbar('peer', ax3)
axis(ax3, 'xy')
xlabel(ax3, 'distance (m)')
ylabel(ax3, 'distance (m)')
title(ax3, '2D potential (analytical)')

end

% fid=fopen(filename);
% data=fscanf(fid,'%f',1);
% lx2=data(1);
% x2=fscanf(fid,'%f',lx2);
% data=fscanf(fid,'%f',1);
% lx3=data(1);
% x3=fscanf(fid,'%f',lx3);
% Phi=fscanf(fid,'%f',lx2*lx3);
% Phi=reshape(Phi,[lx2,lx3]);
% Phi2=fscanf(fid,'%f',lx2*lx3);
% Phi2=reshape(Phi2,[lx2,lx3]);
% Phitrue=fscanf(fid,'%f',lx2*lx3);
% Phitrue=reshape(Phitrue,[lx2,lx3]);
% fclose(fid);
