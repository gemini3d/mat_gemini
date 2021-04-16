function diff(A, B, name, time, newdir, refdir)
arguments
  A {mustBeNumeric}
  B {mustBeNumeric}
  name (1,1) string
  time (1,1) datetime
  newdir (1,1) string
  refdir (1,1) string
end

assert(ndims(A) <= 3 && ndims(B) <= 3, "for 3D or 2D arrays only")

lx = gemini3d.simsize(newdir);
is3d = lx(2) ~= 1 && lx(3) ~= 1;

A = squeeze(A);
B = squeeze(B);

if ndims(A) == 3
  if size(A,3) == 7
    % loop over the species, which are in the last dimension
    for i = 1:size(A, 3)
      gemini3d.plot.diff(A(:,:,i), B(:,:,i), name + "-" + int2str(i), time, newdir, refdir)
    end
  elseif is3d
    % pick x2 and x3 slice halfway
    i = round(size(A,3) / 2);
    gemini3d.plot.diff(A(:,:,i), B(:,:,i), name + "-x2", time, newdir, refdir)
    i = round(size(A,2) / 2);
    gemini3d.plot.diff(A(:,i,:), B(:,i,:), name + "-x3", time, newdir, refdir)
  else
    error("unexpected case, 2D data but in if-tree only for 3D")
  end

  return
end

assert(ismatrix(A), name + " unexpected > 2D. Size: " + int2str(size(A)) + " " + string(time))

fg = figure('Position', [10 10 1200 400]);
t = tiledlayout(1, 3, 'parent', fg);

if ismatrix(A)
  diff2d(A, B, name, t)
elseif isvector(A)
  diff1d(A, B, name, t)
end

title(nexttile(t, 1), newdir, "interpreter", "none")
title(nexttile(t, 2), refdir, "interpreter", "none")
title(nexttile(t, 3), "diff: " + name)

tstr = string(time, "yyyy-MM-dd-HH-mm-ss");
ttxt = name + "  " + tstr;

sgtitle(fg, ttxt)

plot_dir = fullfile(newdir, "plot_diff");
gemini3d.fileio.makedir(plot_dir)

fn = fullfile(plot_dir, name + "-" + tstr + ".png");
disp("write: " + fn)
exportgraphics(fg, fn)

end


function diff1d(A, B, t)
arguments
  A {mustBeNumeric}
  B {mustBeNumeric}
  t (1,1)
end

plot(nexttile(t, 1), A)

plot(nexttile(t, 2), b)

plot(nexttile(t, 3), A - B)

end


function diff2d(A, B, name, t)
arguments
  A {mustBeNumeric}
  B {mustBeNumeric}
  name (1,1) string
  t (1,1)
end

cmap = string.empty;
if any(startsWith(name, ["J", "v"]))
  cmap = gemini3d.plot.bwr();
end

bmin = min(min(A(:)), min(B(:)));
bmax = max(max(A(:)), max(B(:)));

ax = nexttile(t, 1);
hi = pcolor(ax, A);
set(hi, "EdgeColor", "none")
colorbar(ax)
if ~isempty(cmap)
  colormap(ax, cmap)
end
caxis(ax, [bmin, bmax]);
%%
ax = nexttile(t, 2);
hi = pcolor(ax, B);
set(hi, "EdgeColor", "none")
colorbar(ax)
if ~isempty(cmap)
  colormap(ax, cmap)
end
caxis(ax, [bmin, bmax]);
%%
ax = nexttile(t, 3);
dAB = A - B;
b = max(abs(min(dAB(:))), abs(max(dAB(:))));

hi = pcolor(ax, A - B);
set(hi, "EdgeColor", "none")
colorbar(ax)
colormap(gemini3d.plot.bwr())
caxis(ax, [-b, b]);

end
