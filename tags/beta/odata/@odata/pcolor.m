% pcolor H1LINE
%
% [] = pcolor()
% 
% HELPTEXT
%
% Created: 2010-03-04.
% Copyright (c) 2010, Guillaume Maze (Laboratoire de Physique des Oceans).
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

function varargout = pcolor(O)

nd = ndims(O.cont);
%nd = nd - length(find(size(O.cont)==1)); % Remove singleton dimensions

switch nd
	case 2
		if ~isempty(O.cont)
			figure;
			sub = plot_2d(O);
			hl = title(title_2d(O));
			set(hl(1),'Interpreter','none','FontName','sans-serif','HorizontalAlignment','center');
			get(hl(1),'position');
			switch nargout
				case 1
					varargout(1) = {sub};
				case 2
					varargout(1) = {sub};
					varargout(2) = {hl};
			end
		else
			error('This field is empty, I can''t pcolor it !');
		end

	otherwise
		error(sprintf('pcolor is not yet defined for %i dimensional odata object, sorry about that !',nd));
end



end %functionpcolor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sub] = plot_2d(O)
	
		C = O.cont;
		if ~isempty(O.dims)
			X = evalin('base',O.dims{1}); x = X.cont;
			Y = evalin('base',O.dims{2}); y = Y.cont;
			[n1 n2] = size(C);
			[nx1 nx2] = size(x);
			if nx1 == n1 & nx2 ~= n2
				[a b] = meshgrid(x,1:n2); x = a'; clear b
			end			
			try
				sub = pcolor(x,y,C);
			catch
				sub = pcolor(x,y,C');
			end
			
			if ~isempty(X.long_name)
				nameX = X.long_name;
			else
				nameX = X.name;
			end
			if ~isempty(Y.long_name)
				nameY = Y.long_name;
			else
				nameY = Y.name;
			end
			if ~isempty(X.long_unit)
				unitX = X.long_unit;
			else
				unitX = X.unit;
			end
			if ~isempty(Y.long_unit)
				unitY = Y.long_unit;
			else
				unitY = Y.unit;
			end
			
			xlabel(sprintf('%s [%s]',nameX,unitX),'interpreter','none');
			ylabel(sprintf('%s [%s]',nameY,unitY),'interpreter','none');

		else
			x = 1:size(O.cont,1);
			y = 1:size(O.cont,2);
			sub = pcolor(x,y,C');
		end

	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = title_2d(O)

str = sprintf('%s\n%s\n%s\n ',...
disp_prop('Long Name [short]',sprintf('%s [%s]',O.long_name,O.name)),...
disp_prop('Long Unit [short]',sprintf('%s [%s]',O.long_unit,O.unit)),...
disp_prop('Content statistics',sprintf('Max=%f, Min=%f, Mean=%f, STD=%f',...
							nanmax(O.cont(:)),nanmin(O.cont(:)),...
							nanmean(O.cont(:)),nanstd(O.cont(:))))...
	...
	);

end %function

%%%%%%%%%%%%%%%%%%%
function str = disp_prop(name,value)
	blk = ' ';	
	str = sprintf('%5s %20s: %s',blk,name,value);	
end
