function [Final_Motored_signal,Final_Fired_signal, ave_pressure, Rep_index, theta] = process_engine_cycles(motored_pressure_signal, fired_pressure_signal, Encoder_resolution, TDC_shift, gain,Number_cycles)
%PROCESS_ENGINE_CYCLES Processes engine cycle pressure data.
    %
    % SYNTAX:
    %   [Final_Fired_signal, ave_pressure, Rep_index, theta] = process_engine_cycles(motored_pressure_signal, fired_pressure_signal, Encoder_resolution, TDC_shift, gain, Shift)
    %
    % DESCRIPTION:
    %   This function processes motored and fired engine cycle pressure data.
    %   It corrects TDC shifts, calibrates atmospheric pressure at BDC, 
    %   and identifies the most representative engine cycle.
    %
    % INPUTS:
    %   - motored_pressure_signal : (Vector) Raw motored pressure data [Volts]
    %   - fired_pressure_signal   : (Vector) Raw fired pressure data [Volts]
    %   - Encoder resolution      : (Float) single value [deg/point]
    %   - Shift                   : (Boolean) If true, shifts fired signal
    %
    % OUTPUTS:
    %   - Final_Fired_signal      : (Matrix) Corrected fired pressure cycles [bar]
    %   - ave_pressure            : (Vector) Average fired pressure cycle [bar]
    %   - Rep_index               : (Integer) Index of the most representative cycle
    %   - theta    
Shift = false

atm_pressure = 1.01325;
n_points = 720/Encoder_resolution;       %[-] Number of points
theta = linspace(-360,360-TDC_shift,n_points);         %[deg] Crank angle
TDC_shift_index = TDC_shift/Encoder_resolution; %Index to add to incorporate tdc shift
motored_pressure_signal = motored_pressure_signal*gain;
fired_pressure_signal = fired_pressure_signal*gain;

% Reshape the data into each cycle, remembering that it's a 4 stroke engine
M_pressure_matrix = reshape(motored_pressure_signal,[n_points,Number_cycles+2]);
F_pressure_matrix = reshape(fired_pressure_signal,[n_points,Number_cycles+2]);

Index_TDC_motored = find(mean(M_pressure_matrix,2)==max(mean(M_pressure_matrix,2)))+TDC_shift_index;

Stripped_motored_data = motored_pressure_signal(Index_TDC_motored+720:Number_cycles*n_points+Index_TDC_motored+719);

for l = 1:2

if Shift == false
    Stripped_fired_data = fired_pressure_signal(Index_TDC_motored:Number_cycles*n_points+Index_TDC_motored-1);
elseif Shift == true
    Stripped_fired_data = fired_pressure_signal(Index_TDC_motored+720:Number_cycles*n_points+Index_TDC_motored+719);
end

new_motored_martix = reshape(Stripped_motored_data,[n_points,Number_cycles]);
new_fired_matrix = reshape(Stripped_fired_data,[n_points,Number_cycles]);


% Mean of all cycles for motored and fired
Mean_M_pressure = mean(new_motored_martix,2);
Mean_F_pressure = mean(new_fired_matrix,2);

% Calculating the BDC (Bottom dead center) to calibrate pressure
BDC_index = 360;
BDC_value_Motored = Mean_M_pressure(BDC_index);
BDC_new_Value_motored = BDC_value_Motored-atm_pressure;      %Set athmospheric pressure at BDC
Offset_matrix_m = repmat(BDC_new_Value_motored,[size(new_motored_martix)]);

BDC_value_fired = Mean_F_pressure(BDC_index);
BDC_new_Value_fired = BDC_value_fired-atm_pressure;          %Set athmospheric pressure at BDC
Offset_matrix_f = repmat(BDC_new_Value_fired,[size(new_fired_matrix)]);


Final_Motored_signal = new_motored_martix-Offset_matrix_m;
Final_Fired_signal = new_fired_matrix-Offset_matrix_f;

ave_pressure = mean(Final_Fired_signal,2);

% --------------------------- 
%Check to see if it has to be shifted or not
Index_check = find(ave_pressure==max(ave_pressure));

if theta(Index_check) <-100 || theta(Index_check) > 100
    Shift = true
end
% --------------------------- 

end


deviation  = sum(abs(Final_Fired_signal-ave_pressure),1)

[~,Rep_index] = min(deviation)

end


