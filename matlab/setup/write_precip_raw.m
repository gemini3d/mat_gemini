function write_precip_raw(outdir, pg, realbits)
  narginchk(3,3)

  filename= fullfile(outdir, 'simsize.dat');
  fid=fopen(filename, 'w');
  fwrite(fid, pg.llon,'integer*4');
  fwrite(fid, pg.llat,'integer*4');
  fclose(fid);

  freal = ['float', int2str(realbits)];

  filename = fullfile(outdir, 'simgrid.dat');

  fid=fopen(filename,'w');
  fwrite(fid, pg.mlon, freal);
  fwrite(fid, pg.mlat, freal);
  fclose(fid);

  for i = 1:size(pg.expdate, 1)
    UTsec = pg.expdate(i,4)*3600 + pg.expdate(i,5)*60 + pg.expdate(i,6);
    ymd = pg.expdate(i, 1:3);

    filename = fullfile(outdir, [datelab(ymd,UTsec), '.dat']);

    fid = fopen(filename,'w');
    fwrite(fid, pg.Qit(:,:,i), freal);
    fwrite(fid, pg.E0it(:,:,i), freal);
    fclose(fid);
  end

  end % function