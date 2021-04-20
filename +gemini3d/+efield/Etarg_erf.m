function E = Etarg_erf(E, xg, lx1, lx2, lx3, Nt,gridflag,flagdip)
% Set the top boundary shape (potential) and potential solve type flag

arguments
  E (1,1) struct
  xg (1,1) struct
  lx1 (1,1) {mustBeInteger,mustBePositive}
  lx2 (1,1) {mustBeInteger,mustBePositive}
  lx3 (1,1) {mustBeInteger,mustBePositive}
  Nt (1,1) {mustBeInteger,mustBePositive}
  gridflag (1,1) {mustBeInteger,mustBePositive}
  flagdip (1,1) logical
end

%% create feature defined by Efield
% NOTE: h2, h3 have ghost cells, so we use lx1 instead of "end" to index
% pk is a scalar.

if flagdip
  if lx3 == 1 % meridional slice
    S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
    taper = erf((E.MLAT - E.mlatmean) / E.mlatsig);
  elseif (lx2>1 && lx3>1)
    % 3D
    S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
    taper = erf((E.MLON - E.mlonmean) / E.mlonsig) .* erf((E.MLAT - E.mlatmean) / E.mlatsig);
  else
    error(' Efield_target:  you appear to be making a zonal ribbon grid, which is not yet supported');
  end
else
  if lx3 == 1 % east-west
    S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
    taper = erf((E.MLON - E.mlonmean) / E.mlonsig);
  elseif lx2 == 1 % north-south
    S = E.Etarg * E.sigx3 .* xg.h3(lx1, 1, floor(lx3/2)) .* sqrt(pi)./2;
    taper = erf((E.MLAT - E.mlatmean) / E.mlatsig);
  else % 3D
    S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
    taper = erf((E.MLON - E.mlonmean) / E.mlonsig) .* erf((E.MLAT - E.mlatmean) / E.mlatsig);
  end
end %if

% x2ctr = 1/2*(xg.x2(lx2) + xg.x2(1));
for i = 1:Nt
  E.flagdirich(i)=1;

  if (gridflag==1)
    E.Vminx1it(:,:,i) = S .* taper;
  else
    E.Vmaxx1it(:,:,i) = S .* taper;
  end %if
end

% for i=1:Nt
%   % When using dirichlet conditions the side walls need to be chosen to be
%   % equipotential with the top corner grid points
%   E.Vminx2it(:,i)=
%   E.Vmaxx2it(:,i)=
%   E.Vminx3it(:,i)=
%   E.Vmaxx3it(:,i)=
% end %for

end % function
