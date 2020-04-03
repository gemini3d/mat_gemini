function [Q] = precip_gaussian2d(pg, Qpeak, Qbackground)
%% makes a 2D Gaussian shape in Latitude, Longitude

Q = Qpeak * ...
    exp(-(pg.MLON - pg.mlon_mean).^2 / (2*pg.mlon_sigma^2)) .* ...
    exp(-(pg.MLAT - pg.mlat_mean).^2 / (2*pg.mlat_sigma^2));

Q(Q < Qbackground) = Qbackground;

end % function