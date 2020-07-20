function pBasis = polySolve(t0,t1,initval,finval,n,showFig)
%polySolve - Design nth order polynomial trajectory
%
% pBasis = polyTraj(t0,t1,initval,finval,n,showFig)
% pBasis.a_vpas : coeffs in vpa
% pBasis.a_syms : coeffs in symbolic
% plot function : y = outPolyBasis(pBasis,n,t)
%
% t0      : Trajectory start time
% t1      : Trajectory end time
% initval : Initial boudary condition
% finval  : Final boudary condition
% n       : Trajectory order (now has to be odd number)
% showFig : Flag to show the performance (0,1)
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

dT = t1 - t0; 
if dT < 0, error('error at BCt'); end

%%%%%
syms t real
a = sym('a',[1,n+1],'real'); % a1 is 0th order

T = sym('T',[n+1,1],'real');
for kk = 1:1:n+1
    T(kk) = t^(kk-1);
end

F = sym('f',[(n+1)/2,1]);
F(1) = a*T; % position trajectory
for kk = 1:1:(n+1)/2-1
    F(kk+1) = diff(F(kk),t);
end

Eq_init = sym('Eq_init',[(n+1)/2,1]);
Eq_fin = sym('Eq_fin',[(n+1)/2,1]);

for kk = 1:1:(n+1)/2
    Eq_init(kk) = subs(F(kk),t, 0);
    Eq_fin(kk) = subs(F(kk),t, dT);
end

S = solve([Eq_init; Eq_fin;] == [initval; finval;]);
name = fieldnames(S);
a_vpa = zeros(n+1,1);
if isstruct(S)
    a_sym = sym('a_sym_', [n+1,1],'real');
    for kk = 1:1:length(name)
        a_vpa(kk) = getfield(S,char(name(kk)));
        a_sym(kk) = getfield(S,char(name(kk)));
    end
    if length(name) < length(a)
       for kk = length(name)+1:length(a)
           a_sym(kk) = 0;
       end
    end
else
    a_sym = zeros(n+1,1);
end

F_vpa = sym('f',[(n+1)/2,1]);
F_sym = sym('f',[(n+1)/2,1]);
for kk = 1:1:(n+1)/2
    F_vpa(kk) = subs(F(kk), a, a_vpa.');
    F_sym(kk) = subs(F(kk), a, a_sym.');
end

a_vpas = zeros((n+1)/2,n+1);
a_syms = sym('a_syms_', [(n+1)/2,n+1],'real');
for kk = 1:1:(n+1)/2
    [~,n1] = size(sym2poly(F_vpa(kk)));
    [~,n2] = size(a_vpas(kk,:));
    a_vpas(kk,:) = [zeros(1,n2-n1) sym2poly(F_vpa(kk))];
    a_syms(kk,:) = [zeros(1,n2-n1) sym2poly(F_sym(kk))];
end

pBasis.a_vpas = a_vpas;
pBasis.a_syms = a_syms;
pBasis.BCt = [t0,t1];
pBasis.BC0 = initval;
pBasis.BC1 = finval;
pBasis = orderfields(pBasis);


if showFig == 1
    t_val = 0:dT/100:dT;
    for kk = 1:1:(n+1)/2
        sTitle = sprintf('%d derivative',kk-1);
        figure;
        plot(t_val+t0,polyval(a_vpas(kk,:),t_val));
        title(sTitle);
        xlabel('Time [s]');
        grid on; box on;
    end
end

