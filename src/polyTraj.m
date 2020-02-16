function a_poly = polyTraj(t0,t1,initval,finval,n,showFig)
%polyTraj - Design nth order polynomial trajectory
%
% a_poly = polyTraj(t0,t1,initval,finval,n,showFig)
% t0      : Trajectory start time
% t1      : Trajectory end time
% initval : Initial boudary condition 
% finval  : Final boudary condition
% n       : Trajectory order (now has to be odd number)
% showFig : Flag to show the results (0,1)
% Author  : Wataru Ohnishi, University of Tokyo, 2016
%%%%%

if rem(n,2) == 0
    error('n has to be odd number');
end

if length(initval)+length(finval) ~= n+1
    error('length(initval)+length(finval) != n+1');
end

if nargin < 6
    showFig = 0;
end

%%%%
syms t real
a = sym('a',[1,n+1],'real'); % a1 is 0th order

T = sym('T',[n+1,1],'real');
for kk = 1:1:n+1
    T(kk) = t^(kk-1);
end

F = sym('f',[(n+1)/2,1]);
F(1) = a*T;
for kk = 1:1:(n+1)/2-1
    F(kk+1) = diff(F(kk),t);
end

Eq_init = sym('Eq_init',[(n+1)/2,1]);
Eq_fin = sym('Eq_fin',[(n+1)/2,1]);

for kk = 1:1:(n+1)/2
    Eq_init(kk) = subs(F(kk),t, t0);
    Eq_fin(kk) = subs(F(kk),t, t1);
end

S = solve([Eq_init; Eq_fin;] == [initval; finval;]);
name = fieldnames(S);
a_val = zeros(length(name),1);
for kk = 1:1:length(name)
    a_val(kk) = getfield(S,char(name(kk)));
end


F_subs = sym('f',[(n+1)/2,1]);
for kk = 1:1:(n+1)/2
    F_subs(kk) = subs(F(kk), a, a_val.');
end

a_poly = zeros((n+1)/2,n+1);
for kk = 1:1:(n+1)/2
    a_poly(kk,:) = [zeros(1,kk-1) sym2poly(F_subs(kk))];
end

if showFig
    t_val = t0:(t1-t0)/100:t1;
    for kk = 1:1:(n+1)/2
        sTitle = sprintf('%d derivative',kk-1);
        figure;
        plot(t_val,polyval(a_poly(kk,:),t_val));
        title(sTitle);
        xlabel('Time [s]');
        grid on; box on;
    end    
end


