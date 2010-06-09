% setfield H1LINE
%
% [] = setfield()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-06-08.
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
function T = setfield(T,varargin)

arglen   = length(varargin);
strField = varargin{1};
if (arglen==2)
	T = subsasgn(T,substruct('.',deblank(strField)),varargin{end});
    return
end

subs = varargin(1:end-1);
types = cell(1,arglen-1);
for i = 1:arglen-1
    index = varargin{i};
    if (isa(index, 'cell'))
        types{i} = '()';
    elseif ischar(index)        
        types{i} = '.';
        subs{i} = deblank(index); % deblank field name
    else
        error('COPODA:transect:setfield:InvalidType','Inputs must be either cell arrays or strings.');
    end
end

try
   T = subsasgn(T,struct('type',types,'subs',subs),varargin{end});
catch
   error('COPODA:transect:setfield', lasterr)
end




end %functionsetfield
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
