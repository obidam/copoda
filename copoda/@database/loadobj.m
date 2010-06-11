% loadobj H1LINE
%
% [] = loadobj()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-04-28.
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
function [D v] = loadobj(varargin)

D = varargin{1};

% Curent COPODA version:
v_curent = ver('copoda'); v_curent = v_curent.Version;

% We read the COPODA version in the description file to ensure compatibility:
desc = D.description;
for id = 1 : size(desc,1)
	tline = desc{id,:};
	if strfind(tline,'<copoda version="')		
		ii=strfind(tline,'"');
		v_load = strtrim(tline(ii(1)+1:ii(2)-1));
		iver = id;
	end
end
if exist('iver','var')
	% And remove it from the description
	desc = desc(setdiff(1:size(desc,1),iver),:);
	D.description = desc;
	if ~strcmp(v_curent,v_load)
		warning(sprintf('This database is not in the same version (%s) as the curent one (%s) !\n\t!!! YOU MAY EXPERIENCE TROUBLES !!!',v_load,v_curent));
	end

else
	warning('This database is not associated with a COPODA version number, it must be an incompatible old version !');
end

end %functionloadobj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
