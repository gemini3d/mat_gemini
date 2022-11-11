function cfg = config(direc)
% reads simulation configuration into struct
arguments
  direc (1,1) string {mustBeNonzeroLengthText}
end

cfg = read_nml(direc);

end % function
