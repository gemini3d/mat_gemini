
function [x1,TsEuler,TsBDF2,Tstrue] = test_diffusion1D(fn)
%LOAD AND PLOT NUMERICAL SOLUTION to diffusion problem
%return the test data to the user in case they want to
%look over the differences and numerical error.
arguments
  fn (1,1) string
end

gemini3d.test.exist_or_skip(fn, 'file')

L = h5read(fn, '/lt');
x1 = h5read(fn, '/x1');

for it=1:L
  ic = num2str(it, '%4.4d');

  time(it) = h5read(fn, "/t" + ic);
  TsEuler(:, it) = h5read(fn, "/TsEuler" + ic); %#ok<*AGROW>
  TsBDF2(:, it) = h5read(fn, "/TsBDF2" + ic);
  Tstrue(:, it) = h5read(fn, "/TsTrue" + ic);
end

% reltol = 1e-5 for real32
% this is just a random point we're comparing.
gemini3d.assert_allclose(TsEuler(13,13), 0.770938954253086, rtol=1e-5, err_msg='1-D Euler diffusion accuracy')
gemini3d.assert_allclose(TsBDF2(13,13),  0.763236513549944, rtol=1e-5, err_msg='1-D BDF2 diffusion accuracy')
gemini3d.assert_allclose(Tstrue(13,13),  0.763014494788105, rtol=1e-5, err_msg='1-D true diffusion accuracy')

disp('OK: 1d diffusion')

if ~gemini3d.sys.isinteractive
  if ~nargout, clear, end
  return
end
%% plots

hf = figure;
t = tiledlayout(hf, 1, 3);
ax1 = nexttile(t);
imagesc(time, x1(3:end-2),TsEuler, 'parent', ax1)
ylabel(ax1,'distance (m)')
title(ax1,'1D diffusion (backward Euler)')

ax2 = nexttile(t);
imagesc(time, x1(3:end-2),TsBDF2, 'parent', ax2)
title(ax2,'1D diffusion (TRBDF2)')

ax3 = nexttile(t);
imagesc(time, x1(3:end-2),Tstrue, 'parent', ax3)
title(ax3,'1D diffusion (analytic)')

for ax = [ax1,ax2,ax3]
  colormap(ax, 'bwr')
  colorbar('peer',ax)
  xlabel(ax,'time (sec)')
end

if ~nargout, clear, end
end % function


% fid=fopen(fn);
% data=fscanf(fid,'%f',2);
% lt=data(1);
% lx1=data(2);
% x1=fscanf(fid,'%f',lx1+4)';

% t=zeros(lt,1);
% for it=1:lt
%   t(it)=fscanf(fid,'%f',1);
%   TsEuler(:,it)=fscanf(fid,'%f',lx1)';
%   TsBDF2(:,it)=fscanf(fid,'%f',lx1)';
%   Tstrue(:,it)=fscanf(fid,'%f',lx1)';
% end % for
