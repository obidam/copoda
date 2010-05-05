% labels_map Add labels to geographic features on a map
%
% hl = labels_map()
% 
% Add labels to geographic features on a map
%
%
% Created: 2009-08-04.
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

function t = labels_map(varargin)

global MAP_VAR_LIST
if find(MAP_VAR_LIST.longs<0) % We are in -180W to 180E longitudes
	dlon = 0;
else % we are in E from 0 to 360 longitudes
	dlon  = 360;
end

ii = 0;
global MAP_VAR_LIST

ii=ii+1; t(ii) = m_text(dlon-49,63,'Greenland');
ii=ii+1; t(ii) = m_text(dlon-36,61,sprintf('Irminger\nSea'),'horizontalAlignment','center');
ii=ii+1; t(ii) = m_text(dlon-31,59,'Reykjanes Ridge','rotation',45);
ii=ii+1; t(ii) = m_text(dlon-34.5,57,'BFZ','rotation',0);
ii=ii+1; t(ii) = m_text(dlon-32,53,'CGFZ','rotation',0);
ii=ii+1; t(ii) = m_text(dlon-15,47,sprintf('West European\nBasin'),'horizontalAlignment','center');
ii=ii+1; t(ii) = m_text(dlon-5,40,sprintf('Iberian\nPeninsula'),'horizontalAlignment','center');
ii=ii+1; t(ii) = m_text(dlon-29,43,'Mid Atlantic Ridge','rotation',75);
ii=ii+1; t(ii) = m_text(dlon-30,39,sprintf('Azores\nPlateau'),'horizontalAlignment','center');
ii=ii+1; t(ii) = m_text(dlon-28,54.5,'Maury Channel','rotation',40);
ii=ii+1; t(ii) = m_text(dlon-20,60,sprintf('Iceland\nBasin'),'horizontalAlignment','center');
ii=ii+1; t(ii) = m_text(dlon-15,57,sprintf('Rockall\nPlateau'),'horizontalAlignment','center');

set(t,'fontweight','bold','fontsize',8)

ii=ii+1; t(ii) = legend(t(1),sprintf('%30s\n%30s',...
				algn('BFZ: Bight Fracture Zone','','left'),...
				algn('CGFZ: Charlie-Gibbs Fracture Zone','','left')),...
				'location','southwest');
ch=get(t(end),'children');
%set(ch(5),'position',[.125 0.5 0]);

end %function




function str = algn(str,sep,aln)

str = [sep strjust(sprintf('%35s',str),aln) sep];

end %function

