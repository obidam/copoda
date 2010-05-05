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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ARGUMENTS CHECK-IN !
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BUILD THE DATABASE OBJECT:

dfile = sprintf('%s/%s',copoda_readconfig('copoda_data_folder'),db_struct.storefilename);

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
										T = netcdf2transect(file,db_struct.netcdf2transect_opt);	
										[res T] = validate(T,db_struct.validateT(1),db_struct.validateT(2));				
										isec = isec + 1;
										D.transect(isec) = T;
									case {2,10}
										nc = netcdf(abspath(file),'nowrite');
										if ~isempty(nc{'OXYL'}(:,:)) | ~isempty(nc{'OXYK'}(:,:)) 
											if 0
												T = netcdf2transect(file,db_struct.netcdf2transect_opt);
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
											T0 = netcdf2transect(file,db_struct.netcdf2transect_opt);
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
													T = netcdf2transect(file,db_struct.netcdf2transect_opt);
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
													T0  = netcdf2transect(file,db_struct.netcdf2transect_opt);
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
	case 0 % other way to get datas:
	switch db_type
		case {7,11} % Carina
			eval(sprintf('d = carina2database(''%s'');',abspath(db_struct.path(1).val)));
			if db_type == 7      % Whole Atlantic
				D.transect = d.transect; 
				clear d
			elseif db_type == 11 % Restrict to North-Atlantic:
				isec = 0;
				for it = 1 : length(d)
					T = d.transect{it};
					% Select North-Atlantic only:
					stlon = T.geo.LONGITUDE;
					stlat = T.geo.LATITUDE;
					ii = find(stlon>=360-100 & stlon<=360 & stlat>=0 & stlat<= 70);
					if ~isempty(ii)
						T  = reorder(T,1,ii);											
						isec = isec + 1;
						D.transect(isec) = T;
					end%if empty
				end%for it
			end
		case {12,13}
			l=load(db_struct.path(1).val);
			D.transect = l.D.transect;
			tokeepCARINAIDs = [19,22,24,25,29,91,125,130,135,157,171,172];
			for it = 1 : length(l.D)
				for ikeep = 1 : length(tokeepCARINAIDs)
					if strfind(l.D.transect{it}.cruise_info.NAME,sprintf('CARINA #%i',tokeepCARINAIDs(ikeep)))
						tokeep(ikeep) = it;
					end
				end
			end
			D = reorder(D,tokeep);
			clear l
			%keyboard
			% Now restrict to a box:
			switch db_type
				case 12 % Along the Greenland-Scotland Ridge:
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
				x   = extract(D,'LONGITUDE')-360;
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
				stlon = T.geo.LONGITUDE-360;
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

			
		case 8 % Argo-O2 North Atlantic
				eval(sprintf('d = argoO2database;'));
				D.transect = d.transect;
				
		case 9 % All available oxygen !
				eval(sprintf('d = blendallO2database;'));
				D.transect = d.transect;

	end%switch
end%switch db_struct.explore_path

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Final stuff, validation:
if length(D) >= 1
	if isfield(db_struct,'validateD')
		[res D] = validate(D,db_struct.validateD(1),db_struct.validateD(2));
		disp(sprintf('Database %s build and validated successfully !',db_struct.name))
	else
		disp(sprintf('Database %s build successfully !',db_struct.name))
	end
	dfile = sprintf('%s/%s',copoda_readconfig('copoda_data_folder'),db_struct.storefilename);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT
switch nargout
	case 1
		varargout(1) = {D};
end

end %function





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function db_struct = db_list(varargin)
	ii = 0;
	
	ii = ii + 1;
	db_struct(ii).name = 'Hydrocean full (ATL)';
	db_struct(ii).desc = {'The complete LPO hydrocean transects database'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 0;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'ATL';
	
	ii = ii + 1;
	db_struct(ii).name = 'Hydrocean with O2 (NATLO2)';
	db_struct(ii).desc = {'The LPO hydrocean transects database with oxygen datas over the North-Atlantic'};
	db_struct(ii).path(1).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/';
	db_struct(ii).path(2).val = '~/data/HYDROLPO/HYDROCEAN/MLT_NC/LPO/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'NATLO2';
	
	ii = ii + 1;
	db_struct(ii).name = 'OVIDE';
	db_struct(ii).desc = {'Available OVIDE sections'};
	db_struct(ii).path(1).val = '~/data/OVIDE/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 0;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'OVIDE';
	
	ii = ii + 1;
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
	
	ii = ii + 1;
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
	
	ii = ii + 1;
	db_struct(ii).name = 'OVIDE-BIOGEO';
	db_struct(ii).desc = {'Available OVIDE sections with biogeochemical tracers'};
	db_struct(ii).path(1).val = '~/data/OVIDE/';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = 1;
	db_struct(ii).explore_path = 1; % do we enter the loop
	db_struct(ii).storefilename = 'OVIDE_BIOGEO';
	
	ii = ii + 1;
	db_struct(ii).name = 'CARINA Atlantic V1.0';
	db_struct(ii).desc = {'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database, ';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = '~/data/CARINA/data/CARINA.ATL.V1.0.mat';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA_ATL_V1';

	
	ii = ii + 1;
	db_struct(ii).name = 'Argo-O2 North-Atlantic V1.0';
	db_struct(ii).desc = {'All North Atlantic Argo floats equiped with oxygen sensors since 2003/1/1';...
						  'No specific validation but classic methods from database/validate and transect/validate'};
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop ?
	db_struct(ii).storefilename = 'ArgoO2_NATLv1';
	
	
	ii = ii + 1;
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
	
	
	ii = ii + 1;
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
	

	ii = ii + 1;
	db_struct(ii).name = 'CARINA North Atlantic V1.0';
	db_struct(ii).desc = {'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = '~/data/CARINA/data/CARINA.ATL.V1.0.mat';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.NATL.V1.0';	
	
	ii = ii + 1;
	db_struct(ii).name = 'CARINA GSR Region V1.0';
	db_struct(ii).desc = {'Greeland-Scotland Ridge region selection of';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.ATL.V1.0.mat';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.GSR.V1.0';
		
	ii = ii + 1;
	db_struct(ii).name = 'CARINA DS V1.0';
	db_struct(ii).desc = {'Denmark Strait selection of';...
						  'CARBON IN ATLANTIC OCEAN (CARINA): Atlantic Ocean Region Database';'Restricted to the North Atlantic';...
						  'Version 1.0: CARINA.ATL.V1.0, doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'Citation: CARINA Group. 2009. Carbon in the Atlantic Ocean Region - ';...
						  '          the CARINA project: Results and Data, Version 1.0.';...
						  'Source: http://cdiac.ornl.gov/ftp/oceans/CARINA/CARINA_Database/CARINA.ATL.V1.0/';...
						  'Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. ';...
						  'Department of Energy, Oak Ridge, Tennessee. doi: 10.3334/CDIAC/otg.CARINA.ATL.V1.0';...
						  'CARINA Project Main Page: http://cdiac.ornl.gov/oceans/CARINA/Carina_inv.html'};
	db_struct(ii).path(1).val = 'CARINA.ATL.V1.0.mat';
	db_struct(ii).validateD = [1 1]; % option for validate function of database
	db_struct(ii).validateT = [0 1]; % option for validate function of transects
	db_struct(ii).netcdf2transect_opt = NaN;
	db_struct(ii).explore_path = 0; % do we enter the loop
	db_struct(ii).storefilename = 'CARINA.DS.V1.0';	

	
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
	disp_prop('Validation parameters (VERBOSE,FIX)','...');
	disp_prop('Each transect',num2str(db_struct.validateT));
	disp_prop('The database',num2str(db_struct.validateD));
	disp_prop('Storing file',sprintf('~/matlab/copoda/data/%s',db_struct.storefilename));
	disp_prop('Bio tracers option to netcdf2transect routine',num2str(db_struct.netcdf2transect_opt));
	
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%1s %40s: %s',blk,name,value));	
end





























