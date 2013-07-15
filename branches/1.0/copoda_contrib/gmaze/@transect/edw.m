% edw Characterize the Eighteen Degree Mode Water layer
%
% T = edw(T)
% 
% Characterize the Eighteen Degree Mode Water layer:
% Compute and add the following data fields to the transect object:
%	- Core/Top/Bottom Depth (18/19/17 degC isotherms depths)
%	- Thickness (19-17 isotherms depth differences)
%	- Core Salinity
%	- Core Planetary Vorticity

% Created: 2012-01-28.
% http://code.google.com/p/copoda
% Copyright 2012, COPODA

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
function T = edw(T,varargin)

%- Init:
contH = zeros(size(T,1),1).*NaN;
contD = contH;
contDTOP = contH;
contDBTO = contH;
contPLPV = contH;
contS = contH;

%- Loop over profiles:
for ip = 1 : size(T,1)
	
	y  = T.geo.LATITUDE(ip,:);
	x  = T.geo.LONGITUDE(ip,:);
	z  = T.geo.DEPH(ip,:);
	t  = T.data.TEMP.cont(ip,:);
	s  = T.data.PSAL.cont(ip,:);
	n  = T.data.BRV2.cont(ip,:);
	
	%-- Diagnostics:
%	iz = find(t>=17 & t<=19);	
	iz = find(t>=17);
	if ~isempty(iz)
		izok = find(~isnan(n) & ~isnan(t));
		% Ensure we don't have duplicate values in the profile of temperature:
		t = remove_duplicates(t,izok);
		% Update izok:
		izok = find(~isnan(n) & ~isnan(t));
		
		try
			contD(ip,1)    = nanmin([0 interp1(t(izok),z(izok),18)]);
			contDTOP(ip,1) = nanmin([0 interp1(t(izok),z(izok),19)]);
			contDBTO(ip,1) = nanmin([0 interp1(t(izok),z(izok),17)]);
			contH(ip,1)    = contDTOP(ip,1) - contDBTO(ip,1);
			contS(ip,1)    = interp1(z(izok),s(izok),contD(ip,1));
			contPLPV(ip,1) = sw_f(y)*interp1(z(izok),n(izok),contD(ip,1))/sw_g(y,contD(ip,1));		
		catch
			lasterr
			stophere
		end
	end% if				
end% for ip

%- Update transect object:
% Fast recup of needed variables EDW*:
% T.EDWH    = odata('name','EDWH' ,'long_name','EDW thickness','unit','m','long_unit','meter');
% T.EDWD    = odata('name','EDWD' ,'long_name','EDW Core Depth (18^oC isotherm depth)','unit','m','long_unit','meter');
% T.EDWDTOP = odata('name','EDWDTOP' ,'long_name','EDW Top Depth (19^oC isotherm depth)','unit','m','long_unit','meter');
% T.EDWDBTO = odata('name','EDWDBTO' ,'long_name','EDW Core Depth (17^oC isotherm depth)','unit','m','long_unit','meter');
% T.EDWPLPV = odata('name','EDWPLPV' ,'long_name','EDW Planetary Potential Vorticity (q = f*N2/g)','unit','1/m/s','long_unit','1/m/s');
% T.EDWS    = odata('name','EDWS' ,'long_name','EDW salinity','unit','psu','long_unit','psu');
Tlist = data_list_user; 

% Add values:
od = Tlist.EDWD; od.cont = contD;
T = setodata(T,'EDWD',od);

od = Tlist.EDWDTOP; od.cont = contDTOP;
T = setodata(T,'EDWDTOP',od);

od = Tlist.EDWDBTO; od.cont = contDBTO;
T = setodata(T,'EDWDBTO',od);

od = Tlist.EDWH; od.cont = contH;
T = setodata(T,'EDWH',od);

od = Tlist.EDWS; od.cont = contS;
T = setodata(T,'EDWS',od);

od = Tlist.EDWPLPV; od.cont = contPLPV;
T = setodata(T,'EDWPLPV',od);


end %functionedw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function t = remove_duplicates(t,izok)

	for ii = 1 : length(izok)
		if length(find(t(izok)==t(izok(ii))))>1
			irem = find(t(izok)==t(izok(ii)));
			irem = irem(2:end);
			t(izok(irem)) = NaN;
		end% if 
	end% for ii

end% end function











