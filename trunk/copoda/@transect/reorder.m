% reorder Rearrange profiles order of transect object
%
% T = reorder(T,IDIM,IND)
% 
% Rearrange all profiles order of transect object T
% according to new indexing IND.
%
% Created: 2009-07-29.
% Rev. by Guillaume Maze on 2010-03-05: Only reorder Real datas (not Virtual)
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


function T = reorder(T,IDIM,IND)
	
%%%%%%%%%%%% Check IND validity:
fields = datanames(T);
od = getfield(T,'data',fields{1});
sz_od = size(od.cont);
sz_in = size(IND);
if ndims(sz_in) ~= ndims(sz_od)
	error('IND must be of the dimension numbers as OData object within this transect')
end
if IDIM > ndims(od.cont)
	error('IDIM cannot exceed OData object dimensions within this transect')
end
if IDIM <= 0
	error('Cannot reorder along a negative dimension');
end
old_n = sz_od(IDIM);


%%%%%%%%%%%% Reorder geo properties:
if numel(T.geo.PRES) == sz_od(2) | numel(T.geo.PRES) == prod(sz_od)
	T.geo = do_geo(T.geo,'PRES',IDIM,IND);
end
if numel(T.geo.DEPH) == sz_od(2) | numel(T.geo.DEPH) == prod(sz_od)
	T.geo = do_geo(T.geo,'DEPH',IDIM,IND);
end

if IDIM == 1 % Reorder only the stations axis for these, because they are believed not to depend on depth/pressure (the level axis)
	T.geo = do_geo(T.geo,'STATION_DATE',IDIM,IND);
	T.geo = do_geo(T.geo,'STATION_NUMBER',IDIM,IND);
	T.geo = do_geo(T.geo,'LATITUDE',IDIM,IND);
	T.geo = do_geo(T.geo,'LONGITUDE',IDIM,IND);
	T.geo = do_geo(T.geo,'MAX_PRESSURE',IDIM,IND);
	if size(T.geo.POSITIONING_SYSTEM,1) == sz_od(1)
		T.geo = do_geo(T.geo,'POSITIONING_SYSTEM',IDIM,IND);
	end
end %if IDIM == 1


%%%%%%%%%%%% Reorder data properties:
fields = datanames(T);
data   = T.data;
for iv = 1 : length(fields)
	od = getfield(T.data,fields{iv});
	if T.data.PARAMETERS_STATUS(iv) == 'R'
		od = reorder(od,IDIM,IND);
	end
	data = setfield(data,fields{iv},od);
end
T.data = data;

%%%%%%%%%%%% Update cruise_info
if IDIM == 1 % Reorder only the stations axis:	
	CI = T.cruise_info;
	CI.N_STATION = length(IND);
	CI.DATE = [min(T.geo.STATION_DATE) max(T.geo.STATION_DATE)];
	T.cruise_info = CI;
end

%%%%%%%%%%%% Update modified date within general informations:
T.modified = now;

end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function geo = do_geo(geo,parn,IDIM,IND)
	if isfield(geo,parn);
		C = getfield(geo,parn);
		C = do_thisone(C,IDIM,IND);
		geo = setfield(geo,parn,C);
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


















