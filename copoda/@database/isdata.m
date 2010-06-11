% isdata Check if a field is in all the OData transects
%
% [RES,II] = isdata(D,FIELD)
% 
% Check if FIELD (string) is in all the transects of the database D.
%
% Inputs:
%	D: Database object
%	FIELD: a string
%
% Outputs:
%	RES: true/false
%	II: indices of the transects where FIELD is a data
%
%
% Created: 2010-05-05.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = isdata(D,FIELD)

allv = datanames(D,1);
if ~isempty(intersect(allv,FIELD))
	varargout(1) = {true};
	if nargout == 2
		varargout(2) = {1:length(D)};
	end
else
	
end

%for it = 1 : length(D)
%	res(it) = isdata(D.transect{it},FIELD);
%end%for it



end %functionisdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










