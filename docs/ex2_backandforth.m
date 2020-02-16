clear; close all;

trajType = 'pos';
tmove = 1; % moving time
tdwell = 0.5; % dwelling time
% time boundary conditions
BCt = [tdwell, tdwell+tmove, tdwell+tmove+tdwell, tdwell+tmove+tdwell+tmove,...
    tdwell+tmove+tdwell+tmove+tdwell,tdwell+tmove+tdwell+tmove+tdwell+tmove,...
    tdwell+tmove+tdwell+tmove+tdwell+tmove+tdwell,tdwell+tmove+tdwell+tmove+tdwell+tmove+tdwell+tmove]; 

% motion distance
pmove = 0.3;
% position boundary conditions
BCp = [0, pmove, pmove, 0, 0, pmove, pmove, 0];

% polynomial order
np = 5;

% Polynomial Trajectory generation 
pBasis = backandforth(trajType,BCt,BCp,np);

%% Plot
Ts = 1e-3;
t = 0:Ts:7;
y1 = outPolyBasis(pBasis,1,t);
y2 = outPolyBasis(pBasis,2,t);
y3 = outPolyBasis(pBasis,3,t);
y4 = outPolyBasis(pBasis,4,t);

hfig = figure; 
subplot(2,2,1);
plot(t,y1);
xlabel('time [s]');
title('position');
subplot(2,2,2);
plot(t,y2);
xlabel('time [s]');
title('velocity');
subplot(2,2,3);
plot(t,y3);
xlabel('time [s]');
title('acceleration');
subplot(2,2,4);
plot(t,y4);
xlabel('time [s]');
title('jerk');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
pfig = pubfig(hfig);
expfig('ex2','-png');

