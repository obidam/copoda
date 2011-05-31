% thermalwind H1LINE
%
% [] = thermalwind(T)
% 
% Compute the vertical gradient of geostrophic velocities:
%	dv/dz = g/f/rho0 * d rho / dx
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-06-15.
% http://code.google.com/p/copoda
% Copyright 2010, COPODA

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = thermalwind(T,varargin)

stophere
% Keep input safe:
T0 = T; 

%- Move to standard levels:
% we use the validate test #12 (linear interpolation)
% ID# 12: Change the vertical grid to a regular one defined by the global variable:
%       :      global validate_transect_Zgrid
%       :      validate_transect_Zgrid.ztop   = 0;
%       :      validate_transect_Zgrid.zbot   = -5500;
%       :      validate_transect_Zgrid.dz     = -10;
%       :      validate_transect_Zgrid.method = 'linear';
global validate_transect_Zgrid
validate_transect_Zgrid.ztop   = 0;
validate_transect_Zgrid.zbot   = -5500;
validate_transect_Zgrid.dz     = -50;
validate_transect_Zgrid.method = 'linear';
[res T] = validate(T,1,1,12);

%- Get variables:
[np nl] = size(T);
s = T.data.PSAL.cont;
t = T.data.TEMP.cont;
p = T.geo.PRES;
z = T.geo.DEPH;
lat = T.geo.LATITUDE;
lon = T.geo.LONGITUDE;

% Geopotential Anomaly calculated as the integral of svan 
% from the the sea surface to the bottom.  Thus RELATIVE TO SEA SURFACE.
% svan: specific volume anomly.
% S = salinity    [psu      (PSS-78)]
% T = temperature [degree C (ITS-90)]
% P = Pressure    [db]
gpan = ones(np,nl)*NaN;
for ip = 1 : np
	izok = find(isnan(s(ip,:))==0 & isnan(t(ip,:))==0 &isnan(p(ip,:))==0);
	if length(izok)>2
		gpan(ip,izok) = sw_gpan(s(ip,izok),t(ip,izok),p(ip,izok));
	end
end

% pcolor(1:np,z',gpan')

% Calculates geostrophic velocity given the geopotential anomaly and position of each station.
%   gpan   = geopotential anomoly relative to the sea surface.
%          dim(mxnstations)
%   lat  = latitude  of each station (+ve = N, -ve = S) [ -90.. +90]
%   lon  = longitude of each station (+ve = E, -ve = W) [-180..+180]
vel = sw_gvel(gpan',lat',lon')';

[s ds]=surface(T);


stophere

end %functionthermalwind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








