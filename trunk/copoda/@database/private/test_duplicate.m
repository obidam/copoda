% test_duplicate 3: 
%
% [] = test_duplicate()
% 
% HELPTEXT
%
% Created: 2010-02-11.
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

function varargout = test_duplicate(varargin)

test_name = 'Remove duplicate stations';
test_desc = {'Remove duplicate stations in the database (same latitude, longitude and dates)'};
res   = false;
fixed = false;
switch nargin
	case 0
		varargout(1) = {3}; % ID of the test
		varargout(2) = {test_desc};
		varargout(3) = {test_name};
		return
	otherwise
		D		= varargin{1};
		verbose = varargin{2};
		fixe 	= varargin{3};
end	
msg(1).test_name   = test_name;

%%% First, we get x, y, t for all the stations:
% We can't use extract because we need cruise informations to identify each station
nt = length(D);
istat = 0;
for it = 1 : nt
	T = D.transect{it};
	for is = 1 : T.cruise_info.N_STATION
		istat = istat + 1;
		ST(istat,1) = T.geo.STATION_DATE(is); % Date
		ST(istat,2) = T.geo.LATITUDE(is);     % Lat
		ST(istat,3) = T.geo.LONGITUDE(is);    % Long
		ST(istat,4) = it; % Transect 
	end%for is
end%for it

% Duplicate dates (on a daily precision):
[Ddup DIdup] = duplicate(ST(:,1),0); 
Dfixed = D;
foundup = false;
for iD = 1 : length(Ddup)	
	ii = DIdup{iD};
	% Now look for duplicate latitude for each duplicated dates:
	[Ydup YIdup] = duplicate(ST(ii,2));
	if ~isempty(Ydup)
		for iY = 1 : length(Ydup)	
			ii2 = YIdup{iY};
			% Now look for duplicate longitude for each duplicated dates and latitude:
			[Xdup XIdup] = duplicate(ST(ii(ii2),3));
			if ~isempty(Xdup)
				for iX = 1 : length(Xdup)	
					res = false; fixed = false; % If make it through here, we found duplicates
					foundup = true;
					ii3  = XIdup{iX};
					idup = ii(ii2(ii3));
					idup = unique(idup);
					idup = ST(idup,4);
					if verbose(1)
						disp(sprintf('The following transect(s) have a duplicate station at %s, %0.3f / %0.3f',datestr(Ddup(iD)),Xdup(iX),Ydup(iY)));
						for ik = 1 : length(idup)
							disp(sprintf('\t #%i: %s (%s)',idup(ik),D.transect{idup(ik)}.cruise_info.NAME,D.transect{idup(ik)}.cruise_info.SHIP_NAME));
						end
					end
					if fixe
						try
							% How to fix this ?
							% An automatic rule, without asking the user which one to keep, is to keep only the first occurence of duplicate
							% We do this by reordering individual transects after finding the duplicate station
							for ik = 2 : length(idup)
								iT = idup(ik);
								ikeep = find(fix(D.transect{iT}.geo.STATION_DATE) ~= Ddup(iD) & D.transect{iT}.geo.LATITUDE ~= Ydup(iY) & D.transect{iT}.geo.LONGITUDE ~= Xdup(iX));
								Dfixed.transect{iT} = reorder(D.transect{iT},1,ikeep);
							end
							fixed = true;
							res   = true;
						catch
							fixed = false;
							res   = false;
						end
					end%if try to FIXE
				end%for iX
			end%if		
		end%for iY		
	end%if
end%for iD

%keyboard
if foundup & verbose(1)
	switch fixe
		case true
			switch fixed
				case true
					disp_res('Result','OK (fixed)',verbose(1))
				case false
					disp_res('Result','Echec (not fixed)',verbose(1))
			end			
		case false			
			disp_res('Result','Echec (found duplicates, you should try to fix)',verbose(1))			
	end
elseif foundup & ~verbose(1)
elseif ~foundup 
	res = true;
	fixed = true;
	if verbose(1)
		disp_res('Result','OK',verbose(1))
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%% FOOTER
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {fixed};
	varargout(3) = {Dfixed};
	varargout(4) = {msg};
end


end %functiontest_duplicate













