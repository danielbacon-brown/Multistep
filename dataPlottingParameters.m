function param = dataPlottingParameters()
%MAkes a structure, param, that defines how the data should be plotted.
%This makes it easier to ensure that all the data is collected similarly


%Data is structured by [diffraction efficiency (5), phase parameter (1),
%orientation angle (5), ellipticity (5) ]
%according to Modes:
%[0,0],
%[0,-1],
%[-1,0],
%[1,0],
%[0,1]

%Format:
%name = internal name of plot (for internal use, not publishing
%XaxisIndex = which 'column' of data to use as values for the x-axis
%YaxisIndex = " for y-axis
%filter = 0 if not filtration used, 1 if filtration used
%limits(n) = [index, min, max] describes the filtration used: each value in
%   the column 'index' must be between the values of min and max
%alpha = the value used for alpha when describing the alpha shape
%alphaAspectRatio = the ratio of the y-axis to the x-axis to account for
%   when making the alpha shape (e.g. when plotting different variables)
%   if unset, defaults to 1


%Opposite diffraction orders  %No filtration 
param.plots(1).name = 'diffraction efficiency of opposite orders';
param.plots(1).XaxisIndex = 2;
param.plots(1).YaxisIndex = 5;
param.plots(1).filter = 0;
param.plots(1).alphaRadius = 0.01;
param.plots(1).alphaAspectRatio = 1; 

disp(param.plots(1))

%Adjacent diffraction orders  %No filtration
param.plots(2).name = 'diffraction efficiency of adjacent orders';
param.plots(2).XaxisIndex = 2;
param.plots(2).YaxisIndex = 3;
param.plots(2).filter = 0;
param.plots(2).alphaRadius = 0.01;
param.plots(2).alphaAspectRatio = 1; 

disp(param.plots(2))

%Adjacent diffraction orders %filtering to 0.01diffeff and 0.2diffeff
param.plots(3).name = 'diffraction efficiency of adjacent orders, with opposites held to different diff eff';
param.plots(3).XaxisIndex = 2;
param.plots(3).YaxisIndex = 3;
param.plots(3).filter = 1;
param.plots(3).limits(1).index = 5;
param.plots(3).limits(1).min = 0.009;
param.plots(3).limits(1).max = 0.011;
param.plots(3).limits(2).index = 4;
param.plots(3).limits(2).min = 0.004;
param.plots(3).limits(2).max = 0.006;
param.plots(3).alphaRadius = 0.01;
param.plots(3).alphaAspectRatio = 1; 

disp(param.plots(3))

%Phase parameter vs diffraction efficiency (set to match above limits)
param.plots(4).name = 'phase parameter vs diffraction efficiency, with same limits as above adj diff eff';
param.plots(4).XaxisIndex = 2;
param.plots(4).YaxisIndex = 6;
param.plots(4).filter = 1;
param.plots(4).limits(1).index = 5;
param.plots(4).limits(1).min = 0.009;
param.plots(4).limits(1).max = 0.011;
param.plots(4).limits(2).index = 4;
param.plots(4).limits(2).min = 0.004;
param.plots(4).limits(2).max = 0.006;
param.plots(4).alphaRadius = 0.01;
param.plots(4).alphaAspectRatio = 2*pi/0.05; 

disp(param.plots(4))


end