% display H1LINE
%
% [] = display()
% 
% HELPTEXT
%
%
% Created: 2009-07-23.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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

function varargout = display(C)
	
disp('===== Cruise_info object content description:');
blk = ' ';
disp(sprintf('%10s CRUISE INFORMATION(S)',blk));
	if ~isempty(C.NAME),   disp_prop('Name',C.NAME);end
	if ~isempty(C.PI_NAME) 
		if ~isempty(C.PI_ORGANISM)
			disp_prop('PI (Affiliation)',sprintf('%s (%s)',C.PI_NAME,C.PI_ORGANISM));
		else
			disp_prop('PI',C.PI_NAME);
		end
	end
	if ~isempty(C.SHIP_NAME)
		if ~isempty(C.SHIP_WMO_ID)
			disp_prop('Ship (WMO ID)',sprintf('%s (%s)',C.SHIP_NAME,C.SHIP_WMO_ID));
		else
			disp_prop('Ship',C.SHIP_NAME);
		end
	end
	if ~isempty(C.DATE)
		disp_prop('Date',sprintf('From %s to %s (%i days)',...
					datestr(min(C.DATE),'mmm. dd yyyy'),...
					datestr(max(C.DATE),'mmm. dd yyyy'),diff(C.DATE)));
	end	
	if ~isempty(C.N_STATION)
		disp_prop('Number of station(s)',num2str(C.N_STATION))
	end

end %function


%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end





