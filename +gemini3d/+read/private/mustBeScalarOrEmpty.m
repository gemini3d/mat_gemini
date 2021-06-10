function mustBeScalarOrEmpty(x)
% for Matlab < R2020b
arguments
  x
end

assert(isempty(x) || isscalar(x), "must be scalar or empty")

end
