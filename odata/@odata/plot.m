% plot Plot an OData object
%
% [] = plot(O)
% 
% Plot an OData object
%
% Created: 2009-07-28.
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

function varargout = plot(O)

nd = ndims(O.cont);
nd = nd - length(find(size(O.cont)==1)); % Remove singleton dimensions

switch nd
	case 1
		if ~isempty(O.cont)
			pc = plot_1d(O);
			tt = title(title_2d(O));
			set(tt,'Interpreter','none','FontName','sans-serif','HorizontalAlignment','center');
		end% if 
		
	case 2
		if ~isempty(O.cont)
			[sub,hl,gc,pc] = plot_2dmean(O);
			set(hl(1),'string',title_2d(O));
			set(hl(1),'Interpreter','none','FontName','sans-serif','HorizontalAlignment','center');
			get(hl(1),'position');
			switch nargout
				case 1
					varargout(1) = {sub};
				case 2
					varargout(1) = {sub};
					varargout(2) = {hl};
				case 3
					varargout(1) = {sub};
					varargout(2) = {hl};
					varargout(3) = {gc};
				case 4
					varargout(1) = {sub};
					varargout(2) = {hl};
					varargout(3) = {gc};
					varargout(4) = {pc};
			end
		else
			error('This field is empty, I can''t plot it !');
		end
	% case 3
	% 	if ~isempty(O.cont)
	% 		plot_3d(O);
	% 	else
	% 		error('This field is empty, I can''t plot it !');
	% 	end
		
	otherwise
		error(sprintf('Plot is not yet defined for %i dimensional odata object, sorry about that !',nd));
end

end %function

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = plot_3d(O)
	
	figure
	sz = size(O.cont);
	iw=2;jw=2;
	subplot(iw,jw,1); 
		pcolor(squeeze(nanmean(O.cont,3))); 
		shading flat; title('Mean along 3rd dimension');
		xlabel('x');ylabel('y');
	subplot(iw,jw,2); 
		p = pcolor(squeeze(O.cont(fix(sz(1)/2),:,:)));
		rotate(p,[0 fix(sz(2)/2) 0],90); view(3);
		shading flat; title('Vertical slice along (y,z) at mid-x');
		xlabel('x');ylabel('y');zlabel('z');
	subplot(iw,jw,3); 
		p = pcolor(squeeze(O.cont(:,fix(sz(2)/2),:)));
		rotate(p,[fix(sz(1)/2) 0 0],90); view(3);
		shading flat; title('Vertical slice along (x,z) at mid-y');
		xlabel('x');ylabel('y');zlabel('z');
	subplot(iw,jw,4); 
		p = pcolor(squeeze(O.cont(:,:,fix(sz(3)/2))));
		rotate(p,[0 0 fix(sz(3)/2)],90); view(3);
		shading flat; title('Horizontal slice along (x,y) at mid-z');
		xlabel('x');ylabel('y');zlabel('z');
	
	
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sub,hl,gc,pc] = plot_2dmean(O)
	
	figure
	C = O.cont;
	x = 1:size(O.cont,1);
	y = 1:size(O.cont,2);
	[sub,hl,gc,pc] = twodmean(x,y,C');
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pc = plot_2d(O)
	
	figure
		C = O.cont;
		if ~isempty(O.dims)
			X = evalin('base',O.dims{1}); x = X.cont;
			Y = evalin('base',O.dims{2}); y = Y.cont;
			[n1 n2] = size(C);
			[nx1 nx2] = size(x);
			if nx1 == n1 & nx2 ~= n2
				[a b] = meshgrid(x,1:n2); x = a'; clear b
			end
		else
			x = 1:size(O.cont,1);
			y = 1:size(O.cont,2);
		end
		try
			pc = pcolor(x,y,C);
		catch
			pc = pcolor(x,y,C');
		end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pc = plot_1d(O)
	
	figure
		C = O.cont;
		s = size(C);
		Ci = 1 : length(C);
		if s(1) == 1
			pc = plot(Ci,C);
			xlabel('Array index');
			ylabel(O.unit);
		else
			pc = plot(C,Ci);
			xlabel(O.unit);		
			ylabel('Array index');
		end% if 
end

%%%%%%%%%%%%%%%%%%%
function str = disp_prop(name,value)
	blk = ' ';	
	str = sprintf('%5s %20s: %s',blk,name,value);	
end



