% grep Look for a string into database's transect cruise NAMEs
%
% iT = grep(D,PATTERN,[INDEX])
% 
% Look for a string into database's transect cruise NAMEs
%
% Inputs:
%	D: database object
%	PATTERN: the string to look for (you can use regexp syntax)
%	INDEX: a double with transect indices within D to restrict the
%		search to. It is optional and by default we search the entire
%		database object
%
% Outputs:
%	iT: indices of transect with cruise name matching the search
%
% Examples:
%	iT = grep(D,'OVIDE')
%	iT = grep(D,'OVI*')
%	iT = grep(D,'A25',1:10)
%	D(grep(D,'OVI*')).cruise_info.NAME
%
% See also:
%	regexp
%
% Note:
%	Options order PATTERN then INDEX is not necessary:
%		iT = grep(D,'OVIDE',1:10)
%		iT = grep(D,1:10,'OVIDE')
%	return same result.
%	
% Created: 2010-06-15.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = grep(D,varargin)

%%%%%%%%%%%%%%%%%%%% OPTIONs
if nargin ~=2 & nargin ~=3 
	error('Bad number of arguments');
end

switch nargin
	case 2
		a = varargin{1};
		switch class(a)
			case {'double','cell'}
				error('Search pattern must be a string');
			case 'char'
				PATT = a;
				it = 1 : length(D);
				clear a
		end
	case 3		
		for ii = 1 : 2
			a = varargin{ii};
			switch class(a)
				case 'double'
					it = a;
					clear a
				case 'char'
					PATT = a;
					clear a
				otherwise
					error('Bad argument class, see help database/grep');
			end
		end%for ii
		clear ii
end%switch

%%%%%%%%%%%%%%%%%%%% SEARCH
namelist = subsref(D,substruct('()',{it},'.','cruise_info','.','NAME'));

found = [];
for it = 1 : size(namelist,1)
	if ~isempty(regexp(namelist{it},PATT))
		found = cat(1,found,it);
	end		
end%for it

%%%%%%%%%%%%%%%%%%%% 
varargout(1) = {found};

end %functiongrep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



















