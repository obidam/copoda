% template_test This is a template for validation tests
%
% [] = template_test(OPTS)
% 
% HELPTEXT
%
% Created: 2010-04-23.
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

function varargout = template_test(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%% HEADER
res   = false;
fixed = false;
test_name = 'This is a short name for the test, print on screen during validation';
test_desc = {'This is the description of your test';'you can use multiple lines and it must be a cell of strings'};
switch nargin
	case 0 % INFORMATIONS RETURNS WHEN NO ARGUMENTS ARE PROVIDED
		varargout(1) = {0};         % THIS IS THE ID OF THE TEST !
		varargout(2) = {test_desc}; % THIS IS ITS DESCRIPTION
		return
	otherwise % Otherwise the 1st argument is the 
		T 		= varargin{1}; % Transect object to be tested
		verbose = varargin{2}; % Do we verbose informations on screen (0/1) ?
		fixe 	= varargin{3}; % Do we try to fix the Transect object (0/1) ?
end
msg(1).test_name   = test_name;
msg(1).test_result = '?';

%%%%%%%%%%%%%%%%%%%%%%%%% THE TEST HERE:



%%%%%%%%%%%%%%%%%%%%%%%%% FOOTER
if nargin ~= 0
	varargout(1) = {res};
	varargout(2) = {msg};
	varargout(3) = {fixed};
	varargout(4) = {T};
end

end %functiontemplate_test