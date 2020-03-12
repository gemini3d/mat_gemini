function [ymdnew,UTsecnew]=dateinc(dt,ymd,UTsec)

narginchk(3,3)
validateattributes(dt, {'numeric'}, {'scalar', 'positive'}, mfilename, 'time step', 1)
validateattributes(ymd, {'numeric'}, {'vector', 'positive', 'numel', 3}, mfilename, 'year month day', 2)
validateattributes(UTsec, {'numeric'}, {'scalar', 'nonnegative'}, mfilename, 'UTC second', 3)

day=ymd(3); month=ymd(2); year=ymd(1);

UTsecnew=UTsec+dt;
if UTsecnew>=86400
    UTsecnew=mod(UTsecnew,86400);
    daynew=day+1;

    if daynew > eomday(year, month)
        daynew=1;
        monthnew=month+1;
        monthinc=1;
    else
        monthnew=month;
        monthinc=0;
    end


    if monthinc && monthnew > 12
        monthnew=1;
        yearnew=year+1;
    else
        yearnew=year;
    end

    ymdnew=[yearnew,monthnew,daynew];
else
    ymdnew=ymd(:)';  % ensure always a row vector
end

end
