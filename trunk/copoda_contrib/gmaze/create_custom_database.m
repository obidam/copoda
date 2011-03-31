% create_custom_database Create a predefined database object
%
% D = create_custom_database(DB_TYPE,[INFO])
% 
% This function aims to simplify the construction of a database
% object (type help database for more informations).
% DB_TYPE is an integer specifying the custom database to build.
% To see a list of available custom databases, type:
% 	create_custom_database
%
% Optional parameter INFO is set to 0 by default. If set to 1, the 
% function just print on screen informations about the database of
% type DB_TYPE.
%
% Created: 2009-07-22.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function varargout = create_custom_database(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%- ARGUMENTS CHECK-IN !
switch nargin
	case 0	
		disp('You must specify a database type !');
		disp(sprintf('Create_custom_database: list of available database as of: %s',datestr(now,'mmm. dd yyyy')))
		db_struct = db_list;
		for idb = 1 : length(db_struct)
			disp(sprintf('Database type %i: %s',idb,db_struct(idb).name));
		end %for idb		
		error('Please try again !');
	case 1
		db_type = varargin{1};
		if db_type > length(db_list)
			disp('Unknown database type !');
			disp(sprintf('Create_custom_database: list of available database as of: %s',datestr(now,'mmm. dd yyyy')))
			db_struct = db_list;
			for idb = 1 : length(db_struct)
				disp(sprintf('Database type %i: %s',idb,db_struct(idb).name));
			end %for idb
			error('Please try again !');
		else
			db_struct = db_list(db_type);
			disp(sprintf('Building database type %i: %s',db_type,db_struct.name));
			disp_db(db_type);
		end
	case 2
		db_type = varargin{1};
		prt_inf = varargin{2};		
		if db_type > length(db_list)
			disp('Unknown database type !');
			disp(sprintf('Create_custom_database: list of available database as of: %s',datestr(now,'mmm. dd yyyy')))
			db_struct = db_list;
			for idb = 1 : length(db_struct)
				disp(sprintf('Database type %i: %s',idb,db_struct(idb).name));
			end %for idb
			error('Please try again !');
		elseif prt_inf == 1
			db_struct = disp_db(db_type);
			if nargout == 1
				varargout(1) = {db_struct};
			end
			return
		else
			error('Invalid options');
		end
		
	otherwise
		disp('You must specify a database type !');
		disp(sprintf('Create_custom_database: list of available database as of: %s',datestr(now,'mmm. dd yyyy')))
		db_struct = db_list;
		for idb = 1 : length(db_struct)
			disp(sprintf('Database type %i: %s',idb,db_struct(idb).name));
		end %for idb
		error('Please try again !');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%- BUILD THE DATABASE OBJECT
try
	dfile = sprintf('%s/%s',copoda_readconfig('copoda_userdata_folder'),db_struct.storefilename);
catch
	dfile = sprintf('%s/%s',copoda_readconfig('copoda_data_folder'),db_struct.storefilename);	
end
if exist(sprintf('%s.mat',dfile),'file')
	disp(sprintf('\nThis database seems to already exists here:\n\t%s.mat',dfile));
	d = dir(sprintf('%s.mat',dfile));
	disp(sprintf('\tLast touch: %s',d.date));
	r = input(sprintf('Do you want to reconstruct ''%s'' or just load it (r/[l]) ?',db_struct.name),'s');
	switch lower(r)
		case 'r'
			% No stop here, we continue
		case {'','l'}
			load(sprintf('%s.mat',dfile));
			switch nargout
				case 1
					varargout(1) = {D};
			end
			return
		otherwise
			error('Choices are ''r'' to reconstruct or ''l'' to load !');
	end
end

% Create database object and init some parameters:
D = database;
D.creator = getenv('USER');
D.name = db_struct.name;
D.description = db_struct.desc;

switch db_struct.explore_path
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	%-- PROCESS THE 'LOOP'
	case 1 % We explore path and subfolders
	
		% Paths to explore:
		data_path = db_struct.path;

		% Explore and get the list of transect objects from netcdf files with netcdf2transect.m:
		isec = 0 ; ii = 0;
		for ipath = 1 : size(data_path,2)
	
			disp(sprintf('Scanning: %s',data_path(ipath).val));
			di = dir(data_path(ipath).val);
			di = di(3:end);
			for idir = 1 : size(di,1)	
				if di(idir).isdir
					dir_di = dir(sprintf('%s%s',data_path(ipath).val,di(idir).name));
					for isubdir = 1 : size(dir_di,1)
						if ~dir_di(isubdir).isdir							
							if strfind(dir_di(isubdir).name,'_dep.nc')
								disp(sprintf('\t\t%s %s/%s',data_path(ipath).val,di(idir).name,dir_di(isubdir).name));
								ii = ii + 1;
								%disp(dir_di(isubdir).name)
								file = sprintf('%s%s/%s',data_path(ipath).val,di(idir).name,dir_di(isubdir).name);
								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
								switch db_type
									case 1
										T = hydrocean2transect(file,db_struct.netcdf2transect_opt);	
										[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));				
										isec = isec + 1;
										D.transect(isec) = T;
									case {2,10}
										nc = netcdf(abspath(file),'nowrite');
										if ~isempty(nc{'OXYL'}(:,:)) | ~isempty(nc{'OXYK'}(:,:)) 
											if 0
												T = hydrocean2transect(file,db_struct.netcdf2transect_opt);
												% Select North-Atlantic only:
												stlon = T.geo.LONGITUDE;
												stlat = T.geo.LATITUDE;
												ii = find(stlon>=360-100 & stlon<=360 & stlat>=0 & stlat<= 70);
												if ~isempty(ii)
													T  = reorder(T,1,ii);											
													[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));
													if db_type == 10
														[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2),12);												
													end
													isec = isec + 1;
													D.transect(isec) = T;
												end
											else
												T = hydrocean2transect(file,db_struct.netcdf2transect_opt);
												figure(1);clf;plot(T,'track');title(T.file,'interpreter','none');
												pause												
											end
										end
										close(nc);clear nc									
									case {3,6}
										nc = netcdf(abspath(file),'nowrite');
										if ~isempty(nc{'OXYL'}(:,:)) | ~isempty(nc{'OXYK'}(:,:)) 
											T0 = hydrocean2transect(file,db_struct.netcdf2transect_opt);
											ind = hydro_extract_transects(T0.cruise_info.NAME,T0.geo.LONGITUDE,T0.geo.LATITUDE);
											if strfind(T0.cruise_info.NAME,'74AB62_1'), ind = ind(1); end
											for ileg = 1 : size(ind,2)
												ij = ind(ileg).val;
												T = reorder(T0,1,ij);
												[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));
												isec = isec + 1;
												D.transect(isec) = T;
											end
										end
										close(nc);clear nc	
									case 4
										fil = db_struct.include; done = 0;
										for ik = 1 : length(fil)
											if strcmp(file,fil{ik}) & done == 0
												nc = netcdf(abspath(file),'nowrite');
												if ~isempty(nc{'OXYL'}(:,:)) | ~isempty(nc{'OXYK'}(:,:)) 
													T = hydrocean2transect(file,db_struct.netcdf2transect_opt);
													[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));
													isec = isec + 1;
													D.transect(isec) = T;
												end
												close(nc);clear nc
												done = 1;
											end
										end
									case 5
										fil = db_struct.include; done = 0;
										for ik = 1 : length(fil)
											if strcmp(file,fil{ik}) & done == 0
												nc = netcdf(abspath(file),'nowrite');
												if ~isempty(nc{'OXYL'}(:,:)) | ~isempty(nc{'OXYK'}(:,:)) 
													T0  = hydrocean2transect(file,db_struct.netcdf2transect_opt);
													ind = hydro_extract_transects(T0.cruise_info.NAME,T0.geo.LONGITUDE,T0.geo.LATITUDE);
													if strfind(T0.cruise_info.NAME,'74AB62_1'), ind = ind(1); end
													for ileg = 1 : size(ind,2)
														ij = ind(ileg).val;
														T = reorder(T0,1,ij);
														[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));
														isec = isec + 1;
														D.transect(isec) = T;
													end
												end
												close(nc);clear nc
												done = 1;
											end
										end	
								end
								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%						if isec == 10, return,end
								clear file x y z ship p p_qc T
					
							end%if is a section file				
						end%if is a file
					end%for isubdir
					clear dir_di
				end% if is a dir
			end%for idir
			clear di idir ikeep isubdir ikeep

		end %for ipath

		disp(sprintf('Retained %i over %i files for database name: %s',isec,ii,db_struct.name));
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	%-- NO 'LOOP'
	case 0 % other way to get datas:
	switch db_type
		case 7 % CARINA Whole Atlantic without Mediterranean Sea
			d = webcarina2database('AREA','ATL','VERSION','v1.0');
			% pxv = [	252.6689, 314.0878,354.8311,395.5743,398.6149,379.7635,365.1689,...
			% 		354.8311, 356.0473,376.1149,382.1959,386.4527,272.1284,245.9797,252.6689];
			% pyv = [  40.7432,76.0135,86.3514, 83.3108, 58.3784, 50.4730, 46.8243, 38.9189,...
			% 		31.6216, 6.6892,  -24.3243, -80.8784, -82.0946, -21.8919,40.7432];
			% for it = 1 : length(d)
			% 	T = d.transect{it};
			% 	stlon = T.geo.LONGITUDE; stlon(stlon>=0 & stlon<=180) = stlon(stlon>=0 & stlon<=180) + 360;
			% 	stlat = T.geo.LATITUDE;
			% 	tokeep = inpolygon(stlon,stlat,pxv,pyv);
			% 	ii = find(tokeep==1);
			% 	if ~isempty(ii)
			% 		T  = reorder(T,1,ii);											
			% 		d.transect(it) = T;
			% 		torem(it) = false;
			% 	else
			% 		torem(it) = true;
			% 	end%if empty
			% end%for it
			% if ~isempty(find(torem==true))
			% 	d = reorder(d,find(torem==false));
			% end
			D.transect = d.transect; 
			clear d
		case {11,15} % North-Atlantic without Mediterranean Sea
			l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),'CARINA.ATL.V1.0.mat'));
			 % We load the full Atlantic without Mediterranean Sea database first 		
			D.transect = l.D.transect;clear l
%			pxv = [0 360 360 0 0];
			pxv = [-180 180 180 -180 -180];
			pyv = [0  0  90 90 0];
			D = cut(D,[pxv;pyv]);
		case {12,13}
			keyboard
%			l = load(db_struct.path(1).val); % We load the full North Atlantic database first
			l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),db_struct.path(1).val));			
			D.transect = l.D.transect;
			% tokeepCARINAIDs = [19,22,24,25,29,91,125,130,135,157,171,172];
			% for it = 1 : length(l.D)
			% 	for ikeep = 1 : length(tokeepCARINAIDs)
			% 		if strfind(l.D.transect{it}.cruise_info.NAME,sprintf('CARINA #%i',tokeepCARINAIDs(ikeep)))
			% 			tokeep(ikeep) = it;
			% 		end
			% 	end
			% end
			% D = reorder(D,tokeep);
			% clear l
			%keyboard
			% Now restrict to a box:
			switch db_type
				case {12,16} % Along the Greenland-Scotland Ridge:
					pxv = [-40 -14 -4 8 -22 -40];
					pyv = [66 57 56 62 71 66];
				case 13 % Denmark Strait
					pxv = [-34 -30 -20 -22 -34];
					pyv = [66 63.9 65 71 66];
				
			end
			if 1 % Plot a map to explain what we did
				ff=figure;hold on
				m_proj('equid','lon',[-45 10],'lat',[50 75]);
				m_coast;m_grid('xtick',[-180:2:180],'ytick',[50:1:90],'fontsize',7)
				m_elev('contour',[-1e4:200:-10]);
				x   = extract(D,'LONGITUDE');
				y   = extract(D,'LATITUDE');
				m_plot(x,y,'k.')
				tokeep = inpolygon(x,y,pxv,pyv);
				m_plot(x(tokeep),y(tokeep),'r.')
				m_line(pxv,pyv,'linewidth',2)
				title(sprintf('In black what we selected from CARINA ATL V1.0\nand in red what we kept'))
				drawnow
			end
			for it = 1 : length(D)
				T = D.transect{it};
				stlon = T.geo.LONGITUDE;
				stlat = T.geo.LATITUDE;
				tokeep = inpolygon(stlon,stlat,pxv,pyv);
				ii = find(tokeep==1);
				if ~isempty(ii)
					T  = reorder(T,1,ii);											
					D.transect(it) = T;
					torem(it) = false;
				else
					torem(it) = true;
				end%if empty
			end%for it
			if ~isempty(find(torem==true))
				D = reorder(D,find(torem==false));
			end
			
		case {14,16,19} % Cut to stations with oxygen
			l = load(db_struct.path(1).val); % We load the initial database first
			d = l.D;			
				% 1st remove for each transect stations without oxygen:
				for it = 1 : length(d)
					t = d(it);
					[res t] = validate(t,1,1,13);
					d.transect(it) = t;
				end
				% 2nd remove transect without oxygen data:
				for it = 1 : length(d)
					if isdata(d(it),'OXYK') | isdata(d(it),'OXYL')
						tokeep(it) = true;
					else
						tokeep(it) = false;
					end
				end
				if length(find(tokeep==false)) == length(d)
					error('I can''t create this database');
				else
					d = reorder(d,find(tokeep==true));
				end
			D.transect = d.transect;
		
		case 8 % Argo-O2 North Atlantic
			l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),'ArgoO2_NASTG.mat'));
			D.transect = l.d.transect; clear l
				
		case 9 % All available oxygen !
			eval(sprintf('d = blendallO2database;'));
			D.transect = d.transect;
			
		case 17 % Argo-O2 North Pacific
			l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),'ArgoO2_NPSTG.mat'));
			D.transect = l.D.transect; clear l
			
		case 18 % All CARINA
			it = 0;
			for ii = 1 : length(db_struct.path)
				l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),db_struct.path(ii).val));
				for ij = 1 : length(l.D)
					it = it + 1;
					D.transect{it} = l.D(ij);
				end
				clear l
			end
			
		case 20  % Selection for IBM
			l = load(fullfile(copoda_readconfig('copoda_userdata_folder'),db_struct.path(1).val));			
%			it = [83   166    95   111   134   136   157    88    84    20	55 142 78];
			it = [83   166    95   111   134   136   157    88    84 55 142 78 53];
			D.transect = l.D(it);
			%stophere
			% Cut extra stations to keep trans-basin stations:
			for ii=1:length(it)
				switch it(ii)
					case 83
						px = [-30.4674  -24.1243  -18.0906  -12.6758   -8.3439   -5.7139   -5.7139  -15.1511  -32.0145  -38.2029  -45.1648  -47.4854  -42.0706  -38.5123  -33.2522  -30.4674];
						py = [ 59.8518   63.2565   65.0049   60.4959   58.6555   56.9992   41.5399   39.9756   40.7117  49.4536   58.0114   61.6002   62.1523   60.1278   58.4715   59.8518];
						D.transect{ii} = cut(D(ii),[px;py]);
					case 166
						T = D(ii);
						px =  [-180 -9.2679   -7.6092   -9.4537   -9.4404  -11.2451  -180];
						py =  [37 37.1319   37.1643   35.5661   33.7952   33.7844     37];
						T = cut(T,[px;py]);
						T = reorder(T,1,setdiff(1:size(T,1),find(T.geo.STATION_NUMBER==99)));
						for k=3:9
							T = reorder(T,1,setdiff(1:size(T,1),find(T.geo.STATION_NUMBER==k)));
						end
						D.transect{ii} = T;
					case 95
						T = D(ii);
						T = reorder(T,1,find(T.geo.STATION_DATE < datenum(1998,5,27)));
						D.transect{ii} = T;
					case 134
						px = [ -13.6797  -11.6386   -1.9699   -5.1928   -8.9528  -13.6797];
						py = [ 64.5691   64.9124   59.5342   59.0002   60.6022   64.5691];
						D.transect{ii} = cut(D(ii),[px;py]);
					case 88
						T = D(ii);
						T = reorder(T,1,find(T.geo.STATION_DATE < datenum(1997,11,2) | T.geo.STATION_DATE > datenum(1997,11,5)));
						D.transect{ii} = T;
					case 84
						px = [-25.3707  -21.8054  -26.7549  -30.6558  -28.0972  -25.3707];
						py = [   68.7240   67.0111   65.5715   67.0657   67.9951   68.7240];
						D.transect{ii} = cut(D(ii),[px;py]);
					case 55
						px = [ -45.5642  -45.7114    6.1162    7.2941  -45.5642];
						py = [   48.7929   62.9543   63.6868   48.3046   48.7929];
						D.transect{ii} = cut(D(ii),[px;py]);						
					case 78
						px = [  -55.7518  -45.5705  -45.3613  -43.5482  -43.6180  -55.7518];
						py = [   48.6907   53.3519   60.4067   60.4067   44.5335   48.6907];
						D.transect{ii} = cut(D(ii),[px;py]);						
				end%switch
			end%for ii
			D = cut(D,[-180 180 180 -180 -180;30 30 90 90 30]);
%			stophere
	end%switch
end%switch db_struct.explore_path

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%- FINAL STUFF AND DATABASE VALIDATION
if length(D) >= 1
	if isfield(db_struct,'validateD')
		try
			[res D] = validate(D,db_struct.validateD{:});
		catch
			[res D] = validate(D,db_struct.validateD(1),db_struct.validateD(2));
		end
		disp(sprintf('Database %s build and validated successfully !',db_struct.name))
	else
		disp(sprintf('Database %s build successfully !',db_struct.name))
	end
	dfile = fullfile(copoda_readconfig('copoda_userdata_folder'),db_struct.storefilename);
	if exist(sprintf('%s.mat',dfile),'file')
		disp(sprintf('\nWarning: You''re trying to save the database in an already existing file ! here:'));
		disp(sprintf('%s.mat',dfile));
		r = input(sprintf('Do you want to:\n\t 1- overwrite this file\n\t 2- select another output file\n\t 3- not save the just build database ?\n'),'s');
		switch r
			case '1'
				save(sprintf('%s.mat',dfile),'D');				
			case '2'
				dfile = input(sprintf('Please enter a new file (without the .mat extension) path:\n\t'),'s');
				save(sprintf('%s.mat',dfile),'D');				
			case '3'
				disp('Skipped saving');
			otherwise
				disp('Skipped saving');
		end
	else
		save(sprintf('%s.mat',dfile),'D');				
		disp(sprintf('This database was saved here:\n%s.mat',dfile));
	end	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%- OUTPUT
switch nargout
	case 1
		varargout(1) = {D};
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function db_struct = db_list(varargin)
	ii = 0;
	
	ii = ii + 1; %-- 1: Hydrocean full (ATL)
	db_struct(ii).name = 'Hydrocean full (ATL)';
	db_struct(ii).desc = {'The complete LPO hydrocean transects database'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 0;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'ATL';
	
	ii = ii + 1; %-- 2: Hydrocean with O2 (NATLO2)
	db_struct(ii).name = 'Hydrocean with O2 (NATLO2)';
	db_struct(ii).desc = {'The LPO hydrocean transects database with oxygen datas over the North-Atlantic'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'NATLO2';
	
	ii = ii + 1; %-- 3: OVIDE
	db_struct(ii).name = 'OVIDE';
	db_struct(ii).desc = {'Available OVIDE sections'};
	db_struct(ii).path(1).val = '~/data/OVIDE/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 0;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'OVIDE';
	
	ii = ii + 1; %-- 4: Hydrocean with O2 (NATLO2-SPG)
	db_struct(ii).name = 'Hydrocean with O2 (NATLO2-SPG)';
	db_struct(ii).desc = {'A selection of North Atlantic transects with oxygen';...
							'datas and located in the subpolar gyre'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).include = custom_list(1);
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 0;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'NATL_SPG';
	
	ii = ii + 1; %-- 5: Hydrocean with O2 (NATLO2-SPG-IRM-ICE)
	db_struct(ii).name = 'Hydrocean with O2 (NATLO2-SPG-IRM-ICE)';
	db_struct(ii).desc = {'A selection of North Atlantic transects with oxygen datas,';...
						  'located in the subpolar gyre and overlapping the OVIDE track.';...
						  'Each transects are splitted using function hydro_extract_transects,';...
						  'so that transects object corresponds to 1 leg for analysis.'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
%	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).path(2).val = '~/data/OVIDE/';
	db_struct(ii).include = custom_list(2);
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'NATL_SPG_IRM_ICE';
	
	ii = ii + 1; %-- 6: OVIDE-BIOGEO
	db_struct(ii).name = 'OVIDE-BIOGEO';
	db_struct(ii).desc = {'Available OVIDE sections with biogeochemical tracers'};
	db_struct(ii).path(1).val = '~/data/OVIDE/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'OVIDE_BIOGEO';
	
	ii = ii + 1; %-- 7: CARINA Atlantic V1.0
	db_struct(ii).name = 'CARINA Atlantic V1.0';
	db_struct(ii).desc = {'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database, ';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = '';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.ATL.V1';

	
	ii = ii + 1; %-- 8: Argo-O2 North-Atlantic V1.0
	db_struct(ii).name = 'Argo-O2 North-Atlantic V1.0';
	db_struct(ii).desc = {'All North Atlantic Argo floats equiped with oxygen sensors since 2003/1/1';...
						  'No specific validation but classic methods from database/validate and transect/validate'};
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop ?
	db_struct(ii).storefilename = 'ArgoO2-NA';
	
	
	ii = ii + 1; %-- 9: LPO-O2 North-Atlantic V1.0
	db_struct(ii).name = 'LPO-O2 North-Atlantic V1.0';
	db_struct(ii).desc = {'All available oxygen datas over the North Atlantic';...
						  'From:';...
						  '	-Degraded Hydrocean with O2 (NATLO2lr)';...
						  '	-OVIDE_BIOGEO';...
						  '	-CARINA North Atlantic V1.0';...
						  '	-Argo-O2 North-Atlantic V1.0';...
						  'No specific validation but classic methods from database/validate and transect/validate'};
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop ?
	db_struct(ii).storefilename = 'LPOO2_NATLv1';
	
	
	ii = ii + 1; %-- 10: Degraded Hydrocean with O2 (NATLO2lr)
	db_struct(ii).name = 'Degraded Hydrocean with O2 (NATLO2lr)';
	db_struct(ii).desc = {'The LPO hydrocean transects database with oxygen datas';...
	 					  'North-Atlantic only';'Vertical resolution is reduced from 1m to 10m'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database    verboxe ? /fixe ? 
	db_struct(ii).validateT = [0 1]; % option for validate function of transects   verboxe ? /fixe ? 
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'NATLO2lr';
	global validate_transect_Zgrid
		validate_transect_Zgrid.ztop   = 0;
		validate_transect_Zgrid.zbot   = -5500;
		validate_transect_Zgrid.dz     = -10;
		validate_transect_Zgrid.method = 'linear';
	

	ii = ii + 1; %-- 11: CARINA North Atlantic V1.0
	db_struct(ii).name = 'CARINA North Atlantic V1.0';
	db_struct(ii).desc = {'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.ATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.NATL.V1.0';	
	
	ii = ii + 1; %-- 12: CARINA GSR Region V1.0
	db_struct(ii).name = 'CARINA GSR Region V1.0';
	db_struct(ii).desc = {'CARINA stations in the Greeland-Scotland Ridge region';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.NATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.GSR.V1.0';
		
	ii = ii + 1; %-- 13: CARINA DS V1.0
	db_struct(ii).name = 'CARINA DS V1.0';
	db_struct(ii).desc = {'CARINA stations in the Denmark Strait region';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.NATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.DS.V1.0';	

	ii = ii + 1; %-- 14: CARINA-O2 Atlantic V1.0
	db_struct(ii).name = 'CARINA-O2 Atlantic V1.0';
	db_struct(ii).desc = {'CARINA Atlantic V1.0 stations with oxygen datas';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database, ';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.ATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINAO2.ATL.V1.0';
	
	ii = ii + 1; %-- 15: CARINA-O2 North Atlantic V1.0
	db_struct(ii).name = 'CARINA-O2 North Atlantic V1.0';
	db_struct(ii).desc = {'CARINA stations with oxygen datas in the North Atlantic';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database, ';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINAO2.ATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINAO2.NATL.V1.0';	
	
	ii = ii + 1; %-- 16: CARINA-O2 GSR Region V1.0
	db_struct(ii).name = 'CARINA-O2 GSR Region V1.0';
	db_struct(ii).desc = {'CARINA stations in the Greeland-Scotland Ridge region with Oxygen datas';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.GSR.V1.0.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINAO2.GSR.V1.0';
	
	
	ii = ii + 1; %-- 17: Argo-O2 North-Pacific V1.0
	db_struct(ii).name = 'Argo-O2 North-Pacific V1.0';
	db_struct(ii).desc = {'All North Pacific Argo floats equiped with oxygen sensors since 2003/1/1';...
						  'No specific validation but classic methods from database/validate and transect/validate'};
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop ?
	db_struct(ii).storefilename = 'ArgoO2-NP';
	
	
	ii = ii + 1; %-- 18: CARINA Complete
	db_struct(ii).name = 'CARINA';
	db_struct(ii).desc = {'Blend of CARINA Atlantic, Southern Ocean and Arctic Mediterranean Seas Regions';...
						  'Atlantic Ocean: Version 1.0: doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Arctic Mediterranean Seas Region: Version 1.2: doi: 10.3334/CDIAC/otg.CARINA.AMS.V1.2';...
						  'Southern Ocean: Version 1.1: doi: 10.3334/CDIAC/otg.CARINA.SO.V1.1';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.ATL.V1.0.mat'; % We sub-select from this one
	db_struct(ii).path(2).val = 'CARINA.AMS.V1.2.mat'; % We sub-select from this one	
	db_struct(ii).path(3).val = 'CARINA.SO.V1.1.mat'; % We sub-select from this one
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA';
	
	ii = ii + 1; %-- 19: CARINA Complete with Oxygen datas
	db_struct(ii).name = 'CARINAO2';
	db_struct(ii).desc = {'Blend of CARINA Atlantic, Southern Ocean and Arctic Mediterranean Seas Regions';...
						  'Only stations with Oxygen datas';...
						  'Atlantic Ocean: Version 1.0: doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Arctic Mediterranean Seas Region: Version 1.2: doi: 10.3334/CDIAC/otg.CARINA.AMS.V1.2';...
						  'Southern Ocean: Version 1.1: doi: 10.3334/CDIAC/otg.CARINA.SO.V1.1';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.mat'; % We sub-select from this one
	db_struct(ii).validateD = {1,1,[1 2]}; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINAO2';
	
	ii = ii + 1; %-- 20: Selection for inverse box model in the NE Atl
	db_struct(ii).name = 'Selection for IBM';
	db_struct(ii).desc = {'Hydrographic sections selection to conduct an inverse';...
						'box model analysis over the northern northeast Atlantic'};
	db_struct(ii).path(1).val = 'CARINAO2.mat'; % We sub-select from this one
	db_struct(ii).validateD = {1,1,[1 2 3]}; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'IBM_v0';	
 	
	if nargin ~=0
		db_struct = db_struct(varargin{1});
	end
	
end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fil = custom_list(varargin)
	
	switch varargin{1}
		case 1
			ii = 0;	
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E94_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A16N/A16N_03_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A16N/A16N_88_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A24/A24_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A25/A25_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E90_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91A_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91B_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E92_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E97_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07W/AR07W94_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07W/AR07W96_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07W/AR07W97_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07W/AR07W98_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR18/AR18_92_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/D223/d223_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/HUDSON95011/hudson95011_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/KNORR104/m35w_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/KNORR147/kn147_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/KNORR154/kn154_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/METEOR392/meteor392_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/METEOR394/meteor394_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/BORDEST/bst2_leg1_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid02_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid04_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/TOPOGULF/tpg4_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/TOPOGULF/tpg5_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid06_dep.nc';
			
		case 2
			ii = 0;
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E94_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A25/A25_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91A_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91B_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E92_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E97_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/HUDSON95011/hudson95011_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/KNORR147/kn147_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/METEOR394/meteor394_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid02_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid04_dep.nc';
			% ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid06_dep.nc';
			
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91A_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E91B_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E92_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E94_dep.nc';
			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/AR07E/AR07E97_dep.nc';
%			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid02_dep.nc';
%			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid04_dep.nc';
%			ii=ii+1;fil{ii} = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/OVIDE/ovid06_dep.nc';
			ii=ii+1;fil{ii} = '~/data/OVIDE/data/ovid02_dep.nc';
			ii=ii+1;fil{ii} = '~/data/OVIDE/data/ovid04_dep.nc';
			ii=ii+1;fil{ii} = '~/data/OVIDE/data/ovid06_dep.nc';
			
			
			
	end %switch
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [db_struct] = disp_db(db_type)
		
	db_struct = db_list(db_type);
	disp_prop(sprintf('Information about database type %i',db_type),'');
	disp_prop('Name',db_struct.name);	
	disp_prop('Description',db_struct.desc{1});
	for il = 2 : length(db_struct.desc)
		disp_prop('',db_struct.desc{il});
	end
%	disp_prop('Description',db_struct.desc);
	disp_prop('Path to explore','...');		
	for ipath = 1 : size(db_struct.path,2)
		disp_prop(['#' num2str(ipath)],db_struct.path(ipath).val);
	end
	if isfield(db_struct,'include')
		if ~isempty(db_struct.include)
			disp_prop('File list to include','...');	
			fil = db_struct.include;	
			for ifile = 1 : length(fil)
				disp_prop(['#' num2str(ifile)],fil{ifile});
			end
		end
	end
	disp_prop('Validation parameters (VERBOSE,FIX,TESTS LIST)','...');
	disp_prop('Each transect',num2str(db_struct.validateT));
	try
		disp_prop('The database',num2str(cell2mat(db_struct.validateD)));
	catch
		disp_prop('The database',num2str(db_struct.validateD));
	end
%	disp_prop('Storing file',);
	try
		dfile = evalin('caller','dfile');
	catch
		dfile = sprintf('~/matlab/copoda/data/%s',db_struct.storefilename);
	end
	disp_prop('Storing file',dfile);
	disp_prop('Bio tracers option to netcdf2transect routine',num2str(db_struct.netcdf2transect_opt));
	
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%1s %40s: %s',blk,name,value));	
end





























