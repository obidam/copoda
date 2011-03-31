% ibm Inverse Box Model
%
% [] = ibm()
% 
% Inverse Box Model (IBM)
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-06-14.
% http://code.google.com/p/copoda
% Copyright 2010, COPODA
 
% Geostrophic currents and transports between station 
% pairs are calculated relative to a deep reference level, or 
% the depth of the shallowest station along sloping bot- 
% tom. Large mass imbalances are found between the sec- 
% tions based on this initial guess, and an inverse model is 
% used to adjust the flow and estimate uncertainties on 
% diagnostics.

% The basic inverse model technique follows that of Wunsch 
% (1996) using a Gauss–Markov method to estimate ref- 
% erence-level velocities and Ekman transport along the 
% hydrographic sections enclosing the domain so that the 
% circulation satisfies basic conservation requirement 
% (e.g., Ganachaud 2003). Mass, heat, 
% and salt conservation constraints 
% are applied over isopycnal layers defined by po- 
% tential density surfaces

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = devel_ibm(varargin)


end %functiondevel_ibm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
