clear; close all;

trajType = 'vel';
tacc = 1; % acceleration time
tvel = 1; % constant velocity time
tdec = tacc; % deceleration time
tdwell = 0.5; % dwelling time
% time boundary conditions
BCt = [tdwell,... % dwell
    tdwell+tacc,... % accelerate
    tdwell+tacc+tvel,... % const vel
    tdwell+tacc+tvel+tdec,... % decelerate
    tdwell+tacc+tvel+tdec+tdwell,... % dwell
    tdwell+tacc+tvel+tdec+tdwell+tacc,... % accelerate
    tdwell+tacc+tvel+tdec+tdwell+tacc+tvel,... % const vel
    tdwell+tacc+tvel+tdec+tdwell+tacc+tvel+tdec,... % decelerate
    ];

% motion distance
vmax = 0.5; % m/s
% velocity boundary conditions
BCv = [0, vmax, vmax, 0, 0, -vmax, -vmax, 0];

% polynomial order
np = 5;

% Polynomial Trajectory generation
BC = cell(2,1);
BC{1} = 0; % initial position
BC{2} = BCv; % velocity boundary condition
pBasis = backandforth(trajType,BCt,BC,np);

%% Plot
Ts = 1e-3;
t = 0:Ts:8;
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
if exist('pubfig','file')
    pfig = pubfig(hfig);
    expfig('ex3','-png');
end
