% disp Display informations about a database object
%
% [] = disp(D,[FORMAT])
% 
% D is the database informations are taken from.
% FORMAT determined how informations are being display:
%	Default: Short + Transects infos
%	1: Short
%	2: Medium = Short + Transects variables
%	3: A LaTeX table to be copied in a .tex file
%
%
% Created: 2009-07-28.
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


function varargout = disp(D,varargin)


forma = 100; % Default view
if nargin == 2
	forma = varargin{1};
	if isempty(find([1 2 3 4]-forma==0))
		error('Bad format')
	end
end

switch forma
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SHORT
	case 1		
		disp('===== Database object content description:');
		disp_prop('Name',D.name);
		disp_prop('Source',D.source);
		disp_prop('Creator',D.creator);		
		disp_prop('Created (last modified)',sprintf('%s (%s)',datestr(D.created),datestr(D.modified)));
		disp_prop('Description',D.description{1});
		for il = 2 : length(D.description)
			disp_prop('',D.description{il});
		end
		[nt ns nb] = size(D);
		if nt == 0
			disp_prop('Nb of transect(s)',sprintf('0 (but found %i empty !)',length(D,1)));
		else
			if length(D,1) ~= nt
				disp_prop('Nb of transect(s)',sprintf('%i (and %i empty)',nt,length(D,1)-nt));
			else
				disp_prop('Nb of transect(s)',sprintf('%i',nt));			
			end
			disp_prop('Nb of  station(s)',num2str(ns));	
			disp_prop('Nb of   sample(s)',['~ ' num2str(nb)]);	
		end		
		% for it=1:nt,
		% 	li(it)=isempty(D.transect{it});
		% end
		% if exist('li','var'), if length(find(li==1)) ~= 0
		% 	disp_prop('Nb of empty transect(s)',num2str(length(find(li==1))));
		% end,end
		tt = D.transect;
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LONG (WITH TRANSECT FIELDS)
	case 2
		disp('===== Database object content description:');
		disp_prop('Name',D.name);
		disp_prop('Source',D.source);
		disp_prop('Creator',D.creator);
		disp_prop('Created (last modified)',sprintf('%s (%s)',datestr(D.created),datestr(D.modified)));
		disp_prop('Description',D.description{1});
		for il = 2 : length(D.description)
			disp_prop('',D.description{il});
		end
		[nt ns nb] = size(D);
		if nt == 0
			disp_prop('Nb of transect(s)',sprintf('%i (but empty !)',length(D,1)));
		else
			if length(D,1) ~= nt
				disp_prop('Nb of transect(s)',sprintf('%i (and %i empty)',nt,length(D,1)-nt));
			else
				disp_prop('Nb of transect(s)',sprintf('%i',nt));			
			end
			disp_prop('Nb of  station(s)',num2str(ns));	
			disp_prop('Nb of   sample(s)',['~ ' num2str(nb)]);
			tt = D.transect;
			for it = 1 :nt
				t = tt{it};
				if ~isempty(t)
					str = disp_field(t);
					disp_prop(sprintf('Transect #%i Name',it),t.cruise_info.NAME);
					disp_prop(sprintf('File'),strrep(tt{it}.file,getenv('HOME'),'~'))
					disp_prop('Fields',str);
				else
					disp_prop(sprintf('Transect #%i',it),'empty')
				end
			end%for it
		end%if
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LATEX TABLE
	case 3
		nv = 6;	
		sep = '&';
		alignment = 'center';
		blk = ' ';
		nt = size(D);
		tt = D.transect;	
		toto='c|';for iq=1:nv-1,toto=strcat(toto,'c|');end	
		id = length(D.description); desc=D.description{1};
		if id>=2,for il = 2 : id, desc=[desc ' ' D.description{il}]; end,end
				
		disp(sprintf('\\begin{center}',toto));
		disp(sprintf('%5s \\tabletail{\\hline\\multicolumn{%i}{|r|}{\\small\\sl ~\\ldots}\\\\\\hline}',blk,nv));
		disp(sprintf('%5s \\tablelasttail{\\hline}',blk));
		disp(sprintf('%5s \\tablehead{\\hline\\multicolumn{%i}{|l|}{\\small\\sl ~\\ldots}\\\\\\hline}',blk,nv));
		disp(sprintf('%5s \\tablefirsthead{\\hline',blk))
		disp(sprintf('%s%s%s%s%s%s%s%s%s%s%s',...
			algn05('\#','',alignment),sep,...
			algn20('File','',alignment),sep,...
			algn20('Name','',alignment),sep,...
			algn20('Ship','',alignment),sep,...
			algn20('PI','',alignment),sep,...
			algn20('Period','',alignment),'\\ \hline \hline}'));
		disp(sprintf('%5s \\bottomcaption{\\label{tbl:X} List of transects within the database %s: %s}',blk,D.name,desc))
		disp(sprintf('%5s  %% Matlab database object informations:',blk))
		disp(sprintf('%10s %% Name:    %s',blk,D.name));
		disp(sprintf('%10s %% Source:  %s',blk,D.source));			
		disp(sprintf('%10s %% Creator: %s',blk,D.creator));
		disp(sprintf('%10s %% Created (last modified): %s (%s)',blk,datestr(D.created),datestr(D.modified)));
		disp(sprintf('%5s \\begin{supertabular}{|%s}',blk,toto));
		
		if nt ~= 0
			for it = 1 : nt
				T=tt{it};
				if ~isempty(T)				
					file = clean_file(T);
					str = sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
								algn05(sprintf('%i',it),'',alignment),sep,...
								algn20(sprintf('\\mcode{%s}',file),'',alignment),sep,...
								algn20(sprintf('\\mcode{%s}',T.cruise_info.NAME),'',alignment),sep,...
								algn20(T.cruise_info.SHIP_NAME,'',alignment),sep,...
								algn20(T.cruise_info.PI_NAME,'',alignment),sep,...
								algn20(datestr(median(T.geo.STATION_DATE),'mmm-yyyy'),'',alignment),sep);				
	%				str = sprintf('%s%s',algn10(num2str(it),alignment),stamp(t,2,sep));
					str(max(strfind(str,sep))) = '@';
					str = strrep(str,'@','\\ \hline');
					disp(str);
				else
					disp_prop(sprintf('Transect #%i',it),'empty')
				end
			end	%for it
		else
			disp_prop(sprintf('%% All Transect empty !'),'')
		end%if		
		disp(sprintf('%5s \\end{supertabular}',blk))
		disp(sprintf('%5s %% This LaTeX table was automaticaly generated in Matlab by @database/disp',blk));
		disp(sprintf('%5s %% Help: code@guillaumemaze.org',blk));
		disp(sprintf('\\end{center}'))
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SHORT WITH TABLE
	otherwise
%		disp('===== Database object content description:');
		disp(fitinsection(' DATABASE OBJECT CONTENT DESCRIPTION '))
		
		disp_prop('Name',D.name);
		disp_prop('Source',D.source);
		disp_prop('Creator',D.creator);
		disp_prop('Created (last modified)',sprintf('%s (%s)',datestr(D.created),datestr(D.modified)));
		disp_prop('Description',D.description{1});
		for il = 2 : length(D.description)
			disp_prop('',D.description{il});
		end
		[nt ns nb] = size(D);
		if nt == 0
			disp_prop('Nb of transect(s)',sprintf('%i (but empty !)',length(D,1)));
		else
			if length(D,1) ~= nt
				disp_prop('Nb of transect(s)',sprintf('%i (and %i empty)',nt,length(D,1)-nt));
			else
				disp_prop('Nb of transect(s)',sprintf('%i',nt));			
			end
			disp_prop('Nb of  station(s)',num2str(ns));	
			disp_prop('Nb of   sample(s)',['~ ' num2str(nb)]);
		end
		
		if nt ~= 0
			tt = D.transect;		
			sep = '|';
			alignment = 'center';
			str='-';
			N = get(0,'CommandWindowSize');
			
			if N(1) < 116
				blk = '';
				for ii=1:42
					blk = sprintf('%s%s',blk,str);
				end
				disp(fitinsection(blk,' ',' '))
				tblab = sprintf('%s%s%s%s%s%s%s',sep,...
					algn10('#','',alignment),sep,...
					algn20('Name','',alignment),sep,...
					algn10('Period','',alignment),sep);
				disp(fitinsection(tblab,'',' '));
				disp(fitinsection(blk,' ',' '))				
			else
				disp(fitinsection('-',str,str))			
				disp(sprintf('%s%s%s%s%s%s%s%s%s%s%s',...
					algn10('#','',alignment),sep,...
					algn20('File','',alignment),sep,...
					algn20('Name','',alignment),sep,...
					algn20('Ship','',alignment),sep,...
					algn20('PI','',alignment),sep,...
					algn20('Period','',alignment),sep));
				disp(fitinsection('-',str,str))								
			end
%			disp(fitinsection(str,str,str))
			for it = 1 :nt
				t=tt{it};
				if N(1) < 116
					if ~isempty(t)
						tblab = sprintf('%s%s%s%s%s%s%s',sep,...
							algn10(num2str(it),'',alignment),sep,...
							algn20(t.cruise_info.NAME,'',alignment),sep,...
							algn10(datestr(mean(t.cruise_info.DATE),'mmm yyyy'),'',alignment),sep);
						disp(fitinsection(tblab,'',' '));
							
%						disp(sprintf('%s%s',algn10(num2str(it),'',alignment),stamp(t,2)))
					else
						disp_prop(sprintf('Transect #%i',it),'empty')
					end
				else
					if ~isempty(t)
						disp(sprintf('%s%s',algn10(num2str(it),'',alignment),stamp(t,2)))
					else
						disp_prop(sprintf('Transect #%i',it),'empty')
					end
				end
			end		
%			disp(sprintf('%116s',str))		
			if N(1) < 116	
				disp(fitinsection(blk,' ',' '))								
			else
				disp(fitinsection(str,str,str))
			end
		else
%			disp_prop('','No transect with datas');
		end
end %switch


end %function

%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %25s: %s',blk,name,value));	
end

%%%%%%%%%%%%%%%%%%%
function str = disp_field(T)
	fi = datanames(T,1); 
	str = sprintf('%s,',fi{1});
	for ii = 2 : size(fi,1)-1
%		if (length(str)+length(fi{ii}))>90, str = sprintf('%s\n',str);end
		str = sprintf('%s %s,',str,fi{ii});
	end
	str = sprintf('%s and %s.',str,fi{end});
end


%%%%%%%%%%%%%%%
function file = clean_file(T)
	
	% Remove extension from file name
	file = T.file;
	is = strfind(file,'.');
	if ~isempty(is)
		is = max(is);
		file = file(1:is-1);
	end

	% Keep last folder only:
	if ispc, sla = '\'; 
	else, sla = '/'; end
	is = strfind(file,sla);
	if ~isempty(is)
		is = max(is)+1;
		file = file(is:end);
	end

	% For hydroLPO files, also remove the extension:
	file = strrep(file,'_dep','');
	
end%function


%%%%%%%%%%%%%%%%%%%% 
function str = fitinsection(label,varargin)

	if nargin > 2
		car = varargin{2};
	else
		car = '=';
	end

	n = get(0,'CommandWindowSize');
	nc = n(1); nl = n(2); clear n
	if nc < length(label)+2
		% The Command window is not lerge enough for this label !
		str = label;
	else
		
		n = length(label)+2;
		str = '';
		for ii = 1 : fix( (nc - n)/2 )
			str = sprintf('%s%s',str,car);
		end
		str = sprintf('%s%s',str,label);		
		for ii = 1 : fix( (nc - n)/2 ) + rem(nc - n,2)
			str = sprintf('%s%s',str,car);
		end
		
	end
	
	if nargin == 2
		pref = varargin{1};
		str(1:length(pref)) = pref;
	end
	
end %function
