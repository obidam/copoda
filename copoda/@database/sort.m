% sort Sort transect objects of a database
%
% [Ds,I] = sort(D,[PROPERTY,MODE])
% 
% Sort by PROPERTY all transect objects of a database D.
% By default the database is sorted by ascending cruise_info property DATE.
%
% Inputs:
%	D is a database object.
%
%	PROPERTY selects the property along which to sort. It can be
%		any fields from:
%		- cruise_info properties (NAME, PI_NAME, PI_ORGANISM, 
%		  SHIP_NAME, SHIP_WMO_ID, DATE and N_STATION).
%		- transect simple properties (source, creator, file, 
%		  file_date, created and modified).
%	MODE selects the direction of the sort:
%		'ascend' results in ascending order,
%		'descend' results in descending order.
%
% Outputs:
%	Ds is the sorted database object
%	I is the index matrix so that: Ds = reorder(D,I).
%
% Created: 2011-06-06.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = sort(D,varargin)

%- Sorting options:	
PROP = 'DATE';
MODE = 'ascend';
switch nargin
	case 1, % Use default
	case 2
		PROP = varargin{1};
	case 3
		PROP = varargin{1};
		MODE = varargin{2};
end% switch 

%- Sort the database:

%-- Get the property along which to sort:
cruise_prop   = {'NAME', 'PI_NAME', 'PI_ORGANISM', 'SHIP_NAME', 'SHIP_WMO_ID', 'DATE', 'N_STATION'};
transect_prop = {'source', 'creator', 'file', 'file_date', 'created', 'modified'};

for iT = 1 : length(D)
	if ~isempty(find(ismember(cruise_prop,PROP)==1))		
		eval(sprintf('thisprop = D.transect{iT}.cruise_info.%s;',PROP));
	elseif ~isempty(find(ismember(transect_prop,PROP)==1))
		eval(sprintf('thisprop = D.transect{iT}.%s;',PROP));
	end% if 
	if find(isnan(thisprop)==1)
		thisprop = 'NaN';
	end% if 
	switch PROP
		case {'NAME', 'PI_NAME', 'PI_ORGANISM', 'SHIP_NAME','source', 'creator', 'file'}
			% A string
			props(iT,1) = {thisprop};
		case {'DATE', 'N_STATION','file_date', 'created', 'modified'}
			% A double
			props(iT,1) = {num2str(thisprop(1))};
		case 'SHIP_WMO_ID'
			if ~ischar(thisprop)
				props(iT,1) = num2str(thisprop);					
			else
				props(iT,1) = {thisprop};					
			end% if 
		otherwise
			error('We shouldn''t be here !')
	end% switch 
end% for iT

[props_sorted ii] = sort(props);
switch MODE
	case 'ascend'
		% Nothing to do
	case 'descend'
		% Flip it
		ii = flipud(ii);
end% switch 


%-- Reorder transects:
if exist('ii','var')
	D = reorder(D,ii);
end% if 

%- Output:
D.modified = now;
switch nargout
	case {0,1}
		varargout(1) = {D};
	case 2
		varargout(1) = {D};
		varargout(2) = {ii};
end% switch 

end %functionsort
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%














