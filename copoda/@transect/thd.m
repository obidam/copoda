% thd Compute the main Thermocline properties for each profiles of the transect
%
% [T] = thd(T,[OPTION,VALUE])
% 
% Compute the Thermocline properties for each profiles of the transect
% object T.
%
% Inputs:
%	T: Transect objects
%	[OPTION,VALUE] pairs:
%		CRIT: This option defines the criterion to use to determine
%			the THD. It can be: 'gauss' or 'tanh'
%	
%
% Created: 2011-05-26.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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
function T = thd(T,varargin)

%- Default parameters:
crit = 'TANH';

%- Load method parameters:
switch lower(crit)
	case 'tanh' %-- TANH: DEFAULT

end% switch 

%- Load user options:
if nargin-1 ~= 0
	if mod(nargin-1,2) ~=0
		error('Arguments must come in pairs: ARG,VAL')
	end% if 
	for in = 1 : 2 : nargin-1
		eval(sprintf('%s = varargin{in+1};',varargin{in}));
	end% for in
end% if

%- Compute THD according to the selected criterion
switch lower(crit)
	case 'tanh' %-- TANH: DEFAULT
		%--- Init odata object for MLD:
		name  = sprintf('THD');
		lname = sprintf('Main Thermocline Depth using the tanh method, added by %s',getenv('USER'));
		od = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont = zeros(size(T,1),1)*NaN;
		
		%--- Loop over each profiles of the transect object and determine MLD:
%		try
			for ip = 1 : size(T,1)
				try
					z = T.geo.DEPH(ip,:);
				catch
					z = T.geo.DEPH(1,:);
				end
				st = T.data.SIG0.cont(ip,:);
				[thz mld qc] = get_thd(st,z,varargin{:});
				cont(ip,1) = thz;
				T.geo.THD_FLAG(ip,1) = qc;
			end% for ip
			od.cont = cont;
%		catch
			%stophere
%		end%cath
		%--- Update transect object
		T = setodata(T,'THD',od);
			
	case 'gauss' %-- Fitting gaussian curves
		%--- Init odata object for MLD:
		name  = sprintf('THD');
		lname = sprintf('Main Thermocline Depth using the gaussian method, added by %s',getenv('USER'));
		od    = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont  = zeros(size(T,1),1)*NaN;
		
		name  = sprintf('THH');
		lname = sprintf('Main Thermocline Thickness using the gaussian method, added by %s',getenv('USER'));
		od2   = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont2 = zeros(size(T,1),1)*NaN;
		
		name  = sprintf('THSIG0');
		lname = sprintf('Main Thermocline Potential Density using the gaussian method, added by %s',getenv('USER'));
		od3   = odata('name',name,'unit','kg/m3','long_name',lname,'long_unit','kg/m3');
		cont3 = zeros(size(T,1),1)*NaN;

		name  = sprintf('THDtop');
		lname = sprintf('Main Thermocline Top Depth using the gaussian method, added by %s',getenv('USER'));
		od4   = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont4 = zeros(size(T,1),1)*NaN;
		
		name  = sprintf('THDbto');
		lname = sprintf('Main Thermocline Bottom Depth using the gaussian method, added by %s',getenv('USER'));
		od5   = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont5 = zeros(size(T,1),1)*NaN;
		
		name  = sprintf('THMWD');
		lname = sprintf('Mode Water Depth from TH diag. using the gaussian method, added by %s',getenv('USER'));
		od6   = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont6 = zeros(size(T,1),1)*NaN;
		
		%--- Loop over each profiles of the transect object and determine THD:
		for ip = 1 : size(T,1)
			%ip
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
%			[pe mld] = idvgrads_v0('z',z,'temp',T.data.TEMP(ip,:),'psal',T.data.PSAL.cont(ip,:),varargin{:});			
			[pe mld] = idvgrads_v1('z',z,'temp',T.data.TEMP(ip,:),'psal',T.data.PSAL.cont(ip,:),varargin{:});			
			cont(ip,1)  = pe.depth;
			cont2(ip,1) = sum(pe.thickness);
			cont3(ip,1) = pe.core_sig0;
			cont4(ip,1) = pe.top;
			cont5(ip,1) = pe.bto;
			cont6(ip,1) = pe.mw;
			T.geo.THD_FLAG(ip,1) = pe.qc;
			T.geo.THD_FITSCORE(ip,1) = pe.fitscore;
		end% for ip
		od.cont  = cont;	
		od2.cont = cont2;	
		od3.cont = cont3;	
		od4.cont = cont4;	
		od5.cont = cont5;	
		od6.cont = cont6;	
		%--- Update transect object
		T = setodata(T,'THD',od);
		T = setodata(T,'THH',od2);
		T = setodata(T,'THSIG0',od3);
		T = setodata(T,'THDTOP',od4);
		T = setodata(T,'THDBTO',od5);
		T = setodata(T,'THMWD',od6);
		
end% switch 
	

end %functionthd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





















