% heatcontent Compute the heat content for each profile of a transect
%
% T = heatcontent(T)
% 
% Compute the heat content of a profile, as:
% 	HC = rho*Cp*TEMP.dz
% 	HC unit is: J/m2
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
%
%
% Rev. by Guillaume Maze on 2012-01-27: Now compute the HC for each profile instead of a transect integral
% Created: 2009-07-29.
% http://copoda.googlecode.com
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


function T = heatcontent(T,varargin)

% In-situ density:
RHO = densjmd95(T.data.PSAL.cont,T.data.TEMP.cont,T.geo.PRES);

% Specific heat capacity:
CP = sw_cp(T.data.PSAL.cont,T.data.TEMP.cont,T.geo.PRES);

%
Tlist = data_list_user;
od  = Tlist.HC;  cont = zeros(size(T)).*NaN;
od2 = Tlist.TOTHC;  cont2 = zeros(size(T,1),1).*NaN;
for ip = 1 : size(T,1)
	z = T.geo.DEPH(ip,:);	
	zi  = z(1:end-1)+abs(diff(z));
	dzi = abs(diff(zi)/2);
	dz = [(z(1)-z(2))/2 dzi (z(end)-z(end-1))/2];

	cont(ip,:)  = RHO(ip,:).*CP(ip,:).*T.data.TEMP.cont(ip,:).*dz;
	cont2(ip,1) = nansum(RHO(ip,:).*CP(ip,:).*T.data.TEMP.cont(ip,:).*dz);
end% for ip

od.cont = cont;
T = setodata(T,'HC',od);

od2.cont = cont2;
T = setodata(T,'TOTHC',od2);

end %function













