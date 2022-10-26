function track=virtual_spacecraft(direc, glonsat, glatsat, altsat, tsat)
arguments
  direc (1,1) string {mustBeFolder}
  glonsat (:,:) {mustBeReal}
  glatsat (:,:) {mustBeReal}
  altsat (:,:) {mustBeReal}
  tsat (:,1) {mustBeReal}
end
% This utility traces a spacecraft through the model domain.  Inputs:
%
%    direc (string) - location of simulation output data, must contain output files,
%        config files, and grid data
%    glonsat (#times x #spacecraft) - longitude of spacecraft, degrees
%    glatsat (#times x #spacecraft) - latitude of spacecraft, degrees
%    altsat (#times x #spacecraft) - altitude of spacecraft, meters
%    tstat (#times) - time basis for the spacecraft, assumed to start at
%    the beginning of the simulation, seconds

% READ IN THE SIMULATION INFORMATION
cfg = gemini3d.read.config(direc);
ymd0=cfg.ymd; UTsec0=cfg.UTsec0;
% mloc=[cfg.sourcemlat,cfg.sourcemlon];
dtout=cfg.dtout; tdur=cfg.tdur;

% CHECK WHETHER WE NEED TO RELOAD THE GRID (WHICH CAN BE TIME CONSUMING)
disp('Loading grid...')
xg = gemini3d.read.grid(direc);
% lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
thetactr=double(mean(xg.theta, 'all'));
phictr=double(mean(xg.phi, 'all'));
[X1,X2,X3]=gemini3d.geog2UEN(xg.alt,xg.glon,xg.glat,thetactr,phictr);
X1=double(X1(:)); X2=double(X2(:)); X3=double(X3(:));

% TIMES WHERE WE HAVE MODEL OUTPUT
datemod = datetime(ymd0(1), ymd0(2), ymd0(3), 0, 0, UTsec0:dtout:tdur);

% size on input satellite track
[lorb,lsat] = size(altsat);
datesat = datetime(ymd0(1), ymd0(2), ymd0(3), 0, 0, UTsec0 + tsat);

%MAIN LOOP OVER ORBIT SEGMENTS
datebufprev=datemod(1);
datebufnext=datemod(1);
track.nesat=zeros(lorb,lsat);
track.visat=zeros(lorb,lsat);
track.Tisat=zeros(lorb,lsat);
track.Tesat=zeros(lorb,lsat);
track.J1sat=zeros(lorb,lsat);
track.J2sat=zeros(lorb,lsat);
track.J3sat=zeros(lorb,lsat);
track.v2sat=zeros(lorb,lsat);
track.v3sat=zeros(lorb,lsat);

firstprev=true;
firstnext=true;
interptype="linear";
extraptype="none";
for iorb=1:lorb
  datenow=datesat(iorb);


  %FIND THE TWO FRAMES THAT BRACKET THIS ORBIT TIME
  datemodnext=datemod(1);
  datemodprev=datemod(1);
  while(datemodnext < datenow && datemodnext <= datemod(end))
    datemodprev=datemodnext;
    datemodnext = datemodnext + seconds(dtout);
  end

  if (datemodnext==datemodprev || datemodnext>datemod(end))    %set everything to zero if outside model *time* domain
    fprintf('Requested time %s is out of simulation time interval...\n', datenow);
%     zeroarray=zeros(lx1,lx2,lx3);     %infuriatingly MATLAB is was faster this way rather than calling zeros a bunch...
%     neprev=zeroarray; nenext=zeroarray;
%     viprev=zeroarray; vinext=zeroarray;
%     Tiprev=zeroarray; Tinext=zeroarray;
%     Teprev=zeroarray; Tenext=zeroarray;
%     J1prev=zeroarray; J1next=zeroarray;
%     J2prev=zeroarray; J2next=zeroarray;
%     J3prev=zeroarray; J3next=zeroarray;
%     v2prev=zeroarray; v2next=zeroarray;
%     v3prev=zeroarray; v3next=zeroarray;

    continue;   % go to next iteration, nothing else to do
  else     % go ahead and read in data (in needed) and set up the spatial interpolations
      %DATA BUFFER UPDATES required for time interpolation
      if (abs(datebufprev-datemodprev) >= seconds(dtout/2) || firstprev)    % need to reload the previous output frame data buffers
          if (firstprev && firstnext || abs(datemodprev-datebufnext) >= seconds(dtout/2))               % only load a prev buffer if the desired previous model date (datemodprev) is not the existing next buffer (datebufnext)
              fprintf('Loading previous buffer... %s \n', datenow);

              dat=gemini3d.read.frame(direc, 'time', datemodprev);
              neprev=double(dat.ne(:)); viprev=double(dat.v1(:)); Tiprev=double(dat.Ti(:)); Teprev=double(dat.Te(:));
              J1prev=double(dat.J1(:)); J2prev=double(dat.J2(:)); J3prev=double(dat.J3(:)); v2prev=double(dat.v2(:));
              v3prev=double(dat.v3(:));
              clear('dat')    %avoid keeping extra copies of data

              % Interpolant in space (prev)
              fnesatprev=scatteredInterpolant(X1,X2,X3,neprev,interptype,extraptype);
              fvisatprev=scatteredInterpolant(X1,X2,X3,viprev,interptype,extraptype);
              fTisatprev=scatteredInterpolant(X1,X2,X3,Tiprev,interptype,extraptype);
              fTesatprev=scatteredInterpolant(X1,X2,X3,Teprev,interptype,extraptype);
              fJ1satprev=scatteredInterpolant(X1,X2,X3,J1prev,interptype,extraptype);
              fJ2satprev=scatteredInterpolant(X1,X2,X3,J2prev,interptype,extraptype);
              fJ3satprev=scatteredInterpolant(X1,X2,X3,J3prev,interptype,extraptype);
              fv2satprev=scatteredInterpolant(X1,X2,X3,v2prev,interptype,extraptype);
              fv3satprev=scatteredInterpolant(X1,X2,X3,v3prev,interptype,extraptype);
          else    % we can simply set the previous buffer to the next if we are not skipping over an output file
              fprintf('Copying next into previous buffer... %s %f\n', datenow, tsat(iorb))
              fnesatprev=fnesatnext;
              fvisatprev=fvisatnext;
              fTisatprev=fTisatnext;
              fTesatprev=fTesatnext;
              fJ1satprev=fJ1satnext;
              fJ2satprev=fJ2satnext;
              fJ3satprev=fJ3satnext;
              fv2satprev=fv2satnext;
              fv3satprev=fv3satnext;
          end %if
          datebufprev=datemodprev;
          firstprev=false;
      end %if
    if (abs(datebufnext-datemodnext) >= seconds(dtout/2) || firstnext)    %need to reload the next output frame into data buffers
      fprintf('Loading next buffer... %s\n', datenow)

      dat=gemini3d.read.frame(direc, 'time', datemodnext);
      nenext=double(dat.ne(:)); vinext=double(dat.v1(:)); Tinext=double(dat.Ti(:)); Tenext=double(dat.Te(:));
      J1next=double(dat.J1(:)); J2next=double(dat.J2(:)); J3next=double(dat.J3(:)); v2next=double(dat.v2(:));
      v3next=double(dat.v3(:));
      clear dat;    %avoid keeping extra copies of data

      % Interpolant in space (next)
      fnesatnext=scatteredInterpolant(X1,X2,X3,nenext,interptype,extraptype);
      fvisatnext=scatteredInterpolant(X1,X2,X3,vinext,interptype,extraptype);
      fTisatnext=scatteredInterpolant(X1,X2,X3,Tinext,interptype,extraptype);
      fTesatnext=scatteredInterpolant(X1,X2,X3,Tenext,interptype,extraptype);
      fJ1satnext=scatteredInterpolant(X1,X2,X3,J1next,interptype,extraptype);
      fJ2satnext=scatteredInterpolant(X1,X2,X3,J2next,interptype,extraptype);
      fJ3satnext=scatteredInterpolant(X1,X2,X3,J3next,interptype,extraptype);
      fv2satnext=scatteredInterpolant(X1,X2,X3,v2next,interptype,extraptype);
      fv3satnext=scatteredInterpolant(X1,X2,X3,v3next,interptype,extraptype);

      datebufnext=datemodnext;
      firstnext=false;
    end %if
  end %if


    %INTERPOLATIONS
    nesattmp=zeros(lsat,1); visattmp=zeros(lsat,1); Tisattmp=zeros(lsat,1);
    Tesattmp=zeros(lsat,1); J1sattmp=zeros(lsat,1); J2sattmp=zeros(lsat,1);
    J3sattmp=zeros(lsat,1); v2sattmp=zeros(lsat,1); v3sattmp=zeros(lsat,1);
    for isat=1:lsat
      [x1sat,x2sat,x3sat]=gemini3d.geog2UEN(altsat(iorb,isat),glonsat(iorb,isat),glatsat(iorb,isat),thetactr,phictr);
      fprintf('Starting interpolations for satellite:  %d\n',isat);

      % Interp in space (prev)
      nesatprev=fnesatprev(x1sat,x2sat,x3sat);
      visatprev=fvisatprev(x1sat,x2sat,x3sat);
      Tisatprev=fTisatprev(x1sat,x2sat,x3sat);
      Tesatprev=fTesatprev(x1sat,x2sat,x3sat);
      J1satprev=fJ1satprev(x1sat,x2sat,x3sat);
      J2satprev=fJ2satprev(x1sat,x2sat,x3sat);
      J3satprev=fJ3satprev(x1sat,x2sat,x3sat);
      v2satprev=fv2satprev(x1sat,x2sat,x3sat);
      v3satprev=fv3satprev(x1sat,x2sat,x3sat);

      % Interp in space (next)
      nesatnext=fnesatnext(x1sat,x2sat,x3sat);
      visatnext=fvisatnext(x1sat,x2sat,x3sat);
      Tisatnext=fTisatnext(x1sat,x2sat,x3sat);
      Tesatnext=fTesatnext(x1sat,x2sat,x3sat);
      J1satnext=fJ1satnext(x1sat,x2sat,x3sat);
      J2satnext=fJ2satnext(x1sat,x2sat,x3sat);
      J3satnext=fJ3satnext(x1sat,x2sat,x3sat);
      v2satnext=fv2satnext(x1sat,x2sat,x3sat);
      v3satnext=fv3satnext(x1sat,x2sat,x3sat);

      % Interp in time
      nesattmp(isat)=nesatprev+(nesatnext-nesatprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      visattmp(isat)=visatprev+(visatnext-visatprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      Tisattmp(isat)=Tisatprev+(Tisatnext-Tisatprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      Tesattmp(isat)=Tesatprev+(Tesatnext-Tesatprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      J1sattmp(isat)=J1satprev+(J1satnext-J1satprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      J2sattmp(isat)=J2satprev+(J2satnext-J2satprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      J3sattmp(isat)=J3satprev+(J3satnext-J3satprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      v2sattmp(isat)=v2satprev+(v2satnext-v2satprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
      v3sattmp(isat)=v3satprev+(v3satnext-v3satprev)/(datemodnext-datemodprev)*(datenow-datemodprev);
    end
    track.nesat(iorb,:)=nesattmp(:)';
    track.visat(iorb,:)=visattmp(:)';
    track.Tisat(iorb,:)=Tisattmp(:)';
    track.Tesat(iorb,:)=Tesattmp(:)';
    track.J1sat(iorb,:)=J1sattmp(:)';
    track.J2sat(iorb,:)=J2sattmp(:)';
    track.J3sat(iorb,:)=J3sattmp(:)';
    track.v2sat(iorb,:)=v2sattmp(:)';
    track.v3sat(iorb,:)=v3sattmp(:)';
end

% store input variables in output structure just in case...
track.glonsat=glonsat;
track.glatsat=glatsat;
track.altsat=altsat;
track.tsat=tsat;

end %function
