% supported_variables List supported variables in Transect object property data
%
% [] = supported_variables(T)
% 
% List supported variables in Transect object property data
%
% Created: 2010-04-20.
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


function varargout = supported_variables(varargin)

dl = data_list;
if isfield(dl,'STATION_PARAMETERS')
	dl = rmfield(dl,'STATION_PARAMETERS');
end
if isfield(dl,'PARAMETERS_STATUS')
	dl = rmfield(dl,'PARAMETERS_STATUS');
end
dn = fieldnames(dl);

% Output format:
typ = 'html';
if nargin > 1
	typ = varargout{2};
end
global diag_screen_default
diag_screen_default.PIDlist = [1 2];
fid = fopen('toto.html','w');
diag_screen_default.fid = fid;
diag_screen_default.forma = '%s\n';
%diag_screen('Hello world');

% Init output:
switch typ
	case 'html'
		diag_screen(sprintf('<div align="center">'));
		diag_screen(sprintf('\t<table border="1" bordercolor="#000000" cellpadding="3" cellspacing="0">'));
		diag_screen(sprintf('\t\t<tbody>'));
		diag_screen(sprintf('\t\t<tr>'));
		diag_screen(sprintf('\t\t\t<td> Property </td>'));
		diag_screen(sprintf('\t\t\t<td> Variable name (short/long) </td>'));
		diag_screen(sprintf('\t\t\t<td> Variable unit (short/long) </td>'));
		diag_screen(sprintf('\t\t</tr>'));
end


% Create output
for iv = 1 : length(dn)
	od = getfield(dl,dn{iv});
	switch typ
		case 'html'
			diag_screen(sprintf('\t\t<tr>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s',dn{iv}));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s<br>%s',od.name,od.long_name));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s<br>%s',od.unit,od.long_unit));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t</tr>'));		
		case 'latex'
	end
end

% Finish ouput
switch typ
	case 'html'
		diag_screen(sprintf('\t\t</tbody>'));
		diag_screen(sprintf('\t</table>'));	
		diag_screen(sprintf('</div>'));	
end

end %functionsupported_variables











