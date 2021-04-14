function diff(A, B, name, time, outdir, refdir)
arguments
  A {mustBeNumeric}
  B {mustBeNumeric}
  name (1,1) string
  time datetime
  outdir (1,1) string
  refdir (1,1) string
end

A = squeeze(A);
B = squeeze(B);

if ndims(A) == 3
  % loop over the species, which are in the first dimension
  for i = 1:size(A, 3)
    diff(A(:,:,i), B(:,:,i), name + " - " + int2str(i), time, outdir, refdir)
  end
end

if ~any(ndims(A) == [1, 2])
  warning("skipping diff plot: " + name)
  return
end

fg = figure('Position', [10 10 1200 400]);
t = tiledlayout(1, 3, 'parent', fg);

if ismatrix(A)
  diff2d(A, B, name, t)
elseif isvector(A)
  diff1d(A, B, name, t)
end

title(nexttile(t, 1), outdir, "interpreter", "none")
title(nexttile(t, 2), refdir, "interpreter", "none")
title(nexttile(t, 3), "diff: " + name)

tstr = string(time, "yyyy-MM-dd-HH-mm-ss");
ttxt = name + "  " + tstr;

sgtitle(fg, ttxt)

fn = fullfile(outdir, name + "-diff-" + tstr + ".png");
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
caxis(ax, [bmin, bmax])
%%
ax = nexttile(t, 2);
hi = pcolor(ax, B);
set(hi, "EdgeColor", "none")
colorbar(ax)
if ~isempty(cmap)
  colormap(ax, cmap)
end
caxis(ax, [bmin, bmax])
%%
ax = nexttile(t, 3);
dAB = A - B;
b = max(abs(min(dAB(:))), abs(max(dAB(:))));

hi = pcolor(ax, A - B);
set(hi, "EdgeColor", "none")
colorbar(ax)
colormap(gemini3d.plot.bwr())
caxis(ax, [-b, b])

end
