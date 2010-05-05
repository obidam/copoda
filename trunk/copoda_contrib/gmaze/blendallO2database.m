% blendallO2database Blend all available databases with oxygen
%
% D = blendallO2database()
% 
% Blend all available databases with oxygen.
% This function is not intended to be called directly !
%
% For more details, type: 
%	create_custom_database(9,1) 
%
% Created: 2010-02-05.
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

function d = blendallO2database(varargin)

disp('------------------------------')
d =     create_custom_database(10);
disp('------------------------------')
d = d + create_custom_database(6);
disp('------------------------------')
d = d + create_custom_database(11);
disp('------------------------------')
d = d + create_custom_database(8);
disp('------------------------------')

% Now we need to remove similar stations
% We loop over time, lat and lon, trying to find similar stations
%
 
% [x,y,z,t] = extract(D,'LONGITUDE',{'LATITUDE','DEPH','STATION_DATE'});
% [uTime iu] = unique(t);

% for itime = 1 : length(uTime)
	
% 	for itrans = 1 : length(D)
% 		T = D.transect(itrans);
% 		lit = T.geo.STATION_DATE(:);
		
% 	end

% end	
	
% for it = 1 : length(uTime)
%  	[x,y,z,t] = extract(D,'LONGITUDE',sprintf('STATION_DATE == %i',T(it)),{'LATITUDE'});
	
% end

end %functionblendallO2database














