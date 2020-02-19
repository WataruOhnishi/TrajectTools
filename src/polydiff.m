function out = polydiff(in,n)
%polydiff - calculate differentiated coeffs of polynomial
%
% out = polydiff(in,n)
% example:
% in = [a,b,c,d] (for polyval)
%  y = a*t^3 + b*t^2 + c*t + d
% dy = 3*a*t^2 + 2*b*t + c
% out = [0,3*a,2*b,c]
%
% Author  : Wataru Ohnishi, The University of Tokyo, 2017
%%%%%

if nargin < 2, n = 1; end
out = in;
while n > 0
    out = polydiff_main(out);
    n = n -1;
end
end

function out = polydiff_main(in)
out = [0, in(1:end-1)];
out = fliplr(out);
for kk = 1:length(out)
    out(kk) = out(kk)*kk;
end

out = fliplr(out);
end
