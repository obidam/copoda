% vertcat Concatenate two, or more, databases
%
% D = vertcat(D1, D2, ...)
% 
% Concatenate two, or more, databases.
% 
% D = [D1;D2] is the concatenation of database D1 and D2, ie
% it is a database with all the transects from D1 and D2.
% 
% Note that the meta data from D = [D1;D2] are those 
% inherited from D1.
%
% Inputs: 2 or more database objects
%
% Outputs: 1 database object with meta data from the first concatenated one
%
%
% Created: 2013-06-11.
% http://code.google.com/p/copoda
% Copyright 2013, COPODA

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
function Dout = vertcat(varargin)

Dout = varargin{1}; 
iT   = length(Dout);

for iD = 2 : nargin
	for ii = 1 : length(varargin{iD})
		if ~isa(varargin{iD},'database')
			error('Vertical concatenation is only for database objects !')
		end% if 
		iT = iT + 1;
		Dout.transect(iT) = varargin{iD}.transect(ii);
	end% for ii
end% for id

end %functionvertcat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





















