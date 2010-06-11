% omp DEV: run an OMP analysis on a transect object
%
% [] = omp(T)
% 
% Run an OMP analysis on a transect object.
% Still in devel mode !
%
%
% Created: 2009-09-03.
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


function A = omp(T)

	%%% TO BE PUT INTO A MAT FILE:
	% lat	latitude: essential
	% long	longitude: essential
	% press	pressure: essential
	% sal	salinity: essential
	% temp	temperature: essential unless potential temperature is supplied
	% ptemp	potential temperature: optional (will be calculated if not supplied)
	% pdens	potential density: optional (will be calculated if not supplied)
	% oxy	oxygen: optional
	% ph	phosphate: optional
	% ni	nitrate: optional
	% si	silicate: optional
	% pvort	108 * potential vorticity: optional (will be calculated if requested)
	% comment	data comments (region, cruise, date etsc): optional

	% Data gaps should be filled with a dummy value of -9 or less. If you include 
	% potential vorticity in your data it must be multiplied by 108. If you do not 
	% include potential vorticity but want the program to calculate it, pressure has 
	% to increase for every station (no duplicate samples at identical depths, no 
	% data from up casts). 

	% Essential inputs:
	press = T.geo.PRES;
	lat   = T.geo.LATITUDE; [lat b]=meshgrid(lat,1:size(press,2));clear b;lat=lat';lat(isnan(press))=NaN;
	long  = T.geo.LONGITUDE;[long b]=meshgrid(long,1:size(press,2));clear b;long=long';long(isnan(press))=NaN;
	sal   = T.data.PSAL.cont;
	temp  = T.data.TEMP.cont;
	oxy	  = T.data.OXYK.cont;
	
	% Reduce size:
	dz = 10;
	dd = 1;
	press = press(1:dd:end,1:dz:end);
	lat   = lat(1:dd:end,1:dz:end);
	long  = long(1:dd:end,1:dz:end);
	sal   = sal(1:dd:end,1:dz:end);
	temp  = temp(1:dd:end,1:dz:end);
	oxy   = oxy(1:dd:end,1:dz:end);
	
	% m x n -> 1 x m*n
	mask = press;
	mask(isnan(mask)==0) = 1;
	[n1 n2] = size(press);
	press = map2mat(mask,reshape(press,[1 n1 n2]));
	lat   = map2mat(mask,reshape(lat,[1 n1 n2]));
	long  = map2mat(mask,reshape(long,[1 n1 n2]));
	sal   = map2mat(mask,reshape(sal,[1 n1 n2]));
	temp  = map2mat(mask,reshape(temp,[1 n1 n2]));
	oxy   = map2mat(mask,reshape(oxy,[1 n1 n2]));

	% Complete datas:
	ptemp = sw_ptmp(sal,temp,press,0);
	pdens = sw_dens0(sal,temp) - 1000;	
	
	% Save data for omp2 package:
	dataset = '~/matlab/copoda/omp_data';
	save(dataset,'press','lat','long','sal','temp','ptemp','oxy','pdens');
	
	p = which('omp2');
	p = strrep(p,'omp2.m','');
	run(sprintf('%somp2transect',p));

	% Reshape results:
	A = mat2map(mask,A);
	
	% Move to %	
	A = A*100; 
	


end %function