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
%			the THD. It can be: 
%				'gauss' calls for local function 'idvgrads_v1'
%				DEPREC: 'tanh' calls for local function 'get_thd'
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
crit = 'gauss';

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

if exist('core_top','var')
	core_top0 = core_top;
end% if 

%- Compute THD according to the selected method
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
	
	case 'gauss_optim' %-- Fitting gaussian curves (Optimized routines)
		
		%--- Init odata objects:
		Tlist = data_list_user; % Fast recup of pre-defined variables TH*:		
		cont1 = zeros(size(T,1),1)*NaN;
		cont2 = cont1;cont3 = cont1; cont4 = cont1;
		cont5 = cont1;cont6 = cont1; cont7 = cont1;
		cont8 = cont1;		
	
		%--- Loop over each profiles of the transect object and determine THD:
		for ip = 1 : size(T,1)
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
			temp = T.data.TEMP(ip,:);
			psal = T.data.PSAL.cont(ip,:);
			lat  = T.geo.LATITUDE(ip);

			[pe mld] = idvgrads_v3_good('z',z,'temp',temp,'psal',psal,'lat',lat,varargin{:});			
			if pe.qc == 20 | pe.qc == 31
				if exist('core_top0','var')
					core_top = core_top0 - 200;
					[pe mld] = idvgrads_v3_good('z',z,'temp',temp,'psal',psal,'lat',lat,varargin{:},'core_top',core_top);									
				end% if
			end% if 
				
			cont1(ip,1) = pe.depth;
			cont2(ip,1) = pe.top;
			cont3(ip,1) = pe.bto;			
			cont4(ip,1) = sum(pe.thickness); % top + bottom gaussians thickness
		
			cont5(ip,1) = pe.core_sig0;
			cont6(ip,1) = pe.core_temp;
			cont7(ip,1) = pe.core_psal;
			cont8(ip,1) = pe.core_bfrq;
			cont9(ip,1) = pe.core_pv;
		
			cont10(ip,1)= pe.mw;
		
			T.geo.THD_FLAG(ip,1) = pe.qc;
			T.geo.THD_FITSCORE(ip,1) = pe.fitscore;
		end% for ip
	
		Tlist.THD.cont    = cont1;	
		Tlist.THDTOP.cont = cont2;	
		Tlist.THDBTO.cont = cont3;			
		Tlist.THH.cont    = cont4;
	
		Tlist.THSIG0.cont = cont5;	
		Tlist.THTEMP.cont = cont6;	
		Tlist.THPSAL.cont = cont7;
		Tlist.THBFRQ.cont = cont8;	
		Tlist.THPLPV.cont = cont9;
		
		Tlist.THMWD.cont  = cont10;			

		%--- Update transect object
		T = setodata(T,'THD',Tlist.THD);
		T = setodata(T,'THDTOP',Tlist.THDTOP);
		T = setodata(T,'THDBTO',Tlist.THDBTO);
		T = setodata(T,'THH',Tlist.THH);
	
		T = setodata(T,'THSIG0',Tlist.THSIG0);
		T = setodata(T,'THTEMP',Tlist.THTEMP);
		T = setodata(T,'THPSAL',Tlist.THPSAL);
		T = setodata(T,'THBFRQ',Tlist.THBFRQ);
		T = setodata(T,'THPLPV',Tlist.THPLPV);
	
		T = setodata(T,'THMWD',Tlist.THMWD);


	case 'gauss' %-- Fitting gaussian curves
		%--- Init odata objects:
		Tlist = data_list_user; % Fast recup of pre-defined variables TH*:		
		cont1 = zeros(size(T,1),1)*NaN;
		cont2 = cont1;cont3 = cont1; cont4 = cont1;
		cont5 = cont1;cont6 = cont1; cont7 = cont1;
		cont8 = cont1;		
		
		dz0       = dz;
		zscal0    = zscal;
		Hoffset0  = Hoffset;
		below0    = below;
		core_top0 = core_top;
		%--- Loop over each profiles of the transect object and determine THD:
		for ip = 1 : size(T,1)
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
			temp = T.data.TEMP(ip,:);
			psal = T.data.PSAL.cont(ip,:);
			if 0 % Only one guess
				[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:});		
					
			elseif 0 % Try to improve guess
				[pe mld] = idvgrads_v2('z',z,'temp',temp,'psal',psal,varargin{:});
				if pe.qc == 20 | pe.qc == 31
					if exist('core_top0','var')
						core_top = core_top0 - 200;
						[pe mld] = idvgrads_v2('z',z,'temp',temp,'psal',psal,varargin{:},'core_top',core_top);
					end% if
				end% if 
			elseif 1 % Try to improve 1st guess
			
				% 1st guess:
				[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:});				
				
				% if THD looks shallow, try to improve with less smoothing:
				testA = false;
				if pe.depth > -300 | (pe.qc == 20 | pe.qc == 31)
					[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'dz',dz/2,'zscal',zscal/2);
					testA = true;
				end% if
				
				% The 1st inflexion point is too close to the top (qc=20) or the top gaussian is not well resolved (qc=31), 
				% try to look deeper, by changing the Maximum depth of the mode water:
				testB = false;
				if pe.qc == 20 | pe.qc == 31
					testB = true;
					if testA
						[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'dz',dz/2,'zscal',zscal/2,'core_top',core_top - 200);
					else					
						[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'core_top',core_top - 200);					
					end% if 

					% Again ?, try to look the other way then:
					testC = false;
					if pe.qc == 20 | pe.qc == 31 
						testC = true;
						if testA
							[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'dz',dz/2,'zscal',zscal/2,'core_top',core_top + 200);					
						else
							[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'core_top',core_top + 200);					
						end% if 
					end% if
				end% if
				
				if pe.qc == 22 % ixtop == 1, we may not be looking shallow enough
					if testA
						[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'dz',dz/2,'zscal',zscal/2,'core_top',below + 20);					
					else
						[pe mld] = idvgrads_v2b('z',z,'temp',temp,'psal',psal,varargin{:},'core_top',below + 20);					
					end% if 
				end% if
				
				
			end% if 
			
			cont1(ip,1) = pe.depth;
			cont2(ip,1) = pe.top;
			cont3(ip,1) = pe.bto;			
			cont4(ip,1) = sum(pe.thickness); % top + bottom gaussians thickness
			
			cont5(ip,1) = pe.core_sig0;
			cont6(ip,1) = pe.core_temp;
			cont7(ip,1) = pe.core_psal;
			cont8(ip,1) = pe.core_bfrq;
			cont9(ip,1) = pe.core_pv;
			
			cont10(ip,1)= pe.mw;
			
			T.geo.THD_FLAG(ip,1) = pe.qc;
			T.geo.THD_FITSCORE(ip,1) = pe.fitscore;
			T.geo.THD_QCHISTORY(ip,1) = {pe.qchistory};
			T.geo.THD_PARAMS(ip,1) = {pe.configstr};
		end% for ip
		
		Tlist.THD.cont    = cont1;	
		Tlist.THDTOP.cont = cont2;	
		Tlist.THDBTO.cont = cont3;			
		Tlist.THH.cont    = cont4;
		
		Tlist.THSIG0.cont = cont5;	
		Tlist.THTEMP.cont = cont6;	
		Tlist.THPSAL.cont = cont7;
		Tlist.THBFRQ.cont = cont8;	
		Tlist.THPLPV.cont = cont9;
			
		Tlist.THMWD.cont  = cont10;			
	
		%--- Update transect object
		T = setodata(T,'THD',Tlist.THD);
		T = setodata(T,'THDTOP',Tlist.THDTOP);
		T = setodata(T,'THDBTO',Tlist.THDBTO);
		T = setodata(T,'THH',Tlist.THH);
		
		T = setodata(T,'THSIG0',Tlist.THSIG0);
		T = setodata(T,'THTEMP',Tlist.THTEMP);
		T = setodata(T,'THPSAL',Tlist.THPSAL);
		T = setodata(T,'THBFRQ',Tlist.THBFRQ);
		T = setodata(T,'THPLPV',Tlist.THPLPV);
		
		T = setodata(T,'THMWD',Tlist.THMWD);
		
		
	case 'varrepisot' %-- Variable Representative Isotherm (Fiedler et al, LIMNOL, 2010)
		%--- Init odata objects for output:
		Tlist = data_list_user; % Fast recup of pre-defined variables TH*:		
		cont1 = zeros(size(T,1),1)*NaN;
		cont2 = cont1;
		
		for ip = 1 : size(T,1)
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
			disp(datestr(T.geo.STATION_DATE(ip)));
			pe = varrepisot('dept',z,'temp',T.data.TEMP(ip,:));
			cont1(ip,1) = pe.depth;
			cont2(ip,1) = pe.temp;
			
		end% for ip
		
		Tlist.THD.cont = cont1;	
		Tlist.THTEMP.cont = cont2;	
		
		%--- Update transect object		
		T = setodata(T,'THD',Tlist.THD);		
		T = setodata(T,'THTEMP',Tlist.THTEMP);
		
	case 'infpt' %-- Inflection point (Fiedler et al, LIMNOL, 2010)
		%--- Init odata objects for output:
		Tlist = data_list_user; % Fast recup of pre-defined variables TH*:		
		cont1 = zeros(size(T,1),1)*NaN;
		cont2 = cont1;

		for ip = 1 : size(T,1)
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
			disp(datestr(T.geo.STATION_DATE(ip)));
			pe = infpt('dept',z,'temp',T.data.TEMP(ip,:));
			cont1(ip,1) = pe.depth;
			cont2(ip,1) = pe.temp;

		end% for ip

		Tlist.THD.cont = cont1;	
		Tlist.THTEMP.cont = cont2;	

		%--- Update transect object		
		T = setodata(T,'THD',Tlist.THD);		
		T = setodata(T,'THTEMP',Tlist.THTEMP);
	
	case 'sm' %-- Split and Merge method
		%--- Init odata objects for output:
		Tlist = data_list_user; % Fast recup of pre-defined variables TH*:		
		cont1 = zeros(size(T,1),1)*NaN;
		cont2 = cont1;

		for ip = 1 : 5 : size(T,1)
%		for ip = 5*9 : 5*9
			try
				z = T.geo.DEPH(ip,:);
			catch
				z = T.geo.DEPH(1,:);
			end
			disp(datestr(T.geo.STATION_DATE(ip)));
%			stophere
			pe = splitandmerge('dept',z,'temp',T.data.TEMP(ip,:));
%			cont1(ip,1) = pe.depth;
%			cont2(ip,1) = pe.temp;

		end% for ip

		Tlist.THD.cont = cont1;	
		Tlist.THTEMP.cont = cont2;	

		%--- Update transect object		
		T = setodata(T,'THD',Tlist.THD);		
		T = setodata(T,'THTEMP',Tlist.THTEMP);


	
end% switch 
	
end %functionthd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%- Split-and-merge method (Thompson and Fine, JAOT, 2003; Fiedler et al, LIMNOL, 2010)
function Emax = splitandmerge(varargin) 
	% Creation date: 2012-06-07
	% Author: G. Maze (Ifremer, Laboratoire de Physique des Oceans)

	%-- Defaults parameters:
	monitor = false;
	Emax = 0.005;

	%-- Load arguments (and possibly overwrite defaults parameters):
	if nargin ~= 0
		if mod(nargin,2) ~= 0
			error('Arguments must come in pairs: ARG,VAL')
		end% if 
		for in = 1 : 2 : nargin-1
			eval(sprintf('%s = varargin{in+1};',varargin{in}));
		end% for in
		clear in
	end% if

	%-- Prepare data:
	[x, y] = prepare(dept,temp); % Remove NaN and interpolate
%	x = (x-min(x))./(max(x)-min(x));
%	y = (y-min(y))./(max(y)-min(y));
	
	sx1 = 1./(max(x)-min(x));
	sx2 = -min(x)/(max(x)-min(x));
	x   = x*sx1 + sx2; 
	
	sy1 = 1./(max(y)-min(y));
	sy2 = -min(y)/(max(y)-min(y));
	y   = y*sy1 + sy2;
	
	%-- Step 1 (the split procedure)
	% For an arbitrary initial subset k = 1, 2, … , nr, obtain the polynomial fit and 
	% check to see if the error norm εk for this fit exceeds the imposed limit, ε. 
	% (Here, we can use nr = 2 since the program automatically adjusts to find the 
	% appropriate number of subsets for the specified error norm.) If εk > ε, split 
	% the kth subset into two parts and increment the number of subsets to nr + 1. 
	% The dividing point of the kth subset is determined according to the following 
	% rule: If there are two or more points where the pointwise error is maximum, 
	% then use as a dividing point the midpoint between a pair of them. Otherwise, 
	% divide the segment Sk in half. Calculate the error norms εk on each new interval.
	
		%if monitor		
			figure;figure_tall;
		%end% if 
		
		clear subset
		subset(1) = {1:length(x)};
		done = false; isubset = 1;
		while done ~= true

			% Monitor:
			if monitor
				clf;hold on;iw=1;jw=3;ipl=0;		
				ipl=ipl+1;subp(ipl)=subplot(iw,jw,ipl);hold on
				plot(x,y,'linewidth',2);
				monitor_segments(x,y,subset);
				view(-90,90); grid on, box on;
				title('Start');
			end% if
			 
			% Store the initial segments:
			subset0 = subset;
			
			% Split procedure:
			newsubset = {};
			Errcounter = 0;
			for isubset = 1 : length(subset)
				ix  = subset{isubset};
				Err = step1a(x(ix),y(ix));
				if Err > Emax
					% Split this segment in half:
					ix1 = ix(1):ix(fix(length(ix)/2));
					try
						ix2 = ix1(end)+1:ix(end);
					catch 
						stophere
					end
					newsubset = cat(1,newsubset,{ix1});
					newsubset = cat(1,newsubset,{ix2});
				else
					% Keep this segment:
					newsubset = cat(1,newsubset,{ix});				
					% Errcounter = Errcounter + 1;
					% if (Errcounter == length(subset))
					% 	done = true;
					% end% if 
				end% if

			end% for isubset
			
			% Update subset list after split:
			subset = newsubset;
%			stophere	
			
			% Monitor:
			if monitor
				ipl=ipl+1;subp(ipl)=subplot(iw,jw,ipl);hold on
				plot(x,y,'linewidth',2);
				monitor_segments(x,y,subset);
				view(-90,90); grid on, box on;
				title('After split');
			end% if
			 
			% Merge procedure:
			newsubset = {};	isubset = 1;
			while isubset < length(subset)
				ix1 = subset{isubset};
				ix2 = subset{isubset+1};
				ix  = [ix1 ix2]; 
				Err = step1a(x(ix),y(ix));
				if Err < Emax
					% Merge these segments:
%					disp(sprintf('Merging segments %i with %i',isubset,isubset+1));
					newsubset = cat(1,newsubset,{ix});					
					% If the new first segment is the last one, we need to keep it before ending the while loop:
					if isubset+2 == length(subset)
						newsubset = cat(1,newsubset,{subset{isubset+2}});
					end% if
					% and increment isubset:
					isubset = isubset + 2;			
				else
					% Keep at least the first segment, we don't know yet for the second one:
					newsubset = cat(1,newsubset,{ix1});	
					% Except if the second one is the last one:
					if isubset+1 == length(subset)
						newsubset = cat(1,newsubset,{ix2});
					end% if 		
					% and increment isubset:
					isubset = isubset + 1;		
				end% if 				
			end% for isubset
			
			% Re-Update subset list after merge:
			subset = newsubset;
			
			% Monitor:
			if monitor			
				ipl=ipl+1;subp(ipl)=subplot(iw,jw,ipl);hold on
				plot(x,y,'linewidth',2);
				monitor_segments(x,y,subset);
				view(-90,90); grid on, box on;
				title('After Merge (end)');
			end% if
			 
			% Check if we need to stop the iteration:
			keepworking = false;
			if length(subset0) == length(subset)
				for isubset0 = 1 : length(subset0)
					if length(subset0{isubset0}) == length(subset{isubset0})
						if sum(subset0{isubset0}-subset{isubset0}) ~= 0
							keepworking = true;							
						end% if 
					else
						keepworking = true;
					end% if 
				end% for
			else
				keepworking = true;				
			end% if 
			done = ~keepworking;

		end% for isubset
		
		clf;hold on
		plot(x,y,'linewidth',2);
		monitor_segments(x,y,subset);
		view(-90,90); grid on, box on;
		title('Final segment decomposition');
		suptitle(sprintf('Emax = %0.3f',Emax));

		stophere
		
		%- Now determine thermocline properties:		
		[Err Pcof] = monitor_segments((x-sx2)/sx1,(y-sy2)/sy1,subset);
		
		sl = max(Pcof(Pcof(:,1)~=max(Pcof(:,1)))); % Find the second segment with highest slope
		isubset = find(Pcof(:,1)==sl);
		
		z = (x-sx2)/sx1; % Back to unit vertical axis
		THlayer = z(subset{isubset}); % The main thermocline layer depth range
		THD = mean(THlayer); % The main thermocline depth
		vline(THD)
		
end% function splitandmerge

function [Err pcof] = monitor_segments(x,y,subset)
	for isubset = 1 : length(subset)
		ix = subset{isubset};
		[Err(isubset) pfit pcof(isubset,:)] = step1a(x(ix),y(ix));		
		plot(x(ix),pfit,'r');
		plot(x(ix([1 end])),pfit([1 end]),'.r','markersize',12);
	end% for isubset
end%function

function [Err pfit pcof] = step1a(x,y)
	pcof = polyfit(x,y,1);
	pfit = polyval(pcof,x);
	Err  = ErrNorm(pfit,y);
%	plot(x,pfit,'r');
end%function

function [er erpointwise] = ErrNorm(ref,fct)
	% Define the Error Norm function for splitandmerge
	% Integral square error:
	erpointwise = (fct-ref).^2;
	er = sum(erpointwise);	
end% function


%- Inflection Point method (Fiedler et al, LIMNOL, 2010)
function out = infpt(varargin) 
	% Rev. by Guillaume Maze on 2012-06-07: Not finished !
	
	%-- Define defaults parameters:
	dt  = 0.03;
	
	%-- Load arguments:
	if nargin ~= 0
		if mod(nargin,2) ~=0
			error('Arguments must come in pairs: ARG,VAL')
		end% if 
		for in = 1 : 2 : nargin-1
			eval(sprintf('%s = varargin{in+1};',varargin{in}));
		end% for in
		clear in
	end% if
	
	%-- Output structure:
	out.depth = NaN;
	out.temp  = NaN;

	%-- Squeeze profile to non NaN values:
	iz = ~isnan(temp) & ~isnan(dept);
	if ~isempty(iz)
		temp = temp(iz);
		dept = dept(iz);
	else
		return;
	end% if 
	
	%-- Interpolate:
	z = sort(-2000:20:0,'descend');
	t = interp1(dept,temp,z);
	
	%-- Re-Squeeze profile to non NaN values:
	iz = ~isnan(t) & ~isnan(z);
	if ~isempty(iz)
		t = t(iz);
		z = z(iz);
	else
		return;
	end% if 
	
	
	%-- Standard:
	t = (t - min(t))./(max(t)-min(t));
	z = (z - min(z))./(max(z)-min(z));
	
	%-- 
	clear p pco piz
	isegment = 1;
	iz0 = 1;
	iz1 = iz0+1;
	izC = iz1;
	while izC+1 < length(z)
		p = polyfit(z(iz0:iz1),t(iz0:iz1),1); % t = p(1)*z + p(2)
		
		if abs(t(izC+1) - polyval(p,z(izC+1))) > dt
			ph = plot(polyval(p,z(iz0:izC)),z(iz0:izC),'r');
			pco(isegment,:) = p;
			piz(isegment,:) = [iz0 izC];
			isegment = isegment + 1;
			iz0 = izC;
			iz1 = iz0 + 1;
			izC = iz1;
		else
			izC = izC + 1;
		end% if 
	end% while
	
	stophere
	
end% funntion

%- Variable Representative Isotherm (Fiedler et al, LIMNOL, 2010)
function out = varrepisot(varargin) 
	%-- Define defaults parameters:
	% TT = Thermocline Temperature = T(MLD) - coef*( T(MLD) - T(zref) )
	zref = -400;
	coef = 0.4;
	
	%-- Load arguments:
	if nargin ~= 0
		if mod(nargin,2) ~=0
			error('Arguments must come in pairs: ARG,VAL')
		end% if 
		for in = 1 : 2 : nargin-1
			eval(sprintf('%s = varargin{in+1};',varargin{in}));
		end% for in
		clear in
	end% if
	
	%-- Output structure:
	out.depth = NaN;
	out.temp  = NaN;

	%-- Squeeze profile to non NaN values:
	iz = ~isnan(temp) & ~isnan(dept);
	if ~isempty(iz)
		temp = temp(iz);
		dept = dept(iz);
	else
		return;
	end% if 
	
	%-- More check:
	if zref < min(dept)
		return;
	end% if 
	
	%-- Interpolate on a regular grid
	
	%-- Smoothing
	
	%-- Compute MLD as SST - 0.8
	SST = temp(1); 
	MLD = interp1(temp,dept,SST - 0.8);
	Tmld = interp1(dept,temp,MLD);

	%-- Compute TT
	Tref = interp1(dept,temp,zref);	
	TT   = Tmld - coef*(Tmld-Tref);
	TTz  = interp1(temp,dept,TT);
	
	THDEPTH = mean([MLD TTz]);
	THTEMP  = interp1(dept,temp,THDEPTH);
	
	%-- Output
	out.depth = THDEPTH;
	out.temp  = THTEMP;
		
	%--
	if 0
		clf
		plot(temp,dept);grid on, box on
		hline(zref);vline(Tref); hline(THDEPTH);vline(THTEMP);hline(MLD);vline(Tmld);
	end% if 
	
end% function


function [z,v] = prepare(dept,var1)
	% Creation date: 2012-06-07
	% Author: G. Maze (Ifremer, Laboratoire de Physique des Oceans)

	%-- Defaults parameters:
	
	%-- Squeeze profile to non NaN values:
	iz = ~isnan(dept) & ~isnan(var1);
	if ~isempty(iz)
		dept = dept(iz);
		var1 = var1(iz);
	else
		return;
	end% if 
	
	%-- Interpolate:
	z = sort(-2000:20:0,'descend');
	v = interp1(dept,var1,z);
	
	%-- Re-Squeeze profile to non NaN values:
	iz = ~isnan(z) & ~isnan(v);
	if ~isempty(iz)
		z = z(iz);
		v = v(iz);
	else
		return;
	end% if 
	


end% function prepare
















