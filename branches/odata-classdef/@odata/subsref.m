% subsref Subscripted reference: Define how to access object content
%
% b = subsref(a,index)
% 
% Subscripted reference: Define how to access object content.
%
% Created: 2013-07-18.
% Copyright (c) 2013, Guillaume Maze (Ifremer, Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Ifremer, Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

% Matlab reference:
% http://www.mathworks.fr/fr/help/matlab/matlab_oop/indexed-reference-and-assignment.html

function value = subsref(obj,index)

if size(index,2) > 2
	throw(MException('odata:ops','Invalid indexing !'));
end% if 

switch index(1).type
	% Use the built-in subsref for dot notation
	case '.'
		value = builtin('subsref',obj,index);
	
	% Index the numerical content for () notation:
	case '()'
		if length(index)<2
			% Note that obj.cont is passed to subsref
			value = builtin('subsref',obj.cont,index(1));
			return
		else
			value = builtin('subsref',obj,index);
		end% if 

	% No support for indexing using '{}'
	case '{}'
		throw(MException('odata:ops','Cell array indexing not support by odata objects'));
end% switch 

end %functionsubsref