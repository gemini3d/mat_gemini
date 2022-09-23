function dat = magdata(direc)
% reads full set of magnetic field output data

arguments
  direc (1,1) string {mustBeNonzeroLengthText}
end


% read the config fie
cfg = gemini3d.read.config(direc);
dat.times = cfg.times;

% read in one frame at a time and store results
for it=2:length(cfg.times)-1    %starts at second time step due to weird magcalc quirk
  datframe = gemini3d.read.magframe(direc,dat.times(it));

  if (isfield(datframe,"Br"))
    if (~isfield(dat,"Brt"))
      [lr,ltheta,lphi]=size(datframe.Br);
      dat.Brt=zeros(lr,ltheta,lphi,numel(dat.times));
      dat.Bthetat=zeros(lr,ltheta,lphi,numel(dat.times));
      dat.Bphit=zeros(lr,ltheta,lphi,numel(dat.times));
    end %if
    dat.Brt(:,:,:,it)=datframe.Br;
    dat.Bthetat(:,:,:,it)=datframe.Btheta;
    dat.Bphit(:,:,:,it)=datframe.Bphi;
  end %if
end

end %function
