function E = Jcurrent_gaussian(E, Nt, gridflag, flagdip)
% Set the top boundary shape (current density) and potential solve type flag
arguments
  E (1,1) struct
  Nt (1,1) {mustBePositive, mustBeInteger}
  gridflag (1,1) {mustBeInteger}
  flagdip (1,1) logical = false %#ok<INUSA>
end


if E.llon>1
  shapelon=exp(-(E.MLON - E.mlonmean).^2/2 / E.mlonsig^2);
else
  % doing a simulation with lat/alt. slice probably
  shapelon=1;
end

if E.llat>1
  shapelat = exp(-(E.MLAT - E.mlatmean - 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2) - exp(-(E.MLAT - E.mlatmean + 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2);
else
  shapelat = 1;
end

S = shapelon .* exp(-(E.MLAT - E.mlatmean - 1.5 * E.mlatsig).^2/ 2 / E.mlatsig^2);
for i = 6:Nt
  %could have different boundary types for different times if the user wanted...
  E.flagdirich(i)=0;
  if gridflag==1
    E.Vminx1it(:,:,i) = E.Jtarg.*shapelon.*shapelat;
  else
    E.Vmaxx1it(:,:,i) = E.Jtarg.*shapelon.*shapelat;
  end
end

end % function
