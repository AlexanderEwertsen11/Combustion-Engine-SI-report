clc
close all


load 'Excerise C Matlab example package'\HCCI_group_2_1200pressurefiles\Group2-Test16.lvm

p_file = Group2_Test16(:,1);            %[V] Pressure signal
gain = 9;                  

[Final_Motored_signal,Final_Fired_signal, ave_pressure, Rep_index, theta] = process_engine_cycles(p_file,p_file,0.1,180,gain,18,true);

%%
close all
%test

rep_P = Final_Fired_signal(:,Rep_index);

N = 1200;                           %RPM of engine
dt = 2*60/(N*length(rep_P));        %Time step between measurements

f_sample=1/dt                       %Sample frequency

t = (1:length(rep_P))*dt            %[seconds] Time vector

passBands = [0 5000 1 1
7000 f_sample/2 1 1];     %Pass band matrix
tbw = 500;                          %[Hz] Transition band width

addpath("Exercise_D\");

filtered_signal = fftBPfilter(t,rep_P,passBands,tbw,'plot_on');
knock_signal = rep_P - filtered_signal;

%Fourier signal
%figure;

% === FET analysis of knock segment === %
region = theta >=0 & theta <= 10;
knock_interval = knock_signal(region);
[freq, spectrum] = FFTanalyze(knock_interval,f_sample);

figure;
plot(freq,spectrum,'b');
xlabel('Frequency [Hz]');
ylabel('Amplitude [bar]');
title('Knock Signal Frequency Spectrum');

figure
plot(theta,ave_pressure)
xlabel("\theta - CAD (Crank angle degree)")
ylabel("Pressure [Pa]")
xlim([-20,20])


%% Calculating theoretical natural frequencies
S = 0.085       %[m] stroke
B = 0.085       %[m] Bore
L = 0.165       %[m] Heat capacity ratio
CR = 7;         %[-] Compression ratio
gamma = 1.35    %[-] Heat capacity ratio
T_intake = (21+273.15)  %[K] Intake temperature;

[IMEP, PMEP, V, AHRR, AHR, T] = Exercise_B_Further_analysis(theta, rep_P, S, B, L, CR, T_intake, gamma);

