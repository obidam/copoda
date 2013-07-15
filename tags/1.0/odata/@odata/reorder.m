% reorder Rearrange an odata object
%
% OD = reorder(OD,IDIM,IND)
% 
% Rearrange odata object values according to new indexing IND.
%
%
% Created: 2009-07-30.
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

function OD = reorder(OD,IDIM,IND)


%%%%%%%%%%%% Check IND validity:
sz_od = size(OD.cont);
nd_od = ndims(OD.cont);
if IDIM > nd_od
	error(sprintf('Cannot reorder OData object along dimension %i',IDIM));
end
nd_along_idim = sz_od(IDIM);
if length(IND) > nd_along_idim
	error('New indices larger than OData object dimensions');
end
if max(IND) > nd_along_idim
	error('New indices value too large to reorder OData object');
end
if find(IND<=0)
	error('New indices must be strictly positive');
end
if IDIM<=0
	error('Cannot reorder OData object along negative dimension');
end


%%%%%%%%%%%% Reorder:
cont = do_thisone(OD.cont,IDIM,IND);
if isfield(OD,'prec')
	if size(OD.prec) == sz_od
		prec = do_thisone(OD.prec,IDIM,IND);
	end
end

%%%%%%%%%%%% Update OData object:
OD.cont = cont;
if isfield(OD,'prec')
	OD.prec = prec;
end


end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = do_thisone(C,IDIM,IND)
	sz_od = size(C);
	nd_od = ndims(C);
	old_order = 1:nd_od;
	new_order = [IDIM old_order(find(old_order~=IDIM))];
	old_sz_new_order = sz_od(new_order);
	new_sz_new_order = [length(IND) old_sz_new_order(2:end)];
	C  = permute(C,new_order);
	C  = C(IND,:);
	C = reshape(C,new_sz_new_order);
	C = permute(C,permute(new_order,old_order));
end %function














