% function [P, I_new, D, e_f_new] = MinPID(I_old, e_f_old, e, T_s, para)
%
%   PID-regulator som anvender trapesmetoden, bakoverderivasjon og 
%   første ordens lavpassfilter. Inkluderer integratorbegrensing. 
%
%   Funksjonsargumenter inn:
%   - I_old:    forrige integralverdi I(k-1)
%   - e_f_old:  forrige filtrerte reguleringsavvik e_f(k-1)
%   - e:        de to siste reguleringsavvik e(k-1:k) 
%   - T_s:      tidsskritt T_s(k) 
%   - para:     parametervektor [Kp, Ki, Kd, I_max, I_min, alfa(k)]
%
%   Returargumenter:
%   - P:        proporsjonaldel P(k)
%   - I_new:    integraldel I(k)
%   - D:        derivatdel D(k)
%   - e_f_new:  filtrert reguleringsavvik e_f(k)
%
%   Syntaks for bruk av funksjonen:
%   -------------------------------
%   fc = ..;                        % ønsket knekkfrekvens
%   tau = ...;                      % ønsket tidskonstant filter
%   alfa(k) = 1-exp(-Ts(k)/tau);    % alpha-verdi lavpassfilter
%   para = [Kp, Ki, Kd, I_max, I_min, alfa(k)];
%   [P(k),I(k),D(k),e_f(k)] = MinPID(I(k-1),e_f(k-1),e(k-1:k),T_s(k),para) 
%   u(k) = u0 + P(k) + I(k) + D(k);

function [P, I_new, D, e_f_new] = MinPID(I_old, e_f_old, e, T_s, para)


% -------------------------------------------------------------
% Parametere
% -------------------------------------------------------------
Kp    = para(1);
Ki    = para(2);
Kd    = para(3);
I_max = para(4);
I_min = para(5);
alfa  = para(6);

% -------------------------------------------------------------
% Bidragene P, I og D
% -------------------------------------------------------------
P = Kp*e(2);
I_new = (I_old+T_s*(0.5)*Ki*(e(1)+e(2)));
e_f_new = (1-alfa)*e_f_old(1)+alfa*e(2);
D = Kd*(e_f(2)-e_f(1))/T_s;
    
% -------------------------------------------------------------
% Integratorbegrensing
% -------------------------------------------------------------
if I_new > I_max
    I_new = I_max;
elseif I_new < I_min
    I_new = I_min;
end


