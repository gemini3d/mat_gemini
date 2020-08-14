function [ymdnew, UTsecnew] = dateinc_old(dt, ymd, UTsec)

narginchk(3,3)

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

end % function
