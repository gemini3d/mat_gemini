function write_Efield_raw(dir_out, E)
narginchk(3,3)

freal = 'float64';

fid = fopen( fullfile(dir_out, 'simsize.dat'), 'w');
fwrite(fid, E.llon, 'integer*4');
fwrite(fid, E.llat, 'integer*4');
fclose(fid);

fid = fopen(fullfile(dir_out, 'simgrid.dat'), 'w');
fwrite(fid, E.mlon, freal);
fwrite(fid, E.mlat, freal);
fclose(fid);

for i = 1:length(E.times)
  fid = fopen(fullfile(dir_out, [datelab(E.times(i)), '.dat']), 'w');

  %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
%  fwrite(fid, p.flagdirich, 'int32');
  fwrite(fid, E.flagdirich(i), freal);   %FIXME - fortran code still wants this to be real...
  fwrite(fid, E.Exit(:,:,i), freal);
  fwrite(fid, E.Eyit(:,:,i), freal);
  fwrite(fid, E.Vminx1it(:,:,i), freal);
  fwrite(fid, E.Vmaxx1it(:,:,i), freal);
  fwrite(fid, E.Vminx2ist(:,i), freal);
  fwrite(fid, E.Vmaxx2ist(:,i), freal);
  fwrite(fid, E.Vminx3ist(:,i), freal);
  fwrite(fid, E.Vmaxx3ist(:,i), freal);

  fclose(fid);
end

end % function
