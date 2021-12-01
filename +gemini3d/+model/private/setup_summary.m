function setup_summary(cfg)
arguments
  cfg (1,1) struct
end

disp('******************** input config ****************')
disp("simulation directory: " + cfg.outdir)
disp("start year-month-day: " + int2str(cfg.ymd))
disp("start time: (UT seconds since midnight) " + num2str(cfg.UTsec0))
disp("duration: (seconds) " + num2str(cfg.tdur))
disp("sim file output every: (seconds)" + num2str(cfg.dtout))
disp("Gemini3D input data files:")
disp(cfg.indat_size)
disp(cfg.indat_grid)
disp(cfg.indat_file)

if any(contains(fieldnames(cfg), "flagdneu")) && cfg.flagdneu
  disp("Neutral disturbance mlat,mlon: " + num2str(cfg.sourcemlat) + " " + num2str(cfg.sourcemlon))
  disp("Neutral disturbance cadence (s): " + num2str(cfg.dtneu))
  disp("Neutral grid resolution (m): " + num2str(cfg.drhon) + " " + num2str(cfg.dzn))
  disp("Neutral disturbance data files located in directory: " + cfg.sourcedir)
else
  disp("no neutral disturbance specified.")
end

if any(contains(fieldnames(cfg), "flagprecfile")) &&  cfg.flagprecfile
  disp("Precipitation file input cadence (s): " + num2str(cfg.dtprec))
  disp("Precipitation file input source directory: " + cfg.precdir)
else
  disp("no precipitation specified")
end

if any(contains(fieldnames(cfg), "flagE0file")) && cfg.flagE0file
  disp("Electric field file input cadence (s): " + num2str(cfg.dtE0))
  disp("Electric field file input source directory: " + cfg.E0dir)
else
  disp("no Efield specified")
end

if any(contains(fieldnames(cfg), "flagglow")) && cfg.flagglow
  disp("GLOW enabled for auroral emission calculations.")
  disp("GLOW electron transport calculation cadence (s): " + num2str(cfg.dtglow))
  disp("GLOW auroral emission output cadence (s): " + num2str(cfg.dtglowout))
else
  disp("GLOW disabled")
end

if any(contains(fieldnames(cfg), "msis_version")) &&  cfg.msis_version == 20
  disp("MSIS 2.0 enabled for neutral atmosphere calculations.")
else
  disp("MSISE00 enabled for neutral atmosphere calculations.")
end

if any(contains(fieldnames(cfg), "flagEIA")) && cfg.flagEIA
  disp("EIA enabled with peok equatorial drift: " + num2str(cfg.v0equator))
else
  disp("EIA disabled")
end

if any(contains(fieldnames(cfg), "flagdneuBG")) && cfg.flagneuBG
  disp("Variable background neutral atmosphere enabled at cadence: " + num2str(cfg.dtneuBG))
  disp("Background precipitation has total energy flux and energy: " + num2str(cfg.PhiWBG) + " " + num2str(cfg.W0BG))
else
  disp("Variable background neutral atmosphere disabled.")
end

if any(contains(fieldnames(cfg), "flagJpar")) && cfg.flagJpar
  disp("Parallel current calculation enabled.")
else
  disp("Parallel current calculation disabled.")
end

if any(contains(fieldnames(cfg), "flagcap"))
disp("Inertial capacitance calculation type: " + int2str(cfg.flagcap))
end

if any(contains(fieldnames(cfg), "diffsolvetype"))
disp("Diffusion solve type: " + int2str(cfg.diffsolvetype))
end

if any(contains(fieldnames(cfg), "mcadence")) && cfg.mcadence > 0
  disp("Milestone output selected; cadence (every nth output) of: " + num2str(cfg.mcadence))
else
  disp("Milestone output disabled.")
end

if any(contains(fieldnames(cfg), "flaggravdrift")) && cfg.flaggravdrift
  disp("Gravitational drift terms enabled.")
else
  disp("Gravitaional drift terms disabled.")
end

if any(contains(fieldnames(cfg), "flaglagrangian")) &&  cfg.flaglagrangian
  disp("Lagrangian grid enabled.")
else
  disp("Lagrangian grid disabled")
end

disp('**************** end input config ***************')
end
