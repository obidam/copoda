% isdata Check if field is a non-empty odata object within a transect object
%
% TF = isdata(T,FIELD,[OPT])
% 
% Check if FIELD is an odata object and non-empty within a transect object T.
% TF is true/false.
%
% FIELD can be a string or a cell of string.
% Optional parameter OPT is 1 (default) or 0:
%		1 scan non-empty fields having names (EXCLUDING fields 
%			with content set to a NaN)
%		0 scan non-empty fields having names (INCLUDED fields 
%			with content set to a NaN)
%
% Created: 2009-07-31.
% Rev. by Guillaume Maze on 2010-05-28: Add possibility of multiple FIELD names
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


function out = isdata(T,DATA,varargin)

if nargin == 3
	opt = varargin{1};
else
	opt = 1;
end

if ~iscell(datanames(T,opt))
	out  = false;
else
	out = false;
	fields = datanames(T,opt);
	if isa(DATA,'cell')
		for id = 1 : length(DATA)
			out(id) = false;
			for iv = 1 : length(fields)
				if strcmp(fields{iv},DATA{id})
					out(id) = true;
				end
			end%for iv
		end%for id	
	else	
		for iv = 1 : length(fields)
			if strcmp(fields{iv},DATA)
				out = true;
			end
		end
	end%if
end

end %function






