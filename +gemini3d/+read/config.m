%% CONFIG reads simulation configuration into struct
function cfg = config(direc)
arguments
  direc (1,1) string {mustBeFolder}
end

cfg = gemini3d.read.gemini_namelist(direc);

end
