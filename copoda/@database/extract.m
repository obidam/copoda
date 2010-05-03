% extract Extract values from a database content
%
% [C [C1 C2 ...]] = extract(D,VARN,[CRITER,VARL])
% 
% Loop through all transects objects within the database D and
% get values of field VARN selected, eventualy, according to
% the selection criteria CRITER.
% Type:
%	help transect/extract
% for more details.
%
%
% Created: 2009-09-20.
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


function varargout = extract(D,varargin)

error(nargchk(1,3,nargin-1,'struct'));
switch nargin-1
	case 1
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end
		if nargout ~= 1
			error(sprintf('Number of outputs must match number of fields extracted (here: N=1)'));
		end
	case 2
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end

		v2 = varargin{2};
		if ischar(v2)
			crite = varargin{2};
		elseif iscell(v2)
			varnL = varargin{2};
			if nargout ~= 1+length(varnL)
				error(sprintf('Number of outputs must match number of fields extracted (here: N=%i)',1+length(varnL)));
			end
		else
			error('3rd argument must be a string (CRITER) or a cell (VARL)');
		end

	case 3
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end

		v2 = varargin{2};
		v3 = varargin{3};
		if ischar(v2) & iscell(v3)
			crite = varargin{2};
			varnL = varargin{3};
		elseif iscell(v2) & ischar(v3) 
			varnL = varargin{2};
			crite = varargin{3};
		else
			error('3rd and 4th arguments must be a string (CRITER) or a cell (VARL)');
		end

		if nargout ~= 1+length(varnL)
			error(sprintf('Number of outputs must match number of fields extracted (here: N=%i)',1+length(varnL)));
		end
end%switch		

if ~exist('varnL')
	if exist('crite')
		C = 9999;
		for it = 1 : length(D)
			C = cat(2,C,extract(D.transect{it},varn1,crite));
		end % for it
	else
		C = 9999;
		for it = 1 : length(D)
			C = cat(2,C,extract(D.transect{it},varn1));
		end % for it	
	end %if
	C = C(C~=9999);
	C = C(isnan(C)==0);
	varargout(1) = {C};
	
elseif exist('varnL')
	if exist('crite')
		Clist = 'C0';
		clist = 'c0';
		for iv = 1 : length(varnL)
			Clist = [Clist sprintf(' C%i',iv)];
			clist = [clist sprintf(' c%i',iv)];
		end		
		for iv = 0 : length(varnL)
			eval(sprintf('C%i=9999;',iv));
		end
		for it = 1 : length(D)	
			eval(sprintf('[%s] = extract(D.transect{it},varn1,crite,varnL);',clist));
			for iv = 0 : length(varnL)
				eval(sprintf('C%i = cat(2,C%i,c%i);',iv,iv,iv));
			end%for iv
		end%for it
		ii = find(C0~=9999 & isnan(C0)==0);
		for iv = 0 : length(varnL)
			eval(sprintf('varargout(iv+1) = {C%i(ii)};',iv));
		end%for iv
	else
		Clist = 'C0';
		clist = 'c0';
		for iv = 1 : length(varnL)
			Clist = [Clist sprintf(' C%i',iv)];
			clist = [clist sprintf(' c%i',iv)];
		end		
		for iv = 0 : length(varnL)
			eval(sprintf('C%i=9999;',iv));
		end
		for it = 1 : length(D)	
			eval(sprintf('[%s] = extract(D.transect{it},varn1,varnL);',clist));
			for iv = 0 : length(varnL)
				eval(sprintf('C%i = cat(2,C%i,c%i);',iv,iv,iv));
			end%for iv
		end%for it
		ii = find(C0~=9999 & isnan(C0)==0);
		for iv = 0 : length(varnL)
			eval(sprintf('varargout(iv+1) = {C%i(ii)};',iv));
		end%for iv
	end%if
	
end%if

end %function



