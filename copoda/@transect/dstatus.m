% dstatus Return the status of a variable in transect datas
%
% [S1,S2] = dstatus(T,VARNAME,[OPT])
% 
% Return the status of the variable called VARNAME in the
% transect object T.data property.
%
% Inputs:
%	T: a Transect object
%	VARNAME: a single name for a variable
%	OPT: 0 (default) or 1, determine the outputs, see below.
%
% Outputs:
%	if OPT = 0 (default): 
%		S1: status of the variable
%		S2: index of the variable among tables STATION_PARAMETERS and PARAMETERS_STATUS
%	if OPT = 1:
%		S1: index of the variable among tables STATION_PARAMETERS and PARAMETERS_STATUS
%		S2: status of the variable
%
% See also:
%	setstatus
%
% Created: 2010-04-20.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Tags for documentation:
%TAGS dev-level,status,variable

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


function varargout = dstatus(T,VARNAME,varargin)

% Get the list of datas:
varlist = datanames(T);

% 
[a iS] = intersect(varlist,VARNAME);

if ~isempty(iS)
    S = T.data.PARAMETERS_STATUS(iS);	
else
	error('Variable not defined in this Transect object');
end

switch nargin
	case 3
		switch varargin{1} % OPT
			case 1 % OPT = 1
				switch nargout
					case {0,1}
						varargout(1) = {iS};
					case 2
						varargout(1) = {iS};						
						varargout(2) = {S};
				end%switch
				
			otherwise % (DEFAULT) OPT not equal to 1
				switch nargout
					case {0,1}
						varargout(1) = {S};
					case 2
						varargout(1) = {S};						
						varargout(2) = {iS};
				end%switch								
		end

	otherwise
		switch nargout
			case {0,1}
				varargout(1) = {S};
			case 2
				varargout(1) = {S};						
				varargout(2) = {iS};
		end%switch
end

end %functiondstatus
















