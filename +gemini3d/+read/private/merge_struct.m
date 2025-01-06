%% MERGE_STRUCT merges two scalar struct
% merges fields of SCALAR structs "s1" and "s2",
% optionally overwriting existing s1 fields from s2.
function s1 = merge_struct(s1, s2, overwrite)
arguments
  s1 (1,1) struct
  s2 (1,1) struct
  overwrite (1,1) logical = false
end

s1fields = fieldnames(s1);
for field = fieldnames(s2)'
  if ~overwrite && isfield(s1fields, field{:})
    error('merge_struct:value_error', 'not overwriting field %s', field{:})
  end
  s1.(field{:}) = s2.(field{:});
end
end
