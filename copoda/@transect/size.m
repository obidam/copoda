% size Give back number of stations and samples
%
% [Ns Nz] = size(T)
% 
% From T.data fields, give back the number of stations Ns
% and the number of samples Nz at each stations.
%
%	Ns = size(T,1);
%	Nz = size(T,2);
%	[Ns Nz] = size(T);
%
% Created: 2010-04-02.
% http://code.google.com/p/copoda
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


function varargout = size(T,varargin)

%%%%%%%%%%%%%%%%% METHOD 1
% This is the original method where we look for a real odata object and get its size:
% d  = datanames(T,1);
% done = 0; id = 0;
% while done ~= 1
%  	id = id + 1;
% 	if id > length(d), error('Can''t find any Real variable to compute the size of this Transect object'); end
% 	if dstatus(T,d{id}) == 'R' 
% 		od = getfield(T.data,d{id});
% 		[Ns Nz] = size(od);
% 		done = 1;
% 	end
% end

%%%%%%%%%%%%%%%%% METHOD 2
% This is the new method, suited to manipulate transect object only with geo and meta informations

% From geo properties, only the STATION_NUMBER is supposed to be unique for each profiles and is
% therefore the perfect candidate to infer the first dimension:
% size(STATION_NUMBER) = N_STATIONS x 1
par = 'STATION_NUMBER';
% par = 'STATION_DATE';
% par = 'STATION_NUMBER';
% par = 'LATITUDE';
% par = 'LONGITUDE';
PAR = subsref(T,substruct('.','geo','.',par));
Ns = size(PAR,1);
if size(PAR,2) ~= 1
	warning('geo property %s should be N_STATIONS x 1');
end

if numel(PAR) == 1 & PAR == 9999 % 
	Ns = 0;
end

% From geo properties again, we look for property PRES or DEPH to determine the number of vertical levels:
% These fields should like: N_STATIONS x N_LEVELS or 1 x N_LEVELS
if isfield(T.geo,'PRES')
	N(1,:) = size(subsref(T,substruct('.','geo','.','PRES')));
else
	N(1,:) = [NaN NaN];
end
if isfield(T.geo,'DEPH')
	N(2,:) = size(subsref(T,substruct('.','geo','.','DEPH')));
else
	N(2,:) = [NaN NaN];
end

if length(find(isnan(N)==1))==4
	error('Cannot determine the size of this transect because PRES and DEPH not defined');
else
	if ~isnan(N(1,2))
		Nz = N(1,2);
		if ~isnan(N(2,2))
			if Nz ~= N(2,2)
				warning('PRES and DEPH don''t have similar dimensions !');
			end
		end
	elseif ~isnan(N(2,2))
		Nz = N(2,2);
	else
		error('Cannot determine the size of this transect because PRES and DEPH not formed properly');		
	end
end
if ~isnan(N(1,:))
	if sum(N(1,:),2) == 2 
		if subsref(T,substruct('.','geo','.','PRES','()',{1})) == 9999
			Nz = 0;
		end
	end
elseif ~isnan(N(2,:))
	if sum(N(2,:),2) == 2 
		if subsref(T,substruct('.','geo','.','DEPH','()',{1})) == 9999
			Nz = 0;
		end
	end
end

%%%%%%%%%%%%%%%%% Output
switch nargout
	case 0
		switch nargin-1
			case 0, [Ns Nz]
			case 1, 
				switch varargin{1}
					case 1, varargout(1) = {Ns};
					case 2, varargout(1) = {Nz};
					otherwise
						error('Transect objects have only 2 dimensions !');
				end				
			otherwise
				error('Bad number of arguments')
		end
	case 1, 
		switch nargin-1
			case 0, varargout(1) = {[Ns Nz]}; % This is what appears in a 'whos T' statement
			case 1, 
				switch varargin{1}
					case 1, varargout(1) = {Ns};
					case 2, varargout(1) = {Nz};
					otherwise
						error('Transect objects have only 2 dimensions !');
				end
			otherwise
				error('Bad number of arguments')
		end
	case 2, 
		varargout(1) = {Ns};
		varargout(2) = {Nz};
		
end

end %functionsize









