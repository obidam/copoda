% pcolor Pseudocolor (checkerboard) plot of OData object
%
%   PCOLOR(C) is a pseudocolor or "checkerboard" plot of matrix C.
%   The values of the elements of C specify the color in each
%   cell of the plot. In the default shading mode, 'faceted',
%   each cell has a constant color and the last row and column of
%   C are not used. With shading('interp'), each cell has color
%   resulting from bilinear interpolation of the color at its 
%   four vertices and all elements of C are used. 
%   The smallest and largest elements of C are assigned the first and
%   last colors given in the color table; colors for the remainder of the 
%   elements in C are determined by table-lookup within the remainder of 
%   the color table.
%
%   PCOLOR(X,Y,C), where X and Y are vectors or matrices, makes a
%   pseudocolor plot on the grid defined by X and Y.  X and Y could 
%   define the grid for a "disk", for example.
%
%   PCOLOR(AX,..) plots into AX instead of GCA.
%
%   H = PCOLOR(...) returns a handle to a SURFACE object.
%
%   PCOLOR is really a SURF with its view set to directly above.
%
%   See also CAXIS, SURF, MESH, IMAGE, SHADING.
%
%
% Created: 2009-07-31.
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

function h = pcolor(varargin)

%-------------------------------
%   Additional details:
%
%
%   PCOLOR sets the View property of the SURFACE object to directly 
%   overhead.
%
%   If the NextPlot axis property is REPLACE (HOLD is off), PCOLOR resets 
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and 
%   text objects).  View is set to [0 90].

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 5.9.4.3 $  $Date: 2006/06/27 23:05:13 $

%   J.N. Little 1-5-92

switch nargin
	case 1 % Direct the OData object
		C = getfield(varargin{1},'cont');
		varargin{1} = C;
	case 3		
		C = getfield(varargin{3},'cont');
		varargin{3} = C;
end
		
% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs,'struct'))

% do error checking before calling newplot. This argument checking should
% match the surface(x,y,z) or surface(z) argument checking.
if nargs == 2
  error(id('InvalidNumberOfInputs'),...
        'Must have one or three input data arguments.')
end
if isvector(args{end})
  error(id('NonMatrixColorInput'),'Color data input must be a matrix.');
end
if nargs == 3 && LdimMismatch(args{1:3})
  error(id('InputSizeMismatch'),'Matrix dimensions must agree.');
end
for k = 1:nargs
  if ~isreal(args{k})
    error(id('NonRealInputs'),'Data inputs must be real.');
  end
end

cax = newplot(cax);
hold_state = ishold(cax);

if nargs == 1
    x = args{1};
    hh = surface(zeros(size(x)),x,'parent',cax);
    [m,n] = size(x);
    lims = [ 1 n 1 m];
elseif nargs == 3
    [x,y,c] = deal(args{1:3});
    hh = surface(x,y,zeros(size(c)),c,'parent',cax);
    lims = [min(min(x)) max(max(x)) min(min(y)) max(max(y))];
end
if ~hold_state
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    axis(cax,lims);
end
if nargout == 1
    h = hh;
end

function ok = LdimMismatch(x,y,z)
[xm,xn] = size(x);
[ym,yn] = size(y);
[zm,zn] = size(z);
ok = (xm == 1 && xn ~= zn) || ...
     (xn == 1 && xm ~= zn) || ...
     (xm ~= 1 && xn ~= 1 && (xm ~= zm || xn ~= zn)) || ...
     (ym == 1 && yn ~= zm) || ...
     (yn == 1 && ym ~= zm) || ...
     (ym ~= 1 && yn ~= 1 && (ym ~= zm || yn ~= zn));

function str = id(str)
str = ['MATLAB:pcolor:' str];

