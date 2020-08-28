function r = version_atleast(in, ref)
% compare two string verions: major.minor.rev.patch
arguments
    in (1,1) string
    ref (1,1) string
end

in = split(in, ' ');
in = split(in(1), '.');

ref = split(ref, '.');

r = false;

for i = min(length(in), length(ref))
  if in(i) < ref(i)
    return
  end
end

r = true;

end % function
