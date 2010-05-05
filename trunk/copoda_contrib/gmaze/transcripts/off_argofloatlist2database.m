% argofloatlist2database Create a database object from a list of Argo floats IDs
%
% D = argofloatlist2database(LIST)
% 
% Create a database object from a list of Argo floats IDs
%
% Created: 2010-02-15.
% Copyright (c) 2010, Guillaume Maze (Laboratoire de Physique des Oceans).
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

function varargout = argofloatlist2database(LIST)

D = database;
D.creator = getenv('USER');
D.name = 'Custom Argo database';
D.description = descfromlist(LIST);

for ifloat = 1 : length(LIST)
	disp(sprintf('Loading float #%i/%i',ifloat,length(LIST)));
	T = argo_load1float(LIST{ifloat});
	D.transect(ifloat) = T;	
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

switch nargout
	case 1 
		varargout(1) = {D};
	case 2
		varargout(1) = {D};
		varargout(2) = {LIST};
end


end %functionargofloatlist2database


function STR = descfromlist(LIST)
	STR = sprintf('Floats IDs: %s',LIST{1});
	if length(LIST)>=2
		for il = 2 : length(LIST)
			STR = sprintf('%s; %s',STR,LIST{il});
		end%for il
	end%if
	STR = {STR};
end%function










