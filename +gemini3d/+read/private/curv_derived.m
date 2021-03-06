function dat = curv_derived(dat, vars)
arguments
  dat (1,1) struct
  vars (1,:) string
end

lsp = 7;

%% squeeze for 2D, OK for 3D too
if any(vars == "ne")
  dat.lxs = size(dat.ns, 1:3);
  dat.ne = dat.ns(:,:,:,lsp);
end
if any(vars == "Ti")
  dat.lxs = size(dat.ns, 1:3);
  dat.Ti = sum(dat.ns(:,:,:,1:6) .* dat.Ts(:,:,:,1:6),4) ./ dat.ns(:,:,:,lsp);
end
if any(vars == "Te")
  dat.lxs = size(dat.Ts, 1:3);
  dat.Te = dat.Ts(:,:,:,lsp);
end
if any(vars == "v1")
  dat.lxs = size(dat.ns, 1:3);
  dat.v1 = sum(dat.ns(:,:,:,1:6) .* dat.vs1(:,:,:,1:6), 4) ./ dat.ns(:,:,:,lsp);
end

end
