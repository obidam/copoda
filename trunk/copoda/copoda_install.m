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
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% TODO: Add a script for environment variable MATLAB PATH instead of startup file

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

%%%%%%%%%%%%%% COPODA Config file
% Now we create the configuration file from the default one: default_copoda.cfg
if docfgf
	create_config_file;
end


%%%%%%%%%%%%%% Adjust MATLAB path
if dopath

	disp(sprintf('\nLet''s add relevant folders of the package to the Matlab search path.'));

	disp(sprintf('You need to insert the following block of lines in your startup file:\n'))
	disp(sprintf('%%----------- COPODA PACKAGE ----------- START'));
	flist = get_list_of_folders_for_path;
	for ii = 1 : length(flist)
		disp(sprintf('addpath(''%s'');',flist{ii}))
		addpath(flist{ii}); % add it for the current session
	end
	flist = get_list_of_contrib_folders;
	if ~isempty(flist)
		for ii = 1 : length(flist)
			disp(sprintf('addpath(''%s'');',flist{ii}))
			addpath(flist{ii}); % add it for the current session
		end
	end%if	
	try
		disp(sprintf('try,addpath(copoda_readconfig(''copoda_userdata_folder''));end'));
	end
	disp(sprintf('%%----------- COPODA PACKAGE ----------- END\n'))

	r = input(sprintf('Do you want me to do it for you ?\n y/[n]: '),'s');
	switch lower(r)
		case 'y'
			pathtostartup = which('startup.m');
			doit = false;
			if ~isempty(pathtostartup)
				pathtostartup_bck = sprintf('%s_beforeCOPODAinstall.m',strrep(pathtostartup,'.m',''));
				res = copyfile(pathtostartup,pathtostartup_bck);
				if res == 1
					disp(sprintf('\tI created a backup of your startup file under:\n\t\t%s',pathtostartup_bck));
					doit = true;					
				else
					r2 = input(sprintf('I couldn''t backup your startup file, do you want to continue ?\ny/[n]: '),'s');
					switch lower(r2)
						case 'y'
							doit = true;
						otherwise
							disp('The COPODA package path is not set up !!!');
					end%switch
				end%if
				if doit
					fid = fopen(pathtostartup,'a+');
					fseek(fid,0,'eof'); % Ensure we are at the end of the file
					fprintf(fid,'\n');
					fprintf(fid,'\n%s\n','%%----------- COPODA PACKAGE ----------- START');
					flist = get_list_of_folders_for_path;
					for ii = 1 : length(flist)
						fprintf(fid,'addpath(''%s'');\n',flist{ii});
					end
					flist = get_list_of_contrib_folders;
					if ~isempty(flist)
						for ii = 1 : length(flist)
							fprintf(fid,'addpath(''%s'');\n',flist{ii});
						end
					end%if
					try
						fprintf(fid,'try,addpath(copoda_readconfig(''copoda_userdata_folder''));end\n');
					end
					fprintf(fid,'%s\n\n','%%----------- COPODA PACKAGE ----------- END');
					fclose(fid);
				end
			else
				disp(sprintf('Warning: I can''t find you startup.m file !\nPlease create one and relaunch the COPODA install script.'))
			end%if
		otherwise
			% Nothing
	end%switch


end%if


%%%%%%%%%%%%%% We also need m_map, netcdf and system wget:
if dodepend
	disp(sprintf('\nCheck at other toolboxes and system command(s) needed by COPODA:'));

	check_ifnetcdf;
	check_ifmmap;
	check_ifseaw;
	check_ifwget;
	
end

%%%%%%%%%%%%%% Finish
disp(sprintf('\nIf you made it through here, you''re probably done with version %s of COPODA\n',copoda_readconfig('copoda_version')));
disp(sprintf('You can now start by looking at one of the demo files:'));
dir(fullfile(copodahomedir,'copoda','*demo*.m'))
warning(warning_state_before)


end %functioncopoda_install
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifseaw(varagin);

try % To find SeaWater package	
	sw_cp(35.5,20,0);
	v = true;
catch
	v = false;
end
if v
	disp(sprintf('\tChecking SeaWater toolbox ... ok'));			
else
	disp(sprintf('\tChecking SeaWater toolbox ... echec'));	
	disp(sprintf('\t\tSEAWATER Library is not in your path, please consider to install it to use COPODA with all its features'));
	disp(sprintf('\t\tCheck it out at: http://www.cmar.csiro.au/datacentre/ext_docs/seawater.htm'));
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifwget(varagin);
	
	[a res] = system('wget -V');
	if strfind(res,'Copyright')
		disp(sprintf('\tChecking wget ... ok'));					
	else
		disp(sprintf('\tChecking wget ... echec'));						
		disp(sprintf('\t\tsystem command ''wget'' is not in your path, please consider to install it to use COPODA with all its features'));
	end	
	
end%function
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifmmap(varagin);

	an = which('m_proj');
	if isempty(an)
		disp(sprintf('\tChecking m_map toolbox ... echec'));
		disp(sprintf('\t\tm_map is not in your path, please consider to install it to use COPODA with all its features'));
		disp(sprintf('\t\tCheck it out at: http://www.eos.ubc.ca/~rich/'));
	else
		disp(sprintf('\tChecking m_map toolbox ... ok'));		
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vararougt = check_ifnetcdf(varagin);
	
try % To find netcdf package	
	v = ncversion;
catch
	v = NaN;
end
if ~isnan(v)
	if datenum(v,'dd-mmm-yyyy HH:MM:SS') > datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\tChecking NetCDF toolbox ... ok'));	
		disp(sprintf('\t\tWarning: I found a NetCDF toolbox more up to date than the one used to develop COPODA,\n\t\tyou may experience problems with transcripts routines'));
	elseif datenum(v,'dd-mmm-yyyy HH:MM:SS') == datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\tChecking NetCDF toolbox ... ok'));
	elseif datenum(v,'dd-mmm-yyyy HH:MM:SS') < datenum('30-Apr-2003 11:16:19','dd-mmm-yyyy HH:MM:SS')
		disp(sprintf('\tChecking NetCDF toolbox ... ok'));
		disp(sprintf('\t\tWarning: I found a NetCDF toolbox older than the one used to develop COPODA,\nyou may experience problems with transcripts routines'));
	end
else	
	disp(sprintf('\tChecking NetCDF toolbox ... echec'));
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
	
	defcfg = fullfile(copodahomedir,'copoda','default_copoda.cfg');	
	fid = fopen(defcfg,'r');
	if fid<0
		error(sprintf('\tI can''t find the default configuration file !\n%s NOT FOUND !',defcfg));
	end
	defcfgout = fullfile(copodahomedir,'copoda','copoda.cfg');
	
	doit  = true;
	didit = false;
	if exist(defcfgout,'file')
		re = input(sprintf('You already have a configuration file, do you want to overwrite it y/[n] ?'),'s');
		switch lower(re)
			case {'y','yes'}
				doit  = true;
				didit = true;
				copyfile(defcfgout,fullfile(copodahomedir,'copoda','copoda_old.cfg'));
			otherwise
				doit = false;
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
							prop(3) = {fullfile(copodahomedir,'copoda','data')};
							beenmodified = true;				
						case 'transect_constructor_default_source'
							donethis = 0;
							while ~donethis
								if didit
									r0 = copoda_readconfig('transect_constructor_default_source',fullfile(copodahomedir,'copoda','copoda_old.cfg'));
									r = input(sprintf('\tPlease enter the default source property for Transect object (your affiliation for example)\n\tLEAVE BLANK TO USE PREVIOUS VALUE: %s\n-> ',r0),'s');
									if ~isempty(r)
										donethis = 1;
									else
										r = r0;
										donethis = 1;
									end
								else
									r = input(sprintf('\tPlease enter the default source property for Transect object (your affiliation for example):\n-> '),'s');
									if ~isempty(r)
										donethis = 1;
									else
										disp(sprintf('\tYou must enter something ...'));
									end
								end
							end
							prop(3) = {r};
							beenmodified = true;

						case 'database_constructor_default_source'
						donethis = 0;
						while ~donethis
							if didit
								r0 = copoda_readconfig('database_constructor_default_source',fullfile(copodahomedir,'copoda','copoda_old.cfg'));
								r = input(sprintf('\tPlease enter the default source property for Database object (your affiliation for example)\n\tLEAVE BLANK TO USE PREVIOUS VALUE: %s\n-> ',r0),'s');
								if ~isempty(r)
									donethis = 1;
								else
									r = r0;
									donethis = 1;
								end
							else
								r = input(sprintf('\tPlease enter the default source property for Database object (your affiliation for example):\n-> '),'s');
								if ~isempty(r)
									donethis = 1;
								else
									disp(sprintf('\tYou must enter something ...'));
								end
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
	try
		folders = splitpath(strrep(svn.url,svn.repository.root,''));	
	catch
		svn
		error('Oups, something went wrong ! I cannot read information from your svn working copy !');
	end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = svninfo(varargin)

if nargin ~= 1
	error('You must specify a folder under svn control')
end

pathsvn = varargin{1};
d = dir(fullfile(pathsvn,'.svn'));
if isempty(d)
	error(sprintf('svn: ''%s'' is not a working copy',pathsvn));
end

[st res] = system(sprintf('svn info %s --xml',pathsvn));

try
	a = res(strfind(res,'<entry')+6:end); a = a(1:min(strfind(a,'>'))-1);
	b = a(strfind(a,'kind="')+6:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.kind = b;

	b = a(strfind(a,'path="')+6:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.path = b;

	b = a(strfind(a,'revision="')+10:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.revision = b;

	svn.url = res(strfind(res,'<url>')+5:strfind(res,'</url>')-1);

	repo = res(strfind(res,'<repository>')+12:strfind(res,'</repository>')-1);
	svn.repository.root = repo(strfind(repo,'<root>')+6:strfind(repo,'</root>')-1);
	svn.repository.uuid = repo(strfind(repo,'<uuid>')+6:strfind(repo,'</uuid>')-1);

	varargout(1) = {svn};

catch
	error(sprintf('Oups, something went wrong ! I cannot retrieve information from your svn working copy in: %s from:\n%s',pathsvn,res));
%	varargout(1) = {'?'};
end



end %functionsvninfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
