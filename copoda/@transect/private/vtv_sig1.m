% vtv_sig1 Compute Potential density referenced to 2000m
%
% [] = vtv_sig1(T,[INDEXSTRUCT])
% 
% Inputs:
%
% Outputs:
%
% Created: 2013-07-26.
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
function varargout = vtv_sig1(varargin)

vtv_name = 'SIG1';
vtv_desc = {'Compute: Potential Density Anomaly referenced to P = 1000'};
switch nargin
	case 0
		varargout(1) = {vtv_name};
		varargout(2) = {vtv_desc};
		return
	otherwise
		T = varargin{1};
		if nargin == 2
			index = varargin{2};
		else		
			index(1).type = '.';
			index(1).subs = 'cont';
			index(2).type = '()';
			index(2).subs = {':' ':'};
		end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if ~isdata(T,'TEMP') & ~isdata(T,'PSAL')
	if isdata(T,'TEMP',0) & isdata(T,'PSAL',0)
		error('I can''t compute Potential Density (SIG1) with empty TEMP and PSAL')
	else
		error('I can''t compute Potential Density (SIG1) without TEMP and PSAL')
	end
else
	
	% TODO Check units !

	% Retrieve temperature and salinity:
	Temp = subsref(T.data.TEMP,index);
	Salt = subsref(T.data.PSAL,index);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

SIG1 = densjmd95(Salt,Temp,abs((0.09998*9.81*1000)*ones(size(Salt)))) - 1000;

varargout(1) = {SIG1};

end %functionvtv_sig1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






















