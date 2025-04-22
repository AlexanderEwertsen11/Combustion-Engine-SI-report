% runHCCIexample
close all
clear all
clc

BuildRawDataBase = 1;
LoadRawDataBase = 0;
RawDataBaseFileName = 'dbraw';

BuildWorkDataBase = 0;
LoadWorkDataBase = 0;
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
	'../CFR_C3H8_scheme'					'Sheet1'			2					4
	'../CFR_CH4_scheme'					'Sheet1'			2					4
	};

	% list of variable names for the general data belonging to the 1st header
	
    VariableList1 = {
    'Group' 'p_atm' 'Date' 'Fuel' 'Engine_speed' 'DAQ_folder' 'Motoring_file'
    };
    
    VariableList2 = {'Test_nr','Ignition_timing','Lambda','CR','Torque','Air_mass_flow',...
    'Fuel_mass_flow','T_intake','T_oil','T_exh','T_head','T_cool_out',...
    'T_cool_in','Cool_flow','H2O','CO2','CO','NO',...
    'NO2','CH2O','C3H8','O2','p_man','Knock',...
    'Pressure_file','CR_sweep','Ignition_sweep','Pressure_sweep','Lambda_sweep'};


	% stripping all excel data into a single structure
	dbraw = excelstrip(ExcelProperties,VariableList1,VariableList2,xlsversion);

	% adding pressure files to the structure
	dbraw.Pressure_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.motoring_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.hi_res_pressure_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.Dp_flowmeter.val = cell(size(dbraw.Pressure_file.txt));
	for i = 1:length(dbraw.Pressure_file.txt)

		if ~isempty(dbraw.Pressure_file.txt{i})
			dbraw.Pressure_file.val{i} = dlmread(['..\C3H8 data\',dbraw.Pressure_file.txt{i},'.txt']);
			dbraw.motoring_file.val{i} = dlmread(['..\C3H8 data\',dbraw.Motoring_file.txt{i},'.txt']);

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
	db.N = dbraw.Engine_speed.val; % rpm

	% fuel specs
	db.rho_diesel = 840; % g/L

	% general data
	db.totaltests = length(dbraw.Test_nr.val);

	% general calculations
	%db.mf_diesel = db.rho_diesel*dbraw.DV_diesel.val./dbraw.Dt_diesel.val/1000; % g/s
	%db.mf_DME = dbraw.Dm_DME.val./dbraw.Dt_DME.val; % g/s
	%db.BMEP = 4*pi*dbraw.torque.val/(1000*db.Vd); % kPa

	save(WorkDataBaseFileName,'db');

elseif  LoadWorkDataBase

	load(WorkDataBaseFileName);

end
