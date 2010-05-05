% subsref H1LINE
%
% [] = subsref()
% 
% HELPTEXT
%
% Created: 2009-11-05.
% Copyright (c) 2009, Guillaume Maze (Laboratoire de Physique des Oceans).
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
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used 
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

function b = subsref(a,index)

switch index(1).type
	case '()'
		switch index(1).subs(:)
			case 1, b = a.name;
			case 2, b = a.unit;
			case 3, b = a.cont;
			case 4, b = a.prec;
			case 5, b = a.prec_conv;
			case 6, b = a.long_name;
			case 7, b = a.long_unit;
			case 8, b = a.axis;
			otherwise
				error('Invalid index');
		end
	case '.'
		switch index(1).subs
			case 'name', b = a.name;
			case 'unit', b = a.unit;
			case 'cont', 
				if size(index,2) == 1
					b = a.cont;
				elseif size(index,2) == 2
					b = a.cont;
					b = b(index(2).subs{:});
				else
					error('Invalid index');
				end
			case 'prec', b = a.prec;
			case 'prec_conv', b = a.prec_conv;
			case 'long_name', b = a.long_name;
			case 'long_unit', b = a.long_unit;
			case 'axis',      b = a.axis;
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function