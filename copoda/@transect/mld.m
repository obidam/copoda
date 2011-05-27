% mld Compute the Mixed Layer Depth of each transect's profiles
%
% [T] = mld(T,[OPTION,VALUE])
% 
% Compute the mixed layer depth of each profiles in transect
% object T.
%
% Inputs:
%	T: Transect objects
%	[OPTION,VALUE] pairs:
%		CRIT: This option defines the criterion to use to determine
%			the MLD. It can be:
%			'DT02': Temperature criterion, depth where temperature change 
%				compared to temperature at 10 m depth equals + or - 0.2C 
%				(allows to take into account T inversions)
%			'BRV2': Depth of the maximum Brunt-Vaissala frequency
%	
% References:
%	de Boyer Montegut et al, JGR, 2004. DOI:10.1029/2004JC002378
%
%
% Created: 2011-05-23.
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
function T = mld(T,varargin)

%- Default parameters:
crit = 'DT02';

%- Load method parameters:
switch lower(crit)
	case 'dt02' %-- DT02: DEFAULT
		dt = 0.2;
		zref = -10;
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

%- Compute MLD according to the selected criterion
switch lower(crit)
	case 'dt02' %-- DT02: DEFAULT
		%--- Init odata object for MLD:
		name  = sprintf('MLD_dt%s',num2str(dt));
%		lname = sprintf('Mixed Layer Depth using a dT(T(Zref)) criterion (dT=%s,Zref=%s)',num2str(dt),num2str(zr));
		lname = sprintf('Mixed Layer Depth using a dT(T(Zref)) criterion (dT=%s,Zref=%s), added by %s',num2str(dt),num2str(zref),getenv('USER'));
		od = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont = zeros(size(T,1),1)*NaN;
		
		%--- Loop over each profiles of the transect object and determine MLD:
%		try
			for ip = 1 : size(T,1)
				z = T.geo.DEPH(ip,:);
				t = T.data.TEMP.cont(ip,:);
				%---- Get T(Zref):
				iz  = find(z>=-100);
				if ~isempty(iz) & length(iz) ~= length(z) & length(iz) > 4
					tref = interp1(z(iz),t(iz),zref,'linear');
					%---- Get z where dt compared to tref equals + or - dt
					izmld = find(abs(t-tref)<=dt,1,'last');
					if ~isempty(izmld)						
						cont(ip,1) = z(izmld);
					end% if 
				end% if 
			end% for ip
			od.cont = cont;
%		catch
			%stophere
%		end%cath
		%--- Update transect object
		T = setodata(T,'MLD',od);
			
			
	case 'brv2' %-- BRV2: Depth of the maximum BRV2 frequency
		%--- Init odata object for MLD:
		name  = sprintf('MLD_brv2');
		lname = sprintf('Mixed Layer Depth using the max(N2) criterion, added by %s',getenv('USER'));
		od = odata('name',name,'unit','m','long_name',lname,'long_unit','Meter');
		cont = zeros(size(T,1),1)*NaN;
		Ttmp = bfrq(T);
		
		%--- Loop over each profiles of the transect object and determine MLD:
		for ip = 1 : size(T,1)
			z   = T.geo.DEPH(ip,:);
			nsq = T.data.BRV2.cont(ip,:);			
			izmld = find(nsq==nanmax(nsq),1,'first');
			if ~isempty(izmld) 
				cont(ip,1) = z(izmld);
			end% if 
		end% for ip
		od.cont = cont;
		
		%--- Update transect object
		T = setodata(T,'MLD',od);

end% switch 
	

end %functionmld
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





















