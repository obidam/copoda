% size Give back number of stations and samples
%
% [Ns Nz] = size(T)
% 
% From T.data fields, give back the number of stations Ns
% and the number of samples Nz at each stations.
%
%	Ns = size(T,1);
%	Nz = size(T,2);
%	[Ns Nz] = size(T);
%
% Created: 2010-04-02.
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


function varargout = size(T,varargin)

d  = datanames(T,1);
done = 0; id = 0;
while done ~= 1
 	id = id + 1;
	if id > length(d), error('Can''t find any Real variable to compute the size of this Transect object'); end
	if dstatus(T,d{id}) == 'R' 
		od = getfield(T.data,d{id});
		[Ns Nz] = size(od);
		done = 1;
	end
end

switch nargout
	case 0
		switch nargin-1
			case 0, [Ns Nz]
			case 1, 
				switch varargin{1}
					case 1, varargout(1) = {Ns};
					case 2, varargout(1) = {Nz};
					otherwise
						error('Transect objects have only 2 dimensions !');
				end				
			otherwise
				error('Bad number of arguments')
		end
	case 1, 
		switch nargin-1
			case 0, varargout(1) = {[Ns Nz]}; % This is what appears in a 'whos T' statement
			case 1, 
				switch varargin{1}
					case 1, varargout(1) = {Ns};
					case 2, varargout(1) = {Nz};
					otherwise
						error('Transect objects have only 2 dimensions !');
				end
			otherwise
				error('Bad number of arguments')
		end
	case 2, 
		varargout(1) = {Ns};
		varargout(2) = {Nz};
		
end

end %functionsize









