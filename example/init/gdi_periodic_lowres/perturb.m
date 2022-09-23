function perturb(cfg, xg)
% perturb plasma from initial_conditions file
arguments
  cfg (1,1) struct
  xg (1,1) struct
end

%% READ IN THE SIMULATION INFORMATION
x1 = xg.x1(3:end-2);    %trim ghost cells
x2 = xg.x2(3:end-2);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
dat = gemini3d.read.frame(cfg.indat_file);
lsp = size(dat.ns, 4);


%% Choose a single profile from the center of the eq domain
ix2=floor(xg.lx(2)/2);
ix3=floor(xg.lx(3)/2);
nsscale=zeros(size(dat.ns));
for isp=1:lsp
    nprof=dat.ns(:,ix2,ix3,isp);
    nsscale(:,:,:,isp)=repmat(nprof,[1 xg.lx(2) xg.lx(3)]);
end %for


%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=2.75*6/8;
for isp=1:lsp-1
  nsscale(:,:,:,isp) = scalefact * nsscale(:,:,:,isp);
end %for
nsscale(:,:,:,lsp) = sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality


%% GDI EXAMPLE (PERIODIC) INITIAL DENSITY STRUCTURE AND SEEDING
ell=5e3;           %a gradient scale length for patch/blob
x21=-85e3;         %location on one of the patch edges
x22=-45e3;         %other patch edge
nepatchfact=10;    %density increase factor over background

nsperturb=zeros(size(dat.ns));
for isp=1:lsp-1
  for ix2=1:xg.lx(2)
    amplitude=randn(xg.lx(1),1,xg.lx(3));      %AWGN - note that can result in subtractive effects on density so apply a floor later!!!
    amplitude=0.01*amplitude;                  %amplitude standard dev. is scaled to be 1% of reference profile

    nsperturb(:,ix2,:,isp)=nsscale(:,ix2,:,isp)+...                                             %original data
                nepatchfact*nsscale(:,ix2,:,isp)*(1/2*tanh((x2(ix2)-x21)/ell)-1/2*tanh((x2(ix2)-x22)/ell));    %patch, note offset in the x2 index!!!!

    if (ix2>10 && ix2<xg.lx(2)-10)         %do not apply noise near the edge (corrupts boundary conditions)
      nsperturb(:,ix2,:,isp) = nsperturb(:,ix2,:,isp) + amplitude .* nsscale(:,ix2,:,isp);
    end %if

  end %for
end %for
nsperturb = max(nsperturb,1e4);                        %enforce a density floor (particularly need to pull out negative densities which can occur when noise is applied)
nsperturb(:,:,:,lsp) = sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% KILL OFF THE E-REGION WHICH WILL DAMP THE INSTABILITY (AND USUALLY ISN'T PRESENT IN PATCHES)
%x1ref=150e3;     %where to start tapering down the density in altitude
x1ref=200e3;     %where to start tapering down the density in altitude
dx1=10e3;
taper=1/2+1/2*tanh((x1-x1ref)/dx1);
for isp=1:lsp-1
   for ix3=1:xg.lx(3)
       for ix2=1:xg.lx(2)
           nsperturb(:,ix2,ix3,isp)=1e6+nsperturb(:,ix2,ix3,isp).*taper;
       end %for
   end %for
end %for
nsperturb(:,:,:,lsp) = sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% WRITE OUT THE RESULTS TO the same file
gemini3d.writedata(dat.time, nsperturb, dat.vs1, dat.Ts, cfg.indat_file)

end % function
