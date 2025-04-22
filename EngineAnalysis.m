
function [IMEP, PMEP, V, AHRR, AHR, T] = EngineAnalysis(theta, ave_pressure, S, B, L, CR, T_intake, gamma)
%Inputs for function
% CR = 7;                  %[-] Compression ratio
% B = 82.6e-3;             %[m] Bore
% S = 114.3e-3;            %[m] Stroke length
% L = 254e-3;              %[m] Connecting rod length
% gamma = 1.3;             %[-] Heat capacity ratio
n_cyl = 1;               %[-] Number of cylinders
T1 = 300%T_intake;                %[K] Intake temperature

theta_rads = deg2rad(theta);

%IMEP calculations
V_d = pi/4*B^2*S*n_cyl;           %[m^3] Displacement volume (diff between TDC and BDC)

% Volume as a function of CAD
V_c = V_d/(CR-1);                 %[m^3] Compression volume
R = S/2;                          %[m] Crank shaft arm length

V = V_c+pi*B^2/4*(R*(1-cos(theta_rads))+R^2/(2*L)*sin(theta_rads).^2);   %[m^3] Volume as a function of CAD


IMEP = trapz(V(360:1080)',ave_pressure(360:1080))/V_d;    %[Pa] IMEP - integrated thermodynamic work acting on the piston during compression and expansion

PMEP = trapz(V(1:360)',ave_pressure(1:360))/V_d+trapz(V(1080:end)',ave_pressure(1080:end))/V_d;     %[Pa] PMEP - Integrated thermodynamic work acting on the piston during Intake and exhaust


dp = gradient(ave_pressure)./gradient(theta');
dV = (gradient(V)./gradient(theta))';

AHRR = gamma/(gamma-1)*ave_pressure.*dV+1/(gamma-1)*V'.*dp;     %[J/d_theta] Aparent heat realease rate, which is the total heat energy released per CAD
AHR = cumsum(AHRR*gradient(theta));                             %[J] Cumulative energy release during the whole engine cycle

%Ideal gas law
R_uni = 8.314;       %[J/mol*K] the gas constant
n = ave_pressure(360)*V(360)/(R_uni*T1);

%Gas temperature as a function of CAD
T = ave_pressure.*V'/(n*R_uni);

end

