% runHCCIexample
close all

BuildRawDataBase = 0;
LoadRawDataBase = 1;
RawDataBaseFileName = 'dbraw';

BuildWorkDataBase = 0;
LoadWorkDataBase = 1;
WorkDataBaseFileName = 'db';

xlsversion = 'xls97'; % Options are 'xls97' and 'xls95'. MAC shoud use 'xls95'

%========================================================================
% Either loading all data from excelsheets and LabView files into a 
% Matlab structure or from a preveously generated Mat file
if BuildRawDataBase
	clear db

	% Properties of the excelsheets that should be stripped
	ExcelProperties = {
	% (path\)filename										1st header row		2nd header row
	'HCCI_group_1_mod'					'Sheet1'			2					5
	'HCCI_group_2_mod'					'Sheet1'			2					5
	'HCCI_group_3_mod'					'Sheet1'			2					5
	};

	% list of variable names for the general data belonging to the 1st header
	VariableList1 = {
	'operator','T_atm','p_atm','date','N','CR','fuel','pressure_file_dir','motoring_file'
	};

	% list of variable names for the test data belonging to the 2nd header
	VariableList2 = {
	'run','T_intake_set','DME_pulse_set','Diesel_mode_set','DME_pulse','T_cool_chamber','T_intake_port',...
	'T_exhaust','pressure_file','Air_flow','DV_diesel','Dt_diesel',...
	'Dm_DME','Dt_DME','torque'
	};

	% stripping all excel data into a single structure
	dbraw = excelstrip(ExcelProperties,VariableList1,VariableList2,xlsversion);

	% adding pressure files to the structure
	dbraw.pressure_file.val = cell(size(dbraw.pressure_file.txt));
	dbraw.motoring_file.val = cell(size(dbraw.pressure_file.txt));
	dbraw.hi_res_pressure_file.val = cell(size(dbraw.pressure_file.txt));
	dbraw.Dp_flowmeter.val = cell(size(dbraw.pressure_file.txt));
	for i = 1:length(dbraw.pressure_file.txt)

		if ~isempty(dbraw.pressure_file.txt{i})

			dbraw.pressure_file.val{i} = dlmread([dbraw.pressure_file_dir.txt{i},'/',dbraw.pressure_file.txt{i}]);
			dbraw.motoring_file.val{i} = dlmread([dbraw.pressure_file_dir.txt{i},'/',dbraw.motoring_file.txt{i}]);

		end

	end

	save(RawDataBaseFileName,'dbraw');

elseif  LoadRawDataBase

	clear db
	load(RawDataBaseFileName);

end

%========================================================================
% Either moving data from raw database into a working database, adding some
% general data and doing some general calculations or loading the working database
% from a previously made MAT file
if BuildWorkDataBase
	clear db

	% engine specs
	db.L = 0.160; % m
	db.S = 0.085; % m
	db.B = 0.085; % m
	db.R = db.S/2; % m
	db.Vd = pi/4*db.B^2*db.S; % m^3
	db.CR = dbraw.CR.val; % m^3/m^3
	db.Vc = db.Vd/(db.CR-1); % m^3
	db.N = dbraw.N.val; % rpm

	% fuel specs
	db.rho_diesel = 840; % g/L

	% general data
	db.totaltests = length(dbraw.run.val);

	% general calculations
	db.mf_diesel = db.rho_diesel*dbraw.DV_diesel.val./dbraw.Dt_diesel.val/1000; % g/s
	db.mf_DME = dbraw.Dm_DME.val./dbraw.Dt_DME.val; % g/s
	db.BMEP = 4*pi*dbraw.torque.val/(1000*db.Vd); % kPa

	save(WorkDataBaseFileName,'db');

elseif  LoadWorkDataBase

	load(WorkDataBaseFileName);

end

%========================================================================
% Generating a plot
Nseries = [];
% finding the index of the relevant data for the plot:  
index = find(~isnan(db.mf_diesel) & ~isnan(db.BMEP) & isnan(db.mf_DME) & db.N == 1200);

% sort the indeces so that the data for the x axis comes in number order:
[notused sortorder] = sort(db.mf_diesel(index));
index = index(sortorder);

figure
plot(db.mf_diesel(index),db.BMEP(index),'+b')

hold on

% preparing a linear fit of the data and plotting it
coef_dieselBMEP = polyfit(db.mf_diesel(index),db.BMEP(index),1);
x = [0:200]/1000;
plot(x,polyval(coef_dieselBMEP,x),'-r')
xlabel('Diesel flow [g/s]')
ylabel('BMEP [kPa]')
