% auto_elfun Generate elfun functions for odata objects
%
% [] = auto_elfun()
% 
% Generate elfun functions for odata objects
% Elementary functions for odata objects are very simple, they
% just apply to the numerical content.
%
% Created: 2013-07-12.
% http://code.google.com/p/copoda
% Copyright 2013, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = auto_elfun(varargin)

% Trigonometric functions:
elfun_list =                  {'sin';'sind';'sinh';'asin';'asind';'asinh'};
elfun_list = cat(1,elfun_list,{'cos';'cosd';'cosh';'acos';'acosd';'acosh'});
elfun_list = cat(1,elfun_list,{'tan';'tand';'tanh';'atan';'atand';'atanh'});
elfun_list = cat(1,elfun_list,{'sec';'secd';'sech';'asec';'asecd';'asech'});
elfun_list = cat(1,elfun_list,{'csc';'cscd';'csch';'acsc';'acscd';'acsch'});
elfun_list = cat(1,elfun_list,{'cot';'cotd';'coth';'acot';'acotd';'acoth'});

% Exponential:
elfun_list = cat(1,elfun_list,{'exp';'expm1'});
elfun_list = cat(1,elfun_list,{'log';'log1p';'log10';'log2';'reallog'});
elfun_list = cat(1,elfun_list,{'pow2';'nextpow2'});
elfun_list = cat(1,elfun_list,{'sqrt';'realsqrt';'nthroot'});

% Complex:
elfun_list = cat(1,elfun_list,{'abs'}); % complex, isreal are special ones !
elfun_list = cat(1,elfun_list,{'angle';'conj';'imag';'real'});

% Rounding and remainder:
elfun_list = cat(1,elfun_list,{'fix';'floor';'ceil';'round'});

% Create of delete elementary functions:
for iel = 1 : length(elfun_list)
	mfile = fullfile('..',sprintf('%s.m',elfun_list{iel}));
	if 1 % Create functions
		fid = fopen(mfile,'w');
		fprintf(fid,'%% %s H1LINE\n\n',upper(elfun_list{iel}));	
		fprintf(fid,'%% Do not edit this function !\n');
		fprintf(fid,'%% This function was generated automatically by auto_elfun.m\n');
		tline = sprintf('function od = %s(od,varargin)\n\tod = elfun(''%s'',od,varargin{:});\nend',elfun_list{iel},elfun_list{iel});
		fprintf(fid,'%s',tline);
		fclose(fid);
	else % Delete functions
		delete(mfile)
	end% if 
end% for iel

end %functionauto_elfun
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
