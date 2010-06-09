%DEF Create a database object with all North Atlantic Argo floats equiped with oxygen sensors since 2003/1/1
%REQ
%
% This function is not intended to be called directly !
%
% For more details, type: 
%	create_custom_database(8,1)
%
% Created: 2009-11-25.
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

function varargout = off_argoO2database(varargin)

switch nargin
	case 0
		config.PERIOD = datenum(2003,1,1,0,0,0):now;
		config.DOMAIN = [360-90 360 0 90];
		config.WITH_OXYGEN = 1;
		config.NAME = 'O2-NA';
		name = 'Argo-O2 North-Atlantic V1.0';
		desc = {'All North Atlantic Argo floats equiped with oxygen sensors since 2003/1/1';...
			    'No specific validation but classic methods from database/validate and transect/validate'};
	case 1
		switch varargin{1}
			case 1 % O2 - NA
				config.PERIOD = datenum(2003,1,1,0,0,0):now;
				config.DOMAIN = [360-90 360 0 90];
				config.WITH_OXYGEN = 1;
				config.NAME = 'O2-NA';
				name = 'Argo-O2 North-Atlantic V1.0';
				desc = {'All North Atlantic Argo floats equiped with oxygen sensors since 2003/1/1';...
					    'No specific validation but classic methods from database/validate and transect/validate'};
			case 2 % O2 - NP
				config.PERIOD = datenum(2003,1,1,0,0,0):now;
				config.DOMAIN = [120 360-100 0 90];
				config.WITH_OXYGEN = 1;
				config.NAME = 'O2-NP';
				name = 'Argo-O2 North-Pacific V1.0';
				desc = {'All North Pacific Argo floats equiped with oxygen sensors since 2003/1/1';...
					    'No specific validation but classic methods from database/validate and transect/validate'};
		end
end

filo1 = sprintf('%s/Argo%s_floatlist.mat',copoda_readconfig('copoda_userdata_folder'),config.NAME);
filo2 = sprintf('%s/Argo%s.mat',copoda_readconfig('copoda_userdata_folder'),config.NAME);
%filo1 = strrep(mfilename('fullpath'),'off_argoO2database','data/ArgoO2_floatlist.mat');
%filo2 = strrep(mfilename('fullpath'),'off_argoO2database','data/ArgoO2.mat');

PERIOD = config.PERIOD;
DOMAIN = config.DOMAIN;
WITH_OXYGEN = config.WITH_OXYGEN;

if ~exist(filo1,'file')
	% This is the raw list:
	LIST = argo_get_list_floatID(PERIOD,DOMAIN,WITH_OXYGEN);
	save(filo1,'LIST','PERIOD','DOMAIN','WITH_OXYGEN');
else
	% Check if it needs an update:
	% (we assume float datas are updated every month)
	d = dir(filo1);	
	if str2num(datestr(now,'yyyymm')) > str2num(datestr(d.datenum,'yyyymm'))
		LIST = argo_get_list_floatID(PERIOD,DOMAIN,WITH_OXYGEN);
		save(filo1,'LIST','PERIOD','DOMAIN','WITH_OXYGEN');
	else
		load(filo1);
	end
end

D = database;
D.creator = getenv('USER');
D.name = name;
D.description = desc;

for ifloat = 1 : length(LIST)
	disp(sprintf('Loading float #%i/%i',ifloat,length(LIST)));
	T = argo_load1float(LIST{ifloat},PERIOD,DOMAIN);
	D.transect(ifloat) = T;	
	save(filo2,'D','LIST'); % This is a painful process so we save the database each time
end%for ifloat

% Now we double check if we really have oxygen everywhere:
for iT = 1 : length(D)
	if find(ismember(datanames(D.transect{iT}),'OXYK')==1)
		ikeep(iT) = 1;
	else
		ikeep(iT) = 0;
	end
end
D = reorder(D,find(ikeep==1));
LIST = LIST(ikeep==1);
save(filo2,'D','LIST');


switch nargout
	case 1 
		varargout(1) = {D};
	case 2
		varargout(1) = {D};
		varargout(2) = {LIST};
end

end %function


