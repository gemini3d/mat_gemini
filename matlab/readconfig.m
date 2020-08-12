function [ymd,UTsec,tdur,dtout,flagoutput,mloc,activ,indat_size,indat_grid,indat_file] = readconfig(path)

narginchk(1,1)

params = read_config(path);


%% FIXME: make rest of programs use struct instead of individual variables
ymd = params.ymd;
UTsec = params.UTsec0;
tdur = params.tdur;
dtout = params.dtout;
flagoutput = params.flagoutput;
activ = params.activ;
mloc = params.mloc;
indat_size=params.indat_size;
indat_grid=params.indat_grid;
indat_file=params.indat_file;
end % function

% Copyright 2020 Michael Hirsch, Ph.D.

% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at

%     http://www.apache.org/licenses/LICENSE-2.0

% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
