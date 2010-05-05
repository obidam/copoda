% argo2database Create a database object with ANY Argo floats for a given year over the North-Atlantic
%
% D = argo2database(YEAR)
% 
% Create a database with ANY Argo floats for a given year over the North-Atlantic
% Input:
%	YEAR (double) is any year from 2003 to 2009
% Output:
%	D is the database object
%		with one transect per Argo float
%
% Created: 2009-12-06.
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

function varargout = argo2database(varargin)

if nargin >= 1
	YEAR = varargin{1};
else
	YEAR = str2num(datestr(now,'yyyy'));
end

PERIOD = datenum(YEAR,1,1,0,0,0):datenum(YEAR,12,31,23,59,59);
DOMAIN = [360-100 360 0 90];
WITH_OXYGEN = 0;

filo1 = sprintf('%s_%i.mat',strrep(mfilename('fullpath'),'argo2database','data/Argo_floatlist'),YEAR);
filo2 = sprintf('%s_%i.mat',strrep(mfilename('fullpath'),'argo2database','data/Argo'),YEAR);

if ~exist(filo1,'file')
	% This is the raw list:
	LIST = argo_get_list_floatID(PERIOD,DOMAIN,WITH_OXYGEN);
	save(filo1,'LIST','PERIOD','DOMAIN','WITH_OXYGEN');
else
	load(filo1);
end

D = database;
D.creator = getenv('USER');
D.name = sprintf('Argo %i North-Atlantic V1.0',YEAR);
D.description = {sprintf('All North Atlantic Argo floats for the year %i',YEAR);...
			  	'No specific validation but classic methods from database/validate and transect/validate'};

ifloatok = 0;
for ifloat = 1 : length(LIST)
	disp(sprintf('Loading float #%i/%i',ifloat,length(LIST)));
	T = argo_load1float(LIST{ifloat},PERIOD,DOMAIN);
	if isa(T,'transect')
		ifloatok = ifloatok + 1;
		D.transect(ifloatok) = T;	
		save(filo2,'D','LIST'); % This is a painful process so we save each time
	end
end%for ifloat
save(filo2,'D','LIST');


switch nargout
	case 1 
		varargout(1) = {D};
	case 2
		varargout(1) = {D};
		varargout(2) = {LIST};
end

end %functionargo2database