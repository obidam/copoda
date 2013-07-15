% size Size of OData object content matrix
%
% D = SIZE(OD), for M-by-N content of OD.cont, returns the two-element row vector
% D = [M,N] containing the number of rows and columns in the OData object content.
% For N-D arrays, SIZE(OD) returns a 1-by-N vector of dimension lengths.
% Trailing singleton dimensions are ignored.
%
% [M,N] = SIZE(OD) for OD content, returns the number of rows and columns in
% OD.cont as separate output variables. 
%
% [M1,M2,M3,...,MN] = SIZE(OD) for N>1 returns the sizes of the first N 
% dimensions of the OD content.  If the number of output arguments N does
% not equal NDIMS(X), then for:
%
% N > NDIMS(OD), SIZE returns ones in the "extra" variables, i.e., outputs
%               NDIMS(OD)+1 through N.
% N < NDIMS(OD), MN contains the product of the sizes of dimensions N
%               through NDIMS(OD).
%
% M = SIZE(OD,DIM) returns the length of the dimension specified
% by the scalar DIM.  For example, SIZE(OD,1) returns the number
% of rows. If DIM > NDIMS(OD), M will be 1.
%
% Note by Guillaume Maze on 2009-09-02: This is simply a wrapper of the builtin function 
%					size on the OD object content matrix.
% Created: 2009-09-02.
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

function varargout = size(OD,varargin)

C    = OD.cont;
nOut = nargout;
nIn  = nargin-1;
if nIn==1 & nOut > nIn
	error('Bad number of outputs');
end
if nIn > 1
	error('Too many input arguments');
end

if nOut <= 1
	results{1} = feval('size',C,varargin{:});
else
	[results{1:nOut}] = feval('size',C,varargin{:});
end

varargout = results;




end %function