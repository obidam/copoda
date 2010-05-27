% copoda_install Install and set-up the COPODA package
%
% For a complete installation process, simply type at the 
% Matlab prompt:
% 	copoda_install
%
% Optional arguments.
% You may want to process only part of the script, in this case,
% use the following pairs of options:
%	dopath (true): Check the path
% 	docfgf (true): Edit and create config file
%	dodepend (true) : Check dependencies
% Using the syntax, as an example:
%		copoda_install('dopath',true,'docfgf',false,'dodepend',true)
%
%
% Created: 2010-04-30.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = copoda_install(varargin)

%- Default parameters:
dopath   = true; % Check the path
docfgf   = true; % Edit and create config file
dodepend = true; % Check dependencies

%- Load user parameters:
if nargin > 1
	for in = 1 : 2 : nargin-1
		eval(sprintf('%s = varargin{in+1};',varargin{in}));		
	end
end

% Clear the command window for a fresh start !
clc; 
% Disable warnings:
a = warning; warning_state_before = a(1).state; clear a
warning off

%if ispc, sla = '\'; else, sla = '/'; end

disp(sprintf('\nThis function will help you install and configure the COPODA Matlab package\n'));
rver = realversion;
dver = copoda_readconfig('copoda_version','default_copoda.cfg');
if ~strcmp(rver,dver)
	disp(sprintf('You''re about to install COPODA Version: %s',dver));
	switch rver
		case 'trunk'
			disp(sprintf('\tThis is the experimental ''trunk'' version !'));
		otherwise
			disp(sprintf('\tI don''t know this version !'));
	end
else	
	disp(sprintf('You''re about to install COPODA Version: %s',dver));
end
r = input(sprintf('\n\tDo you want to continue [y]/n ?'),'s');
switch lower(r)
	case {'n','no'}
		disp('Bye then !');
		return
	otherwise
end

%%%%%%%%%%%%%% Check if we have all we're supposed to have 
disp(sprintf('\nChecking package architecture under:\n%s',copodahomedir));
folders_ok = true;

flist = get_list_of_stuff_to_check;
for ii = 1 : length(flist)
	if exist(flist{ii})
		disp(sprintf('\t%s ... ok',strrep(flist{ii},copodahomedir,'')));
	else
		disp(sprintf('\t%s ... not found !',strrep(flist{ii},copodahomedir,'')));
		folders_ok = false;
	end
end
if folders_ok
	%
else
	disp(sprintf('\tERROR !\n\tSomething''s wrong with the local package architecture\n\n\tPlease check out again with:'));
	disp(sprintf('\t\tsvn checkout http://copoda.googlecode.com/svn/tags/alpha copoda-package'));
	return
end


%%%%%%%%%%%%%% Adjust MATLAB path
if dopath

disp(sprintf('\nLet''s add relevant folders of the package to the Matlab search path.'));
r = input(sprintf('Do you want to:\n\t1 (default): Add COPODA to your default search path\n\t2: create a string to insert in you startup.m file\n? '),'s');
switch lower(r)
	case '2'
		flist = get_list_of_folders_for_path;
		
		disp(sprintf('In your startup.m file, please insert the following block of lines:\n'));
		disp(sprintf('%%----------- COPODA PACKAGE -----------'))
		for ii = 1 : length(flist)
			disp(sprintf('addpath(''%s'');',flist{ii}))
		end
		
		% Before we finish, let's see if we have contrib folders:
		flist = get_list_of_contrib_folders;
		if ~isempty(flist)
			for ii = 1 : length(flist)
				disp(sprintf('addpath(''%s'');',flist{ii}))
			end
		end%if
		
		disp(sprintf('%%--------------------------------------'))		

	otherwise
		flist = get_list_of_folders_for_path;
%		keyboard
		for ii = 1 : length(flist)
			addpath(flist{ii});
		end
		
		flist = get_list_of_contrib_folders;
		if ~isempty(flist)
			for ii = 1 : length(flist)				
				addpath(flist{ii});
			end
		end%if
		savepath;		
		
end%switch 

end%if


%%%%%%%%%%%%%% COPODA Config file
% Now we create the configuration file from the default one: default_copoda.cfg
if docfgf
	create_config_file;
end

%%%%%%%%%%%%%% We also need m_map, netcdf and system wget:
if dodepend
	disp(sprintf('\nCheck at other toolboxes and system command(s) needed by COPODA:'));

	check_ifnetcdf;
	check_ifmmap;
	check_ifwget;
	
end

%%%%%%%%%%%%%% Finish
disp(sprintf('\nIf you made it through here, you''re probably done with version %s of COPODA\n',copoda_readconfig('copoda_version')));
disp(sprintf('You can now start by looking at one of the demo files:'));
dir('./*demo*.m')
warning(warning_state_before)


end %functioncopoda_install
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifwget(varagin);
	
	disp(sprintf('\n\tChecking wget ...'));	
	
	[a res] = system('wget -V');
	if strfind(res,'Copyright')
		disp(sprintf('\t\tOK'));		
	else
		disp(sprintf('\t\twget is not in your path, please consider to install it to use COPODA with all its features'));
	end	
	
end%function
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifmmap(varagin);

	disp(sprintf('\n\tChecking m_map toolbox ...'));	
	try % To find m_map package	
		m_proj('mercator');
		v = true;
	catch
		v = false;
	end
	if ~isempty(v)
		disp(sprintf('\t\tOK'));		
	else
		disp(sprintf('\t\tm_map is not in your path, please consider to install it to use COPODA with all its features'));
		disp(sprintf('\t\tCheck it out at: http://www.eos.ubc.ca/~rich/map.html'));
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifnetcdf(varagin);
	
disp(sprintf('\n\tChecking NetCDF toolbox ...'));	
try % To find netcdf package	
	v = ncversion;
catch
	v = NaN;
end
if ~isnan(v)
	if datenum(v,'dd-mmm-yyyy HH:MM:SS') > datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\t\tI found a NetCDF toolbox more up to date than the one used to develop COPODA,\n\t\tyou may experience problems with transcripts routines'));
	elseif datenum(v,'dd-mmm-yyyy HH:MM:SS') == datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\t\tOK'));
	elseif datenum(v,'dd-mmm-yyyy HH:MM:SS') < datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\t\tI found a NetCDF toolbox older than the one used to develop COPODA,\nyou may experience problems with transcripts routines'));
	end
else
	disp(sprintf('\t\tNetCDF is not in your path, please consider to install it to use COPODA with all its features'));
	disp(sprintf('\t\tCheck it out at: http://mexcdf.sourceforge.net/'));	
end	

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the configuration file
% We loop through lines of the default file and update
% properties when found and needed
function varargout = create_config_file;
	
	disp(sprintf('\nNow we''ll create the COPODA configuration file ''copoda.cfg''\n'));
	
	if ispc, sla = '\'; else, sla = '/'; end	
	here = pwd;
	defcfg = sprintf('%s%s%s',here,sla,'default_copoda.cfg');
	fid = fopen(defcfg,'r');
	if fid<0
		error(sprintf('\tI can''t find the default configuration file !\n%s NOT FOUND !',defcfg));
	end
	defcfgout = sprintf('%s%s%s',here,sla,'copoda.cfg');
	doit = true;
	if exist(defcfgout,'file')
		re = input(sprintf('You already have a configuration file, do you want to overwrite it y/[n] ?'),'s');
		if strcmp(lower(re),'n') | strcmp(lower(re),'no')
			doit = false;
		else
			doit = true;
		end
	end
	
	if doit
		fidout = fopen(defcfgout,'w');
		if fidout < 0
			error(sprintf('\tI can''t open the configuration file !\n%s',defcfgout));
		end
		
		done = 0;
		while ~done
			tline = fgetl(fid);
			if ~ischar(tline);
				done = 1;
			elseif ~isempty(tline)
				if tline(1) ~= '#' % Comment line
					prop = retrievevalue(tline,3);
					switch prop{1}
						case 'copoda_data_folder'
							% We don't ask the user yet in this beta version
							prop(3) = {sprintf('%s%s%s',pwd,sla,'data')};
							beenmodified = true;				
						case 'transect_constructor_default_source'
							donethis = 0;
							while ~donethis
								r = input(sprintf('\tPlease enter the default source property for Transect object (your affiliation for example):\n'),'s');
								if ~isempty(r)
									donethis = 1;
								else
									disp(sprintf('\tYou must enter something ...'));
								end
							end
							prop(3) = {r};
							beenmodified = true;

						case 'database_constructor_default_source'
							donethis = 0;
							while ~donethis
								r = input(sprintf('\tPlease enter the default source property for Database object (Your affiliation for example):\n'),'s');
								if ~isempty(r)
									donethis = 1;
								else
									disp(sprintf('\tYou must enter something ...'));
								end
							end
							prop(3) = {r};
							beenmodified = true;
						otherwise
							% We don't change the other properties right now
							beenmodified = false;
					end
								
					switch prop{2} % type
						case 'char'
							fprintf(fidout,'<parameter name="%s" type="%s">%s</parameter>\n',prop{1},prop{2},prop{3});
						case 'logical'
							if ~islogical(prop{3})
								switch prop{3}
									case {0,1}
										if prop{3} == 1
											prop(3) = {'true'};
										else
											prop(3) = {'false'};
										end
									otherwise
										error('I don''t recognize this value !')							
								end
							else
								if prop{3}
									prop(3) = {'true'};
								else	
									prop(3) = {'false'};
								end
							end
							
							switch beenmodified
								case true
								case false
									fprintf(fidout,'<parameter name="%s" type="%s">%s</parameter>\n',prop{1},prop{2},prop{3});
							end
						case 'double'	
							switch beenmodified
								case true
									prop{3} = str2num(prop{3});
								case false
							end
							a = prop{3}; 
							str = sprintf('%i',a(1));
							for ii = 2 : length(a)
								str = sprintf('%s %i',str,a(ii));
							end%for ii
							fprintf(fidout,'<parameter name="%s" type="%s">[%s]</parameter>\n',prop{1},prop{2},str);

					end%switch
					
				else
					fprintf(fidout,'%s\n',tline);				
				end%if
			else
				fprintf(fidout,'\n');
			end%if
		end%while
		fclose(fid);
		fclose(fidout);
		disp(sprintf('\nThe COPODA configuration file ''copoda.cfg'' is now set up. It is located here:\n\t%s\n',defcfgout));
		
	else
		disp(sprintf('\nThe COPODA configuration file ''copoda.cfg'' is already set up. It is located here:\n\t%s\n',defcfgout));		
	end%if already here
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = get_list_of_stuff_to_check;
	
	flist = get_list_of_folders_for_path;
	ii    = length(flist);
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','@cruise_info')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','@database')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','@transect')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','default_copoda.cfg')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'odata','@odata')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'odata','@oaxis')};
	
	flist = sort(flist);
	
end%function		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = get_list_of_folders_for_path;
		
	ii = 0;
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','data')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','utils')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'copoda','transcripts')};
	ii=ii+1; flist(ii) = {fullfile(copodahomedir,'odata')};
	
end%function		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = get_list_of_contrib_folders;
	
	contribH = fullfile(copodahomedir,'copoda_contrib');
	
	ic = 0;
	if exist(contribH,'dir')
		contrib_list = dir(contribH);
		for ii = 1 : length(contrib_list)
			if contrib_list(ii).isdir & ~strcmp(contrib_list(ii).name,'.') & ~strcmp(contrib_list(ii).name,'..') & ~strcmp(contrib_list(ii).name,'.svn')
				ic = ic + 1;
				flist(ic) = {fullfile(contribH,contrib_list(ii).name)};
			end
		end
	end
	if ic == 0 
		flist = {};
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function config = read_cfg(varargin)
	
	config_file = varargin{1};
	fid_cfg     = fopen(config_file,'r');
	if fid_cfg < 0
		error(sprintf('Config file: %s couldn''t be opened !',config_file));
	end
	
	iprop = 0;
	while 1
		tline = fgetl(fid_cfg);
		if ~ischar(tline);
			break
		elseif ~isempty(tline)
			if tline(1) ~= '#' % Comment line
%				disp(tline);
				prop  = retrievevalue(tline,3);
				iprop = iprop + 1;
				if iprop == 1
					config = prop;
				else
					config = cat(1,config,prop);
				end
			end
		end
	end
	
	fclose(fid_cfg);
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cleanprop = retrievevalue(tline,typ,varargin)

switch typ

	case 3 % <parameter name="param_name" type="matlab type">value</parameter>
		iso = strfind(tline,'<');
		isc = strfind(tline,'>');
		if length(iso) ~= 2 & length(isc) ~= 2
			disp('Something''s wrong with this propertie')
		else
			tl = strtrim(strrep(tline(iso(1)+1:isc(1)-1),'parameter',''));
			tl = strread(tl,'%s','delimiter',' ');
			for ii = 1 : length(tl)
				a = strread(tl{ii},'%s','delimiter','=');
				switch a{1}
					case 'name'
						prop_name = strrep(a{2},'"','');
					case 'type'
						prop_type = strrep(a{2},'"','');
					otherwise
						error('Unrecognized option in parameter');
				end%switch
			end%for ii
			prop_val = strtrim(tline(isc(1)+1:iso(2)-1));
%			disp(sprintf('%s (%s) = %s',prop_name,prop_type,prop_val));
			prop.property_name = prop_name;
			prop.property_type = prop_type;
			switch prop_type
				case 'logical'
					if strcmp(lower(prop_val),'true') | strcmp(prop_val,'1')
						prop_val = 1;
					elseif strcmp(lower(prop_val),'false') | strcmp(prop_val,'0')
						prop_val = 0;
					end
					eval(sprintf('prop.property_value = logical(%i);',prop_val));
				case 'char'
					eval(sprintf('prop.property_value = ''%s'';',prop_val));
				case 'double'
					eval(sprintf('prop.property_value = str2num(''%s'');',prop_val));
				otherwise
					error('unknown property type (must be logical, char or double)')
			end%switch
			cleanprop = {prop.property_name prop.property_type prop.property_value};
		end
		
		
		
end

end%function retrievevalue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = realversion

	svn = svninfo(copodahomedir);
	folders = splitpath(strrep(svn.url,svn.repository.root,''));	
	str = folders{end};

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function folders = splitpath(pathi)
	
	if ~strcmp(pathi(end),filesep)
		pathi = fullfile(pathi,filesep);
	end
	
	islash = strfind(pathi,filesep);
	
	if isempty(islash)
		folders = pathi;
		return
	end
	
	done = 0; ii = 0;
	while done ~= 1
		ii = ii + 1;
		if ii+1 <= length(islash)
			folders(ii) = {pathi(islash(ii)+1:islash(ii+1)-1)};
		else	
			done = 1;
		end
	end
	return
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function treehome = copodahomedir
	here     = strrep(mfilename('fullpath'),'copoda_install','');
	treehome = here(1:max(strfind(here,'copoda'))-1);
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
