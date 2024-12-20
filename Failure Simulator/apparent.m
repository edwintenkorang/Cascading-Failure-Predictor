function S = apparent(P, Q)
% Calculate apparent power S from real power P and reactive power Q
S = sqrt(P.^2 + Q.^2);
end