function Struct = ini2struct(filename)
% Parses .ini file
% Returns a structure with section names and keys as fields.
%
% Based on init2struct.m by Andriy Nych
% 2014/02/01
%
% robustified by Michael Hirsch 2020
arguments
  filename (1,1) string
end

f = fopen(filename,'r');                    % open file
if f < 1
  error('ini2struct:os_error', 'could not open %s', FileName)
end

while ~feof(f)                              % and read until it ends
  s = strtrim(fgetl(f));                  % remove leading/trailing spaces
  if isempty(s) || s(1)==';' || s(1)=='#' % skip empty & comments lines
    continue
  end
  if s(1)=='['                            % section header
    Section = matlab.lang.makeValidName(strtok(s(2:end), ']'));
    Struct.(Section) = [];              % create field
    continue
  end

  [Key,Val] = strtok(s, '=');             % Key = Value ; comment
  Val = strtrim(Val(2:end));              % remove spaces after =

  if isempty(Val) || Val(1)==';' || Val(1)=='#' % empty entry
    Val = [];
  elseif Val(1)=='"'                      % double-quoted string
    Val = strtok(Val, '"');
  elseif Val(1)==''''                     % single-quoted string
    Val = strtok(Val, '''');
  else
    Val = strtok(Val, ';');             % remove inline comment
    Val = strtok(Val, '#');             % remove inline comment
    Val = strtrim(Val);                 % remove spaces before comment

    [val, status] = str2num(Val);
    if status, Val = val; end           % convert string to number(s)
  end

  if ~exist('Section', 'var')             % No section found before
    Struct.(matlab.lang.makeValidName(Key)) = Val;
  else                                    % Section found before, fill it
    Struct.(Section).(matlab.lang.makeValidName(Key)) = Val;
  end

end

fclose(f);

end % function
