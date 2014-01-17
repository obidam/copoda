% hydrocean2transect Create a transect object from a HYDROCEAN netcdf file
%
% T = hydrocean2transect(netcdf_file,[BIO])
% 
% This function creates a transect object from a HYDROCEAN netcdf file.
% HYDROCEAN is the database collecting hydrographic (CTD) datas at LPO, Ifremer, Brest.
% Intranet webpage: http://w3.ifremer.fr/lpo/base_hydro/hydrocean.htm
%
% Inputs:
%	netcdf_file (string): absolute path to the netcdf file (multistation format).
%		Tip: you can use the direct url from the intranet, like:
%			T = hydrocean2transect('http://w3.ifremer.fr/lpo/base_hydro/mlt/<NETCDFFILE>')
%			In this case, using the system command 'wget', the function downloads the file
%			in the copoda_readconfig('copoda_userdata_folder') folder.
%			
%	BIO (0/1): try to fil in with biogeochemical tracers the transect object (default=0).
%
% Examples:
%	T = hydrocean2transect('~/data/HYDROLPO/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/A01E91_dep.nc')
%	T = hydrocean2transect('http://w3.ifremer.fr/lpo/base_hydro/mlt/A20_97_dep.nc')
%
% Tip:
%	Calling the function without an argument will open the intranet webpage in your browser.
%
% Created: 2010-04-30.
% Rev. by Guillaume Maze on 2014-01-06: Open webpage without argument
% Rev. by Guillaume Maze on 2013-11-28: Downloaded files are placed into the user data folder (copoda_userdata_folder)
% Rev. by Guillaume Maze on 2013-11-28: Now uses Matlab builtin netcdf library by default 
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Tags for documentation:
%TAGS user-level,transcript,netcdf,hydro,hydrocean,lpo

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

function T = hydrocean2transect(varargin)
	
switch nargin
	case 0
		% List all files
		web('http://w3.ifremer.fr/lpo/base_hydro/campagnes.htm','-browser');
		web('http://w3.ifremer.fr/lpo/base_hydro/mlt','-browser');
		return
	otherwise	
		% Load a file
		T = hydrocean2transect_builtin(varargin{:});	
	%	T = hydrocean2transect_tiers(varargin{:});
end%switch
	
end% function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- This version uses the Matlab builtin netcdf library
function T = hydrocean2transect_builtin(varargin)
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	% Init transect object:
	nc_file  = varargin{1};
	nc_file  = abspath(nc_file);
	nc_file0 = nc_file; % We keep the initial file name

	% Do we load biogeochemical tracers ?
	if nargin == 2
		do_biogeo = varargin{2};
	else	
		do_biogeo = 0;
	end

	% Here we insert the possibility to download data from the intranet
	% if we find 'http' in nc_file
	if ~isempty(strfind(nc_file,'ftp://')) | ~isempty(strfind(nc_file,'http://'))
		try
			userdata_folder = copoda_readconfig('copoda_userdata_folder');
			[PATHSTR,NAME,EXT] = fileparts(nc_file);
			local_ncfile = fullfile(userdata_folder,sprintf('%s%s',NAME,EXT));
	%		local_ncfile = fullfile(userdata_folder,'hydrocean_tempo_file.nc');
			system(sprintf('wget -O %s ''%s''',local_ncfile,nc_file));
			disp(sprintf('COPODA saved this remote file:\n\t%s\ninto:\n\t%s',nc_file,local_ncfile));		
			% If we made it through here, we can change the nc_file value:
			nc_file = local_ncfile;
		catch
			error('You asked for an online netcdf file I couldn''t download !');
		end
		clear userdata_folder PATHSTR NAME EXT
	end

	% Open netcdf file
	ncid    = netcdf.open(nc_file);
	varlist = ncvarname(ncid);
	if ncid < 0
		error('Badly open netcdf file, please double check it ...')
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Init transect object and fill in header properties:
	T          = transect;
	%T.file     = nc_file0;
	T.file     = nc_file;
	finfo = dir(nc_file);
	T.file_date = finfo.datenum;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Cruise informations:
	NAME = '?'; CRUISE_NAME = '?';	PI_NAME= '?';	PI_ORGANISM= '?';	SHIP_NAME= '?';	SHIP_WMO_ID= '?'; % Declare variables to avoid dynamic assignment
	plist_f = {'CRUISE_NAME','PI_NAME','PI_ORGANISM','SHIP_NAME','SHIP_WMO_ID'}; % in netcdf file
	plist_d = {'NAME','PI_NAME','PI_ORGANISM','SHIP_NAME','SHIP_WMO_ID'}; % in cruise_info
	
	for ii = 1 : length(plist_f)
		try 
			prop = plist_f{ii};
			val  = deblank(netcdf.getVar(ncid,netcdf.inqVarID(ncid,prop),[0 1],[16 1])');
%			assignin('caller',plist_d{ii},val)
			eval(sprintf('%s = val;',plist_d{ii}));
		catch
			% if those properties are not mandatory to create a transect, throw a warning:
			warning(sprintf('I encountered a problem with variable %s in this netcdf file (probably not found),\nso I set it to an empty string in cruise_info.',prop));
			% oterhwise, throw an error:
%			error(sprintf('Cannot read cruise informations from this netcdf file (variable %s not found)',prop));			
		end%try
	end% for ii
	
	try
		DATE = [min(datenum(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'))','yyyymmddHHMMSS')) ...
			max(datenum(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'))','yyyymmddHHMMSS'))];
	catch
		error(sprintf('Cannot read cruise informations from this netcdf file (problem with STATION_DATE_BEGIN)'));		
	end%try

	try
		N_STATION = length(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_NUMBER')));
	catch
		error(sprintf('Cannot read cruise informations from this netcdf file (problem with STATION_NUMBER)'));				
	end%try

	try 
		T.cruise_info = cruise_info(...
							'NAME',NAME,...
							'PI_NAME',PI_NAME,...
							'PI_ORGANISM',PI_ORGANISM,...
							'SHIP_NAME',SHIP_NAME,...
							'SHIP_WMO_ID',SHIP_WMO_ID,...
							'DATE',DATE,...
							'N_STATION',N_STATION...
							...
							);
	catch
		error('Cannot set cruise informations from this netcdf file')
	end% try

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Axes informations:
	T.geo = fill_axes(...
				'STATION_DATE',get_date(ncid),...
				'STATION_NUMBER',double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_NUMBER'))),...
				'LATITUDE',get_latitude(ncid),...
				'LONGITUDE',get_longitude(ncid),...
				'POSITIONING_SYSTEM',netcdf.getVar(ncid,netcdf.inqVarID(ncid,'POSITIONING_SYSTEM'))',...
				'PRES',get_pres(ncid),...
				'MAX_PRESSURE',netcdf.getVar(ncid,netcdf.inqVarID(ncid,'MAX_PRESSURE')),...
				'DEPH',get_deph(ncid)...
				...
				);			

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Data informations:
	switch do_biogeo
		case 1
			vlist = {'TEMP';'PSAL';'OXYL';'OXYK';'BRV2';'SIGI';'SIG0';'PHOS';'NITR';'ALKT';'SIO2';'CANT';'CTOT'};
		otherwise
			vlist = {'TEMP';'PSAL';'OXYL';'OXYK';'BRV2';'SIGI';'SIG0'};
	end% switch 
	
	for iv = 1 : length(vlist)
		try
			T = setodata(T,vlist{iv},fill_odata(vlist{iv},ncid));
		catch
			%disp(sprintf('Cannot load %s',vlist{iv}));
		end% Try
	end% for iv


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	netcdf.close(ncid); clear ncid

	T = clean_empty_variables(T);
	check(T);

	% if exist('local_ncfile','var')
	% 	delete(local_ncfile);
	% end

	switch nargout
		case 1
			varargout(1) = {T};
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function D = fill_odata(varn,ncid)

		if ~isempty(intersect(ncvarname(ncid),varn))
			c = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,varn)))';
			fval = netcdf.getAtt(ncid,netcdf.inqVarID(ncid,varn),'_FillValue');

			try % Try to get sure we're not doing crap:
				p = par_code(varn);
				c(c<p{1}.valid_min | c > p{1}.valid_max) = NaN;
				c(c==fval) = NaN;
			end

			D = odata(...
				'long_name',clean_spc(netcdf.getAtt(ncid,netcdf.inqVarID(ncid,varn),'long_name')),...
				'long_unit',clean_spc(netcdf.getAtt(ncid,netcdf.inqVarID(ncid,varn),'units')),...
				'unit',shorten_unit(strtrim(netcdf.getAtt(ncid,netcdf.inqVarID(ncid,varn),'units'))),...
				'cont',c,...
				'prec',double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,sprintf('PROFILE_%s_PREC',varn))))',...
				'name',varn...
				...
				);
		else	
			D = NaN;
		end% if 
	end% function

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function A = fill_axes(varargin)

		% Init
		A.dummy = '';

		% Add parameters/values pairs:
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
	%		elseif	strcmp(P,'STATION_DATE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'STATION_DATE_END'), OK = true;
			elseif	strcmp(P,'LATITUDE'), OK = true;
	%		elseif	strcmp(P,'LATITUDE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'LATITUDE_END'), OK = true;
			elseif	strcmp(P,'LONGITUDE'), OK = true;
	%		elseif	strcmp(P,'LONGITUDE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'LONGITUDE_END'), OK = true;
			elseif	strcmp(P,'POSITIONING_SYSTEM'), OK = true;
			elseif	strcmp(P,'PRES'), OK = true;
			elseif	strcmp(P,'MAX_PRESSURE'), OK = true;
			elseif	strcmp(P,'DEPH'), OK = true;
			else, OK = false;
			end
		end

	end %function

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_date(ncid)

		if ~isempty(intersect(ncvarname(ncid),'STATION_DATE_BEGIN'))	
			c1 = datenum(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'))','yyyymmddHHMMSS');
			c2 = datenum(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'))','yyyymmddHHMMSS');
			if length(find(c1-c2~=0)) >= 1
				cp0 = (c1+c2)/2;
			else
				cp0 = c1;
			end
		else
			error('I don''t know how to get the date in this netcdf file');	
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_pres(ncid)

		cp0 = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'PRES'))';
		fval = netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'PRES'),'_FillValue');

		try % Try to get sure we're not doing crap:
			p = par_code('PRES');
			cp0(cp0<p{1}.valid_min | cp0 > p{1}.valid_max) = NaN;
			cp0(cp0==fval) = NaN;

		end	

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_deph(ncid)

		cp0  = -double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'DEPH'))');
		fval = netcdf.getAtt(ncid,netcdf.inqVarID(ncid,'DEPH'),'_FillValue');

		try % Try to get sure we're not doing crap:
			p = par_code('DEPH');
			cp0(cp0<p{1}.valid_min | cp0 > p{1}.valid_max) = NaN;
			cp0(cp0==fval) = NaN;
		end	

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_latitude(ncid)

		if ~isempty(intersect(ncvarname(ncid),'LATITUDE_BEGIN'))
			c1 = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'));
			c2 = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'));
			if length(find(isnan(c2)==1)==length(c2))
				cp0 = c1;
			elseif length(find(c2==-9999)) == length(c2)
				cp0 = c1;		
			else
				cp0 = (c1+c2)/2;
			end
		else
			error('I don''t know how to get the latitude in this netcdf file');	
		end		

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_longitude(ncid)

		if ~isempty(intersect(ncvarname(ncid),'LONGITUDE_BEGIN'))
			c1 = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'));
			c2 = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'));
			if length(find(isnan(c2)==1)==length(c2))
				cp0 = c1;
			elseif length(find(c2==-9999)) == length(c2)
				cp0 = c1;		
			else
				cp0 = (c1+c2)/2;
			end
		else
			error('I don''t know how to get the longitude in this netcdf file');	
		end

		% Move to longitude east from 0 to 360	
		%cp0(cp0>=-180 & cp0<0) = 360 + cp0(cp0>=-180 & cp0<0);

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function s = clean_spc(s)
		for ii=1:10
			s = strrep(s,'  ',' ');
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function varargout = ncvarname(ncid)

		[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

		for iv = 1 : nvars
			varid = iv-1;
			[varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
			[Dim_ids Dim_names Dim_length] = netcdf.DimVar(ncid,varid);	
			dim_str = '';
			for id = 1 : length(Dim_ids)
				str = sprintf('(%s=%i)',Dim_names{id},Dim_length(id));
				if length(Dim_ids) == 1
					dim_str = sprintf('%s',str);
				elseif id == length(Dim_ids)
					dim_str = sprintf('%s %s',dim_str,str);
				else
					dim_str = sprintf('%s %s x',dim_str,str);
				end% if 
			end% for 
			dstr = sprintf('\t#%3.1d: %20s [%s]',varid,varname,dim_str);
			RESdisp(iv) = {dstr};
			Vnames(iv) = {varname};
			Vids(iv)   = varid;
		end% for iv
		[Vnames is] = sort(Vnames);
		RESdisp = RESdisp(is);
		Vids    = Vids(is);

		switch nargout
			case 1
				varargout(1) = {Vnames};
			case 2
				varargout(1) = {Vnames};
				varargout(2) = {Vids};
			otherwise
				s = sep;
				disp(sep('-',' LIST OF VARIABLE(S) '))	
				disp(sprintf('\t#IDS: %20s [%s]','VARIABLE NAME','(DIMENSION NAME = LENGTH)'))			
				disp(s(1:fix(length(s)/2)));
				for iv = 1 : nvars
					disp(RESdisp{iv});
				end% for iv
				disp(s);
		end% switch 

	end %functionlistVar

end% function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- This version uses the third party netcdf library
function T = hydrocean2transect_tiers(varargin)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	% Automatic retrieval of scaled variable with NaNs in place of the fill value
	global nctbx_options;
	nctbx_options.theAutoNaN = 1;
	nctbx_options.theAutoscale = 1;

	% Init transect object:
	nc_file = varargin{1};
	nc_file = abspath(nc_file);
	nc_file0 = nc_file; % We keep the initial file name

	% Do we load biogeochemical tracers ?
	if nargin == 2
		do_biogeo = varargin{2};
	else	
		do_biogeo = 0;
	end

	% Here we insert the possibility to download the datas from the intranet
	% if we find 'http' in nc_file
	if ~isempty(strfind(nc_file,'ftp://')) | ~isempty(strfind(nc_file,'http://'))
		try
			local_ncfile = sprintf('%s/hydrocean_tempo_file.nc',pwd);
			system(sprintf('wget -O %s ''%s''',local_ncfile,nc_file));
			% If we made it through here, we can change the nc_file value:
			nc_file = local_ncfile;
		catch
			error('You asked for an online netcdf file I couldn''t download !');
		end
	end

	% Open netcdf file
	nc = netcdf(nc_file,'nowrite');
	[ndims, nvars, ngatts, theRecdimid, status] = ncmex('inquire',ncid(nc));
	if status == -1
		error('Badly open netcdf file, please double check it ...')
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Init transect object and fill in header properties:
	T          = transect;
	T.file     = nc_file0;
	finfo = dir(nc_file);
	T.file_date = finfo.datenum;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Cruise informations:
	if ~isempty(nc{'STATION_DATE_BEGIN'}(:))
		T.cruise_info = cruise_info(...
							'NAME',deblank(nc{'CRUISE_NAME'}(1,:)'),...
							'PI_NAME',deblank(nc{'PI_NAME'}(1,:)'),...
							'PI_ORGANISM',deblank(nc{'PI_ORGANISM'}(1,:)'),...
							'SHIP_NAME',deblank(nc{'SHIP_NAME'}(1,:)'),...
							'SHIP_WMO_ID',deblank(nc{'SHIP_WMO_ID'}(1,:)'),...
							'DATE',[min(datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS')) ...
									max(datenum(nc{'STATION_DATE_END'}(:),'yyyymmddHHMMSS'))],...
							'N_STATION',length(nc{'STATION_NUMBER'}(:))...
							...
							);
						
	else % This is more likely an Argo file, just a trick to be able to 
	%		handle argo data with transect class
		REFERENCE_DATE_TIME = nc{'REFERENCE_DATE_TIME'};
		ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
				str2num(REFERENCE_DATE_TIME(5:6)),...
				str2num(REFERENCE_DATE_TIME(7:8)),...
				str2num(REFERENCE_DATE_TIME(9:10)),...
				str2num(REFERENCE_DATE_TIME(11:12)),...
				str2num(REFERENCE_DATE_TIME(13:14)));
		tim = nc{'JULD_LOCATION'} + ref;
		T.cruise_info = cruise_info(...
							'NAME',deblank(nc{'CRUISE_NAME'}(1,:)'),...
							'PI_NAME',deblank(nc{'PI_NAME'}(1,:)'),...
							'PI_ORGANISM',deblank(nc{'PI_ORGANISM'}(1,:)'),...
							'SHIP_NAME',deblank(nc{'SHIP_NAME'}(1,:)'),...
							'SHIP_WMO_ID',deblank(nc{'SHIP_WMO_ID'}(1,:)'),...
							'DATE',[min(tim) max(tim)],...
							'N_STATION',length(nc{'STATION_NUMBER'}(:))...
							...
							);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Axes informations:
	T.geo = fill_axes(...
				'STATION_DATE',get_date(nc),...
				'STATION_NUMBER',nc{'STATION_NUMBER'}(:),...
				'LATITUDE',get_latitude(nc),...
				'LONGITUDE',get_longitude(nc),...
				'POSITIONING_SYSTEM',nc{'POSITIONING_SYSTEM'}(:,:),...
				'PRES',get_pres(nc),...
				'MAX_PRESSURE',nc{'MAX_PRESSURE'}(:),...
				'DEPH',-nc{'DEPH'}(:,:)...
				...
				);			

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fill in Data informations:
	switch do_biogeo
		case 1
			T.data = fill_data(...
					'TEMP',fill_odata('TEMP',nc),...
					'PSAL',fill_odata('PSAL',nc),...
					'OXYL',fill_odata('OXYL',nc),...
					'OXYK',fill_odata('OXYK',nc),...
					'BRV2',fill_odata('BRV2',nc),...
					'SIGI',fill_odata('SIGI',nc),...
					'SIG0',fill_odata('SIG0',nc),...
					'PHOS',fill_odata('PHOS',nc),...
					'NITR',fill_odata('NITR',nc),...
					'ALKT',fill_odata('ALKT',nc),...
					'SIO2',fill_odata('SIO2',nc),...
					'CANT',fill_odata('CANT',nc),...
					'CTOT',fill_odata('CTOT',nc)...
					...
					);
		otherwise
			T.data = fill_data(...
					'TEMP',fill_odata('TEMP',nc),...
					'PSAL',fill_odata('PSAL',nc),...
					'OXYL',fill_odata('OXYL',nc),...
					'OXYK',fill_odata('OXYK',nc),...
					'BRV2',fill_odata('BRV2',nc),...
					'SIGI',fill_odata('SIGI',nc),...
					'SIG0',fill_odata('SIG0',nc)...
					...
					);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	close(nc);clear nc

	T = clean_empty_variables(T);
	check(T);

	if exist('local_ncfile','var')
		delete(local_ncfile);
	end

	switch nargout
		case 1
			varargout(1) = {T};
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function D = fill_odata(varn,nc)
	
		if ~isempty(nc{varn}(:,:))
			c = nc{varn}(:,:);
			try % Try to get sure we're not doing crap:
				p = par_code(varn);
				c(c<p{1}.valid_min | c > p{1}.valid_max) = NaN;
			end
			
			D = odata(...
				'long_name',clean_spc(nc{varn}.long_name(:)),...
				'long_unit',clean_spc(nc{varn}.units(:)),...
				'unit',shorten_unit(strtrim(nc{varn}.units(:))),...
				'cont',c,...
				'prec',nc{sprintf('PROFILE_%s_PREC',varn)}(:),...
				'name',varn...
				...
				);
		else	
			D = NaN;
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function D = fill_data(varargin)
	
		% INIT:
		D.dummy = '';
		
		% THEN MODIFY OBJECT USING SPECIFIED VALUES:
		n = nargin;
		if mod(n,2) ~= 0,
			error('Invalid number of input arguments');
		else
			for iprop = 1 : 2 : n
				prop_nam = varargin{iprop};
				prop_val = varargin{iprop+1};
				if isa(prop_val,'odata') | strcmp(prop_nam,'STATION_PARAMETERS') | strcmp(prop_nam,'PARAMETERS_STATUS')
					D = setfield(D,prop_nam,prop_val);
				end
			end
		end
	
		% FINISH 
		D = rmfield(D,'dummy');	
	
	end %function

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
	%		A.LATITUDE_BEGIN = 0;
	%		A.LATITUDE_END = 0;
			A.LONGITUDE = 0;
	%		A.LONGITUDE_BEGIN = 0;
	%		A.LONGITUDE_END = 0;
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
	%		elseif	strcmp(P,'STATION_DATE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'STATION_DATE_END'), OK = true;
			elseif	strcmp(P,'LATITUDE'), OK = true;
	%		elseif	strcmp(P,'LATITUDE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'LATITUDE_END'), OK = true;
			elseif	strcmp(P,'LONGITUDE'), OK = true;
	%		elseif	strcmp(P,'LONGITUDE_BEGIN'), OK = true;
	%		elseif	strcmp(P,'LONGITUDE_END'), OK = true;
			elseif	strcmp(P,'POSITIONING_SYSTEM'), OK = true;
			elseif	strcmp(P,'PRES'), OK = true;
			elseif	strcmp(P,'MAX_PRESSURE'), OK = true;
			elseif	strcmp(P,'DEPH'), OK = true;
			else, OK = false;
			end
		end

	end %function

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_date(nc)
		if ~isempty(nc{'STATION_DATE_BEGIN'}(:))	
			c1 = datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS');
			c2 = datenum(nc{'STATION_DATE_END'}(:),'yyyymmddHHMMSS');
			if length(find(c1-c2~=0)) >= 1
				cp0 = (c1+c2)/2;
			else
				cp0 = datenum(nc{'STATION_DATE_BEGIN'}(:),'yyyymmddHHMMSS');
			end
		else
			REFERENCE_DATE_TIME = nc{'REFERENCE_DATE_TIME'};
			ref = datenum(str2num(REFERENCE_DATE_TIME(1:4)),...
					str2num(REFERENCE_DATE_TIME(5:6)),...
					str2num(REFERENCE_DATE_TIME(7:8)),...
					str2num(REFERENCE_DATE_TIME(9:10)),...
					str2num(REFERENCE_DATE_TIME(11:12)),...
					str2num(REFERENCE_DATE_TIME(13:14)));
			tim = nc{'JULD_LOCATION'} + ref;
			cp0 = tim;
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_pres(nc)
		cp0 = nc{'PRES'}(:,:);
	
		try % Try to get sure we're not doing crap:
			p = par_code('PRES');
			cp0(cp0<p{1}.valid_min | cp0 > p{1}.valid_max) = NaN;
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_latitude(nc)
	
		if ~isempty(intersect(ncvarname(nc),'LATITUDE_BEGIN'))
			c1 = nc{'LATITUDE_BEGIN'}(:);
			c2 = nc{'LATITUDE_END'}(:);
			if length(find(isnan(c2)==1)==length(c2))
				cp0 = c1;
			else
				cp0 = (c1+c2)/2;
			end
		
		elseif ~isempty(intersect(ncvarname(nc),'LATITUDE'))
			cp0 = nc{'LATITUDE'}(:);		
		else
			error('I don''t know how to find the latitude in this netcdf file');
		end	
		
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function cp0 = get_longitude(nc)
	
		if ~isempty(intersect(ncvarname(nc),'LONGITUDE_BEGIN'))
			c1 = nc{'LONGITUDE_BEGIN'}(:);
			c2 = nc{'LONGITUDE_END'}(:);
			if length(find(isnan(c2)==1)==length(c2))
				cp0 = c1;
			else
				cp0 = (c1+c2)/2;
			end
		elseif ~isempty(intersect(ncvarname(nc),'LATITUDE'))
			cp0 = nc{'LONGITUDE'}(:);	
		else
			error('I don''t know how to find the longigutde in this netcdf file');	
		end

		% Move to longitude east from 0 to 360	
		%cp0(cp0>=-180 & cp0<0) = 360 + cp0(cp0>=-180 & cp0<0);
	
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function s = clean_spc(s)
		for ii=1:10
			s = strrep(s,'  ',' ');
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function varargout = ncvarname(varargin)

		nc = varargin{1};
		if ~isa(nc,'netcdf')
			error('ncvarname only take as argument a netcdf object')
		end

		v = var(nc);
		for iv = 1 : length(v)
			namelist(iv) = {name(v{iv})};
		end
		namelist = sort(namelist);

		if nargout == 0
			for iv=1:length(namelist)
				disp(namelist{iv})
			end
		else
			varargout(1) = {namelist};
		end

	end %functionncvarname

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
