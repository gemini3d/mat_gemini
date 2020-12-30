function mustBeA(x, classes)
% for Matlab < R2020b
arguments
  x
  classes (1,:) string
end

mustBeMember(class(x), classes)

end
