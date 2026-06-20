function test_TrajectTools
%test_TrajectTools - regression tests for TrajectTools
%
% Run from any folder:
%   test_TrajectTools
% Returns silently on success, errors on the first failed assertion.
% No test framework required (plain assert-based harness).
%
% Covered:
%   - polySolve  : boundary conditions for several orders, incl. n>=9 where
%                  solve() field names sort alphabetically (a1,a10,a2,...)
%   - polySolve  : a_syms and a_vpas agree numerically
%   - polydiff   : analytic derivative of polynomial coefficients
%   - diff_pBasis: differentiating the position basis yields the velocity basis
%   - int_pBasis : integrate-then-differentiate round trip
%   - backandforth/outPolyBasis: end-to-end run for every trajType
%%%%%

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here,'..','src'));

npass = 0;
npass = npass + t_polySolve_bcs();
npass = npass + t_polySolve_sym_vpa();
npass = npass + t_polydiff();
npass = npass + t_diff_pBasis();
npass = npass + t_int_pBasis_roundtrip();
npass = npass + t_backandforth();

fprintf('test_TrajectTools: ALL %d CHECKS PASSED\n', npass);
end

%% ---- individual tests -------------------------------------------------

function n = t_polySolve_bcs()
% polynomial must hit the prescribed boundary conditions at both ends,
% across orders. n=9 and n=13 exercise the >=10-coefficient ordering hazard.
n = 0;
cases = { ...
    3,  [0;0],         [1e-3;0]; ...
    5,  [0;0;0],       [1;0;0]; ...
    7,  [0;0.2;0;0],   [1;0;-3;0]; ...
    9,  [0;0;0;0;0],   [2e-3;0;0;0;0]; ...
    9,  [0;0.1;0;0;0], [1;0;-2;0;0]; ...    % nonzero higher-order BCs
    13, zeros(7,1),    [1;zeros(6,1)] };
t0 = 0; t1 = 0.2;
for c = 1:size(cases,1)
    ord = cases{c,1}; iv = cases{c,2}; fv = cases{c,3};
    pB = polySolve(t0,t1,iv,fv,ord);
    dT = t1 - t0; nd = (ord+1)/2;
    tol = 1e-6 * max(1, max(abs([iv;fv])));
    for r = 1:nd
        assert(abs(polyval(pB.a_vpas(r,:),0)  - iv(r)) < tol, ...
            'polySolve n=%d: initial BC of derivative %d not met', ord, r-1);
        assert(abs(polyval(pB.a_vpas(r,:),dT) - fv(r)) < tol, ...
            'polySolve n=%d: final BC of derivative %d not met', ord, r-1);
    end
    n = n + 1;
end
end

function n = t_polySolve_sym_vpa()
% symbolic and numeric coefficient tables must agree
pB = polySolve(0,0.15,[0;0.1;0;0],[1;0;-2;0],7);
err = max(abs(double(pB.a_syms(:)) - pB.a_vpas(:)));
rtol = 1e-9 * max(1, max(abs(pB.a_vpas(:)))); % coeffs can be large -> relative tol
assert(err < rtol, 'polySolve: a_syms and a_vpas disagree (%.3e)', err);
n = 1;
end

function n = t_polydiff()
% d/dt (a t^3 + b t^2 + c t + d) = 3a t^2 + 2b t + c
in  = [2 -3 5 7];
exp = [0 6 -6 5];
assert(isequal(polydiff(in), exp), 'polydiff: wrong first derivative');
assert(isequal(polydiff(in,2), polydiff(polydiff(in))), ...
    'polydiff: n-fold differentiation inconsistent');
n = 1;
end

function n = t_diff_pBasis()
% differentiating the position basis must reproduce the velocity basis
pB = polySolve(0,0.1,[0;0;0;0],[1e-3;0;0;0],7);
d  = diff_pBasis(pB);
ts = linspace(0,0.1,50);
v_from_diff = polyval(d{1}.a_vpas(1,:), ts);      % 1st row of diff = velocity
v_direct    = polyval(pB.a_vpas(2,:),  ts);       % 2nd row of pos  = velocity
assert(max(abs(v_from_diff - v_direct)) < 1e-9, ...
    'diff_pBasis: differentiated basis disagrees with analytic velocity');
% symbolic table must stay consistent with numeric table after the fix
errsym = max(abs(double(d{1}.a_syms(1,:)) - d{1}.a_vpas(1,:)));
rtol   = 1e-9 * max(1, max(abs(d{1}.a_vpas(1,:))));
assert(errsym < rtol, 'diff_pBasis: a_syms polluted by a_vpas (%.3e)', errsym);
n = 1;
end

function n = t_int_pBasis_roundtrip()
% integrate the velocity basis, then differentiate: recover velocity
pB  = polySolve(0,0.1,[0;0;0;0],[1e-3;0;0;0],7);
vel = diff_pBasis(pB);                 % velocity basis (cell)
pos = int_pBasis(vel,1,pB.BC0(1));     % integrate back to position
ts  = linspace(0,0.1,50);
pos_int = polyval(pos{1}.a_vpas(1,:), ts);
pos_ref = polyval(pB.a_vpas(1,:),     ts);
assert(max(abs(pos_int - pos_ref)) < 1e-9, ...
    'int_pBasis: integrate(diff(pos)) does not recover position');
n = 1;
end

function n = t_backandforth()
% end-to-end smoke test for every trajType, plus position continuity
BCt = [0 0.1 0.2 0.3];
order = 7;
specs = { ...
    'pos', [0; 1; -1; 0]; ...
    'vel', {0, [0; 1; -1; 0]}; ...
    'acc', {0, 0, [0; 1; -1; 0]}; ...
    'jrk', {0, 0, 0, [0; 1; -1; 0]} };
for s = 1:size(specs,1)
    pB = backandforth(specs{s,1}, BCt, specs{s,2}, order, false);
    t  = linspace(BCt(1), BCt(end), 200);
    y  = outPolyBasis(pB, 1, t);
    assert(all(isfinite(y)), 'backandforth/%s: non-finite output', specs{s,1});
    % position continuity across internal knots
    for k = 2:numel(BCt)-1
        tk  = BCt(k);
        yl  = outPolyBasis(pB, 1, tk - 1e-6);
        yr  = outPolyBasis(pB, 1, tk + 1e-6);
        assert(abs(yl - yr) < 1e-3, ...
            'backandforth/%s: position discontinuity at knot %d', specs{s,1}, k);
    end
end
n = 1;
end
