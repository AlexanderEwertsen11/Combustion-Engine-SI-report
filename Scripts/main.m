clear all
close all
clc

load db.mat
load dbraw.mat

%% ================= Plots for Task 1 - Influence of compression ratio =================
close all


% ----------------------- Plot BMEP, IMEP, eta_b & eta_i -----------------------





%% ----------------------- AHHR & AHR CR = 10 -----------------------
close all
Index_fuel_1 = find(dbraw.CR.val(1:24)==10);
Index_fuel_2 = find(dbraw.CR.val(25:end)==10)+24;

LW = 1.4

AHR_1 = db.AHR{Index_fuel_1};
AHR_2 = db.AHR{Index_fuel_2};

AHRR_1=db.AHRR{Index_fuel_1};
AHRR_2=db.AHRR{Index_fuel_2};

% AHR Plot
figure
plot(theta,AHR_1,LineWidth=LW)
hold on
plot(theta,AHR_2,LineWidth=LW)
legend("C3H8","CH4")
title("AHR at CR = 10")
grid on
xlim([min(theta),max(theta)])

% AHRR Plot
figure
plot(theta,AHRR_1,LineWidth=LW)
hold on
plot(theta,AHRR_2,LineWidth=LW)
legend("C3H8","CH4")
title("AHRR at CR = 10")
grid on
xlim([min(theta),max(theta)])

%% ----------------------- AHRR & AHR at max CR -----------------------
close all
Index_fuel_1 = find(dbraw.CR.val(1:24)==max(dbraw.CR.val(1:24)));
Index_fuel_2 = find(dbraw.CR.val(25:end)==max(dbraw.CR.val(25:end)))+24;
LW = 1.4

AHR_1 = db.AHR{Index_fuel_1};
AHR_2 = db.AHR{Index_fuel_2};

AHRR_1=db.AHRR{Index_fuel_1};
AHRR_2=db.AHRR{Index_fuel_2};

% AHR Plot
figure
plot(theta,AHR_1,LineWidth=LW)
hold on
plot(theta,AHR_2,LineWidth=LW)
legend("C3H8","CH4")
title("AHR at highest CR")
grid on
xlim([min(theta),max(theta)])

% AHRR Plot
figure
plot(theta,AHRR_1,LineWidth=LW)
hold on
plot(theta,AHRR_2,LineWidth=LW)
legend("C3H8","CH4")
title("AHRR at highest CR")
grid on
xlim([min(theta),max(theta)])


%% ----------------------- BSFuel slip plots -----------------------
close all
Indecies_Fuel1 = find(dbraw.CR_sweep.val(1:24)==1);
Indecies_Fuel2 = find(dbraw.CR_sweep.val(25:end)==1)+24;

Cr_fuel1 = dbraw.CR.val(Indecies_Fuel1);
[Cr_fuel1_sorted, idx] = sort(Cr_fuel1);

Cr_fuel2 = dbraw.CR.val(Indecies_Fuel2);

%Plot CH4 and C3H8
figure
plot(Cr_fuel1_sorted,dbraw.Fuel.val(idx))
hold on
scatter(Cr_fuel1_sorted,dbraw.Fuel.val(idx),'filled',MarkerFaceColor="blue",Marker="o")

plot(Cr_fuel2,dbraw.Fuel.val(Indecies_Fuel2),"Color","r",LineStyle="-")
scatter(Cr_fuel2,dbraw.Fuel.val(Indecies_Fuel2),'filled',MarkerFaceColor="red",Marker="o")
legend("C3H8","","CH4",Location="northwest")
title("C3H8 & CH4 fuel slip")
grid on
ylabel("C3H8 / CH4 [ppm]")
xlabel("CR - Compression Ratio [-]")


%Plot BSCO
figure
plot(Cr_fuel1_sorted,dbraw.CO.val(idx))
hold on
scatter(Cr_fuel1_sorted,dbraw.CO.val(idx),'filled',MarkerFaceColor="blue",Marker="o")

plot(Cr_fuel2,dbraw.CO.val(Indecies_Fuel2),"Color","r",LineStyle="-")
scatter(Cr_fuel2,dbraw.CO.val(Indecies_Fuel2),'filled',MarkerFaceColor="red",Marker="o")
legend("C3H8","","CH4",Location="northwest")
title("BSCO")
grid on
ylabel("CO [ppm]")
xlabel("CR - Compression Ratio [-]")


% Plot BSNO
figure
plot(Cr_fuel1_sorted,dbraw.NO.val(idx))
hold on
scatter(Cr_fuel1_sorted,dbraw.NO.val(idx),'filled',MarkerFaceColor="blue",Marker="o")

plot(Cr_fuel2,dbraw.NO.val(Indecies_Fuel2),"Color","r",LineStyle="-")
scatter(Cr_fuel2,dbraw.NO.val(Indecies_Fuel2),'filled',MarkerFaceColor="red",Marker="o")
legend("C3H8","","CH4",Location="northwest")
title("BSNO")
grid on
ylabel("NO [ppm]")
xlabel("CR - Compression Ratio [-]")


% Plot BSNO
figure
plot(Cr_fuel1_sorted,dbraw.NO.val(idx))
hold on
scatter(Cr_fuel1_sorted,dbraw.NO.val(idx),'filled',MarkerFaceColor="blue",Marker="o")

plot(Cr_fuel2,dbraw.NO.val(Indecies_Fuel2),"Color","r",LineStyle="-")
scatter(Cr_fuel2,dbraw.NO.val(Indecies_Fuel2),'filled',MarkerFaceColor="red",Marker="o")
legend("C3H8","","CH4",Location="northwest")
title("BSNO")
grid on
ylabel("NO [ppm]")
xlabel("CR - Compression Ratio [-]")








