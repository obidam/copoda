% getfield Call to private method transect/subsref
%
% F = getfield(T,'field')
% F = getfield(T,'field',{2})
% 
% Call to transect/subsref
% I implemented this to force all call to a transect object to go through subsref.
% From some function this was not the case.
% This is probably not really clean.
%
% Eg:
%	getfield(T,'data','TEMP')
%
% Created: 2010-03-05.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Tags for documentation:
%TAGS contrib-level,reference

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


function varargout = getfield(T,varargin)

switch nargin - 1
	case 1 %- T.<>
		index = substruct('.',varargin{1});
	case 2 %- T.<>.<>
		index = substruct('.',varargin{1},'.',varargin{2});
	case {3,4} 
		if ~ischar(varargin{3}) 
			%- T.<>.<>(<>)
			index = substruct('.',varargin{1},'.',varargin{2},'()',varargin{3});
		else 
			if nargin - 1 == 4 
				%- T.<>.<>.<>(<>)
				index = substruct('.',varargin{1},'.',varargin{2},'.',varargin{3},'()',varargin{4});
			else 
				%- T.<>.<>.<>
				index = substruct('.',varargin{1},'.',varargin{2},'.',varargin{3});
			end
		end
end

varargout = {subsref(T,index)};

end %functiongetfield













