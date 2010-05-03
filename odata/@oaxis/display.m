% display H1LINE
%
% [] = display()
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

function varargout = display(O)

disp('OAxis object content description =======================================================');

disp_prop('Long Name [short]',sprintf('%s [%s]',O.long_name,O.name));
disp_prop('Long Unit [short]',sprintf('%s [%s]',O.long_unit,O.unit));
disp_prop('Content statistics',sprintf('Max=%f, Min=%f, Mean=%f, STD=%f',...
							nanmax(O.cont(:)),nanmin(O.cont(:)),...
							nanmean(O.cont(:)),nanstd(O.cont(:))));
if ~isempty(O.prec)
	disp_prop('Precision',sprintf('Max=%f, Min=%f',...
								nanmax(O.prec(:)),nanmin(O.prec(:))));
end
if ~isempty(O.prec_conv)							
	disp_prop('Precision Convention',O.prec_conv);
end

ns = size(O.cont);str='';
str = sprintf('%i',ns(1));
if ndims(O.cont)>1, for id = 2 : ndims(O.cont)
	str = sprintf('%s x %i',str,ns(id));
end,end		
disp_prop('Dimensions',str)

disp_prop('Axis',sprintf('''%s''',O.axis))

disp('========================================================================================');
end %function



%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end
