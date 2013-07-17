% copoda_readconfig Retrieve configuration parameters for the COPODA package
%
% O = copoda_readconfig([PROP_NAME])
% 
% Retrieve configuration parameters for the COPODA package.
% This function read the COPODA configuration file under:
%	/copoda/copoda.cfg
% 
% Without inputs, the function returns a cell with all parameters as
%	<PROPERTY>,<TYPE>,<VALUE>
% and display all informations on screen.
%
% With input parameter PROP_NAME specified, the function returns its value.
%
% Created: 2010-04-23.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

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


function varargout = copoda_readconfig(varargin)

if nargin == 2
	config_file = varargin{2};
else
	config_file = 'copoda.cfg';
	config_file = sprintf('%s%s',class_home,config_file);	
end
config = read_cfg(config_file);

switch nargin
	case 0 % Display list of properties
		switch nargout
			case 0
				disp(sprintf('\nCOPODA configuration file (%s):\n',config_file))
				disp(sprintf('<PROPERTY> (<TYPE>): <VALUE>\n',config_file))
				for ip = 1 : size(config,1)
					switch config{ip,2}
						case 'logical'
							str = sprintf('%s (%s): %i',config{ip,1},config{ip,2},config{ip,3});
						case 'char'
							str = sprintf('%s (%s): %s',config{ip,1},config{ip,2},config{ip,3});
						case 'double'
							str = sprintf('%s (%s): %s',config{ip,1},config{ip,2},num2str(config{ip,3}));
					end
					disp(str)
				end%for ip
			otherwise
				varargout(1) = {config};
		end%switch
	case {1,2} % We retrieve one config information
		prop = varargin{1};
		[a ip] = intersect(config(:,1),prop);		
		varargout(1) = {config{ip,3}};
	otherwise
		error('copoda_readconfig bad number of arguments');
end



end %functioncopoda_readconfig
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
			if tline(1) ~= '#' % Not a commented line
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cleanprop = retrievevalue(tline,typ,varargin)

switch typ

	case 3 % <parameter name="param_name" type="matlab type">value</parameter>
		iso = strfind(tline,'<');
		isc = strfind(tline,'>');
		if length(iso) ~= 2 & length(isc) ~= 2
			disp('Something''s wrong with this property')
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function p = class_home()
	p = strrep([mfilename('fullpath') '.m'],[mfilename '.m'],'');
	p = strrep(fileparts(which('transect')),'@transect','');
end


