clear; close all;

% constraints
pmax = 1; % final position
vmax = 0.5; % max velocity
amax = 0.75; % max acceleration
% jmax = 4; % max jerk

tfin = 3.5; % final time
d = 5; % spline degree, minimum 3
n = 8; % number of knots, typical 8

% B-spline basis of degree d with n knots
basis = BSplineBasis([0, tfin], d, n);

% scalar (1x1) spline variable
pos = BSpline.sdpvar(basis, [1, 1]); % position trajectory
vel = pos.derivative(1); % velocity trajectory
acc = pos.derivative(2); % acceleration trajectory
jrk = pos.derivative(3); % jerk trajectory

% equality constraints
con = [pos.f(0) == 0, pos.f(tfin) == pmax, ...
    vel.f(0) == 0, vel.f(tfin) == 0, ...
    acc.f(0) == 0, acc.f(tfin) == 0];
%     jrk.f(0) == 0, jrk.f(tfin) == 0];

% inequality constraints
con = [con, -vmax <= vel, vel <= vmax, ...
    -amax <= acc, acc <= amax];
if exist('jmax','var'), con = [con, -jmax <= jrk, jrk <= jmax]; end

% set objective function: minimal deflection
obj = jrk^2;

% Solve convex semi-Definite program (SDP)
options = sdpsettings('verbose',1);
sol = optimize(con, obj.integral, options);
if sol.problem == 1, error('infeasible! increase d or n, otherwise relax tfin!'); end

%% Plot
Ts = 1e-3;
t = 0:Ts:tfin;

y1 = value(pos); y1 = y1.f(t);
y2 = value(vel); y2 = y2.f(t);
y3 = value(acc); y3 = y3.f(t);
y4 = value(jrk); y4 = y4.f(t);

hfig = figure;
subplot(2,2,1);
plot(t,y1,'b-'); hold on
xlabel('time [s]');
title('position');
subplot(2,2,2);
plot(t,y2,'b-'); hold on
plot([t(1),t(end)],[vmax,vmax],'r--');
plot([t(1),t(end)],[-vmax,-vmax],'r--');
ylim([0,0.6]);
xlabel('time [s]');
title('velocity');
subplot(2,2,3);
plot(t,y3,'b-'); hold on
plot([t(1),t(end)],[amax,amax],'r--');
plot([t(1),t(end)],[-amax,-amax],'r--');
xlabel('time [s]');
title('acceleration');
subplot(2,2,4);
plot(t,y4,'b-'); hold on
if exist('jmax','var')
    plot([t(1),t(end)],[jmax,jmax],'r--');
    plot([t(1),t(end)],[-jmax,-jmax],'r--');
end
xlabel('time [s]');
title('jerk');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
if exist('pubfig','file')
    pfig = pubfig(hfig);
    expfig('ex7','-png');
end
