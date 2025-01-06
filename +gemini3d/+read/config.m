%% CONFIG reads simulation configuration into struct
function cfg = config(direc)
arguments
  direc (1,1) string
end

cfg = read_nml(direc);

end
