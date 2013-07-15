% vertcat Create a vertical cell with two transect objects
%
% D = vertcat(T1,T2)
% 
% Create a vertical cell with transect objects T1 and T2. 
% Simply return the result of:
%	D = {T1 ; T2};
%
%
% Created: 2009-07-28.
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

function D = vertcat(T1,T2)


%disp('Call vertcat from transect, create cell with transects');

D = {T1 ; T2};


end %function