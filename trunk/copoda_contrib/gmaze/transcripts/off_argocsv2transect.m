% argocsv2transect Read a CSV argo file and create a transect object
%
% T = argocsv2transect(CSVfile)
% 
% Not working !!!
%
% Created: 2009-11-17.
% Copyright (c) 2009, Guillaume Maze (Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

function varargout = argocsv2transect(varargin)

standardZ = 1; % Move to standard Z levels
matfile = varargin{1}; 
matcte  = load(matfile);

UNIQUE_PLATFORMS = unique(matcte.PLATFORM);
UNIQUE_PLATFORMS = UNIQUE_PLATFORMS(~isnan(UNIQUE_PLATFORMS))

if length(UNIQUE_PLATFORMS) > 1
	D = database;
end

%for iplat = 1 : length(UNIQUE_PLATFORMS)
for iplat = 1:3
	THIS_PLATFORM = UNIQUE_PLATFORMS(iplat);
	
	clear ii UNIQUE_DATE N_LEVELS this_profil
	
	ii = find(ismember(matcte.PLATFORM,THIS_PLATFORM)); % All belong to 1 platforms
	
	%%% For this platform:
	
	% Profiles dates:
	UNIQUE_DATE = unique(matcte.DATE(ii));
	N_PROFS = length(UNIQUE_DATE);
	
	% Determine the number of levels for each profils:
	for it = 1 : N_PROFS
		this_profil = ii(find(ismember(matcte.DATE(ii),UNIQUE_DATE(it)))); % All belong to 1 profil of 1 platform
		N_LEVELS(it) = length(this_profil);
	end
	disp(sprintf('Platform #%i: %i',iplat,THIS_PLATFORM))
	disp(sprintf('\tNumber of profils: %i',N_PROFS));
	disp(sprintf('\tMax Number of levels: %i',max(N_LEVELS)));
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Create transect object
	T = transect();
	
	%%%%%%% Header properties:
	T.file = matfile;
	T.creator = sprintf('%s (login)',getenv('USER'));
	T.source = 'Laboratoire de Physique des Oceans, Brest, France';
	T.created  = datenum(now);
	T.modified = datenum(1900,1,1,0,0,0);
	
	%%%%%%% CRUISE_INFO
	T.cruise_info = cruise_info(...
						'NAME',sprintf('%i (Argo platform #)',THIS_PLATFORM),...
						'SHIP_NAME',sprintf('%i (Argos ID)',unique(matcte.ARGOS_ID(ii))),...
						'DATE',[min(UNIQUE_DATE) max(UNIQUE_DATE)],...
						'N_STATION',N_PROFS...
						...
						);
	
	%%%%%%% AXES
	STATION_NUMBER = matcte.STATION_NUMBER(ii);
	if length(unique(STATION_NUMBER)) == length(ii) 
		% This is probably full of NaN !
		STATION_NUMBER = 1:N_PROFS;
	end	
	
	PRES = get_var('PRES',matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
	LAT  = get_var('LATITUDE',matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
	LON  = get_var('LONGITUDE',matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
	LATITUDE  = LAT(:,1)';
	LONGITUDE = LON(:,1)';	
	MAX_PRESSURE = max(PRES,[],2);
	DEPH = -abs(sw_dpth(PRES,LAT)); clear LAT
	
	if standardZ
		nz = fix(max(abs(DEPH(:))))+1;
		PRES_0 = PRES;
		DEPH_0 = DEPH;
		clear DEPH
		for it = 1 : N_PROFS
			DEPH(it,:) = -nz+1:0;
		end 
		PRES = prs2dep(DEPH,PRES,PRES); % Interpolate at standard depth		
	end
		
	% Move to longitude east from 0 to 360	
	cp0 = LONGITUDE;
	cp0(cp0>=-180 & cp0<0) = 360 + cp0(cp0>=-180 & cp0<0);
	LONGITUDE = cp0;
		
	% Fill it:	
	T.geo = fill_axes(...
				'STATION_DATE',UNIQUE_DATE',...
				'STATION_NUMBER',STATION_NUMBER',...
				'LATITUDE',LATITUDE',...
				'LONGITUDE',LONGITUDE',...
				'POSITIONING_SYSTEM','?',...
				'PRES',PRES,...
				'MAX_PRESSURE',MAX_PRESSURE,...
				'DEPH',DEPH...
				...
				);
	
	%%%%%%% DATAS:
	vv = {'TEMP','PSAL','DOXY'};
	od = struct();
	for iv = 1 : length(vv)		
		[a ik] = intersect(matcte.field_list,vv{iv}); clear a
		C = get_var(vv{iv},matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
		if strcmp(vv{iv},'DOXY')
			varn = 'OXYL';
			sig0 = sw_dens0(get_var('PSAL',matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii),get_var('TEMP',matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii));
			C = convert_unit(C,'OXY',strrep(strrep(matcte.unit_list{ik},'milli','m'),'mole','mol'),'ml/l',sig0);
			unit = 'ml/l';
		else
			varn = vv{iv};
			unit = matcte.unit_list{ik};
		end
		if standardZ			
			C = prs2dep(DEPH_0,PRES_0,C); % Interpolate at standard depth
		end
		parc = par_code(varn);
		od = setfield(od,varn,odata('long_name',parc{1}.name,'name',varn,'unit',unit,'cont',C));
	end%for iv
	
	% Fill it:
	od = orderfields(od);
	T.data = od;
	try
		[res T] = validate(T,0,1);
	end
		
	if exist('D')	
		% Update database object:
		D.transect(iplat) = T;	
	end
	
	
	
end

if exist('D')	
	varargout(1) = {D};
else
	varargout(1) = {T};
end

end %functionargocsv2transect

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function VARO = get_var(VARN,matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);

	if isfield(matcte,sprintf('%s_ADJUSTED',VARN))		
		VARO = mat2prof(sprintf('%s_ADJUSTED',VARN),matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
		if prod(size(VARO)) == length(find(isnan(VARO)==1))
			% This is full of NaN, we drop this for the non-adjusted field:
			VARO = mat2prof(VARN,matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
		end
	else
		VARO = mat2prof(VARN,matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);
	end

end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Move from 1 x N_SAMPLES to N_PROFS x N_LEVELS
function VARO = mat2prof(VARN,matcte,N_PROFS,N_LEVELS,UNIQUE_DATE,ii);

	VARO  = zeros(N_PROFS,max(N_LEVELS)).*NaN;
	for it = 1 : N_PROFS
		this_profil = ii(find(ismember(matcte.DATE(ii),UNIQUE_DATE(it)))); % All belong to 1 profil of 1 platform
		C = getfield(matcte,VARN);
		VARO(it,1:N_LEVELS(it)) = C(this_profil);
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = fill_axes(varargin)
	
	% Init
	A.dummy = '';
	if 0
		% Stations:	
		A.STATION_NUMBER = 0;
		A.STATION_DATE = 0;
		% Lat/Lon:
		A.LATITUDE = 0;
		A.LONGITUDE = 0;
		A.POSITIONING_SYSTEM = '';
		% Vertical axis:
		A.PRES = 0;
		A.MAX_PRESSURE = 0;
		A.DEPH = 0;
	end
	% then modify object using specified values:
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else
			for iprop = 1 : 2 : n
				prop_nam = varargin{iprop};
				prop_val = varargin{iprop+1};
				if check_prop(prop_nam)
					A = setfield(A,prop_nam,prop_val);
				else
					error('Invalid propertie name for axes structure');
				end
			end
		end
	A = rmfield(A,'dummy');
	
	%
	function OK = check_prop(P)
		if 		strcmp(P,'STATION_NUMBER'), OK = true;
		elseif	strcmp(P,'STATION_DATE'), OK = true;
		elseif	strcmp(P,'LATITUDE'), OK = true;
		elseif	strcmp(P,'LONGITUDE'), OK = true;
		elseif	strcmp(P,'POSITIONING_SYSTEM'), OK = true;
		elseif	strcmp(P,'PRES'), OK = true;
		elseif	strcmp(P,'MAX_PRESSURE'), OK = true;
		elseif	strcmp(P,'DEPH'), OK = true;
		else, OK = false;
		end
	end

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cdep = prs2dep(DEPH,PRES,Cprs)
        
	nz   = fix(max(abs(DEPH(:))))+1;
	Cdep = zeros(size(Cprs,1),nz)*NaN;
	for ip = 1 : size(Cprs,1)
		p  = PRES(ip,:);
		c  = Cprs(ip,:);
		il = find(~isnan(p) & ~isnan(c));
		zm = -fix(min(DEPH(ip,il)));
		try 
			c  = interp1(DEPH(ip,il),Cprs(ip,il),-zm+1:0);
		catch
			whos
			figure;pcolor(DEPH);shading flat
			rethrow(lasterror)
		end
		Cdep(ip,1:zm) = c;
	end
        
end%function















