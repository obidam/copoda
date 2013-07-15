% simplify_text H1LINE
%
% [] = simplify_text()
% 
% HELPTEXT
%
%
% Created: 2009-08-26.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function t = simplify_text(t1,t2,op)

oplist = '-+';

switch op
	case '-'
		if strfind(t1,t2)
			t  = strrep(t1,t2,'');
			
			% Try to find an operator at the beginning to remove:
			if length(t) ~=0			
				tp = strrep(t,' ',''); tp = tp(1);
				if strfind(oplist,tp)
					t(min(strfind(t,oplist(strfind(oplist,tp))))) = '';
				end
				% try to find an operator at the end to remove:
				tp = strrep(t,' ',''); tp = tp(end);
				if strfind(oplist,tp)
					t(max(strfind(t,oplist(strfind(oplist,tp))))) = '';
				end
				t = dblk1(t);
			end
		else
			t = sprintf('%s - %s',t1,t2);
		end
	case '+'	
		if strfind(t1,t2)
			t = sprintf('%s + %s',t1,t2);
		else	
			t = sprintf('%s + %s',t1,t2);
		end
end

end %function

% Remove empty space at the beginning of the string:
function t = dblk1(t)
	done = 0;
	while done ~= 1
		if t(1) == ' '
			t = t(2:end);
		else
			done = 1;
		end
	end%while
	done = 0;
	while done ~= 1
		if t(end) == ' '
			t = t(1:end-1);
		else
			done = 1;
		end
	end%while
end
