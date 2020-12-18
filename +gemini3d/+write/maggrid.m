function maggrid()



end %function


function writemagh5()

end %function


function writemagraw()

fid=fopen([direc,'/inputs/magfieldpoints.dat'],'w');
fwrite(fid,numel(THETA),'integer*4');
fwrite(fid,R(:),'real*8');
fwrite(fid,THETA(:),'real*8');
fwrite(fid,PHI(:),'real*8');

end %function