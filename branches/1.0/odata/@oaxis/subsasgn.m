% subsasgn H1LINE
%
% [] = subsasgn()
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


function a = subsasgn(a,index,val)
	
switch index.type
	case '()'
		switch index.subs(:)
			case 1, a.name = val;
			case 2, a.unit = val;
			case 3, 
				if size(val)
					a.cont = val;
				else
				end
			case 4, a.prec = val;			
			case 5, a.prec_conv = val;
			case 6, a.long_name = val;
			case 7, a.long_unit = val;
			case 8, a.axis = val;
			otherwise
				error('Invalid index');
		end
	case '.'
		switch index.subs
			case 'name', a.name = val;
			case 'unit', a.unit = val;
			case 'cont', a.cont = val;
			case 'prec', a.prec = val;
			case 'prec_conv', a.prec_conv = val;
			case 'long_name', a.long_name = val;
			case 'long_unit', a.long_unit = val;
			case 'axis', 
				if isa(val,'char')
					a.axis = val;
				else
					error('OAXIS object dims property must be a string');
				end
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function