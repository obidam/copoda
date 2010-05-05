% heatcontent Compute the heat content of a transect
%
% HC = heatcontent(T)
% 
% Compute the heat content of a transect, defined as:
% 	HC = int_z int_l (rho*Cp*TEMP).dz.dl
% 	HC unit is: J/m
%
% where:
%	rho is the in-situ density (kg/m3) computed from
%		T.data.PSAL, T.data.TEMP and T.geo.PRES 
%		with densjmd95.m
%	Cp is the specific heat of sea water computed from
%		T.data.PSAL, T.data.TEMP and T.geo.PRES 
%		with sw_cp.m
%	TEMP is from T.data.TEMP.cont
%	dz is the vertical grid element, ie the distance between
%		two vertical grid points
%	dl is the along grid element, ie the distance between two
%		successive profiles.
%
%
% Created: 2009-07-29.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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


function HC = heatcontent(T)

% Surface elements:
ds = get_ds(T);

% In-situ density:
RHO = densjmd95(T.data.PSAL.cont,T.data.TEMP.cont,T.geo.PRES);

% Specific heat capacity:
CP = sw_cp(T.data.PSAL.cont,T.data.TEMP.cont,T.geo.PRES);

% Heat content:
HC = nansum(nansum(RHO.*CP.*T.data.TEMP.cont.*ds));

end %function