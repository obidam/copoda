% size Compute the size of a Database object
%
% [Nt Ns Nz] = size(D,[DIMi,DIMj,DIMk])
% 
% Compute the size of a Database object D
% 
% Nt: Number of Transect(s)
% Ns: Total number of stations
% Nz: Total number of vertical levels (samples)
%
% Created: 2010-04-22.
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


function varargout = size(D,varargin)

narg = nargin - 1;
if narg == 1
	idim = varargin{1};
else
	idim = 0;
end
if ~isempty(find(idim > 3))
	error('Database objects have only 3 dimensions')
end

switch nargout
	case 0
		switch idim
			case 0, [n(3) n(2) n(1)] = get_nz(D);
			case 1, n = get_nt(D);
			case 2, n = get_ns(D);
			case 3, n = get_nz(D);
		end
		varargout(1) = {n};
		return		
		
	case 1
	
		switch idim
			case 0, [n(3) n(2) n(1)] = get_nz(D); % This is what appears in a 'whos T' statement
			case 1,     n = get_nt(D);
			case 2,     n = get_ns(D);
			case 3,     n = get_nz(D);
		end
		varargout(1) = {n};
		return
	
	case 2
	
		if narg == 0
			[n(2) n(1)] = get_ns(D);
			varargout(1) = {n(1)};
			varargout(2) = {n(2)};
			return			
		elseif narg == 2
			[n(3) n(2) n(1)] = get_nz(D);
			varargout(1) = {n(varargin{1})};
			varargout(2) = {n(varargin{2})};
			return
		elseif narg == 1 | narg == 3
			error('Please specify the 2 dimensions you want ...');
		end

	case 3
		if narg == 3
			[n(3) n(2) n(1)] = get_nz(D);
			varargout(1) = {n(varargin{1})};
			varargout(2) = {n(varargin{2})};
			varargout(3) = {n(varargin{3})};
			return
		elseif narg == 0	
			[n(3) n(2) n(1)] = get_nz(D);
			varargout(1) = {n(1)};
			varargout(2) = {n(2)};
			varargout(3) = {n(3)};
			return
		else
			error('Please specify the 3 dimensions you want ...');		
		end
			
end

	
end %functionsize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NT = get_nt(D);
	nt = length(D.transect);
	nt_empty = 0;
	for it = 1 : nt
		if isempty(D.transect{it})
			nt_empty = nt_empty + 1;
		end
	end
	NT = nt - nt_empty;
end


function [NS NT] = get_ns(D);
	nt = length(D.transect);
	nt_empty = 0;
	ns = zeros(1,nt);
	for it = 1 : nt
		if isempty(D.transect{it})
			nt_empty = nt_empty + 1;
		else
			ns(it) = D.transect{it}.cruise_info.N_STATION;
		end
	end
	NT = nt - nt_empty;
	NS = sum(ns);
end


function [NZ NS NT] = get_nz(D);
	nt = length(D.transect);
	nt_empty = 0;
	ns = zeros(1,nt);
	nz = zeros(1,nt);
	for it = 1 : nt
		if isempty(D.transect{it})
			nt_empty = nt_empty + 1;
		else
			ns(it) = D.transect{it}.cruise_info.N_STATION;
			nz(it) = max([size(D.transect{it}.geo.PRES,2) ; size(D.transect{it}.geo.DEPH,2)]);
		end
	end
	NT = nt - nt_empty;
	NS = sum(ns);
	NZ = sum(nz.*ns);
end





