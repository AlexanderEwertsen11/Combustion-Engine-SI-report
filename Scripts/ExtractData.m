% runHCCIexample
close all
clear all
clc

BuildRawDataBase = 1;
LoadRawDataBase = 0;
RawDataBaseFileName = 'dbraw';

BuildWorkDataBase = 1;
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
    'NO2','CH2O','Fuel','O2','p_man','Knock',...
    'Pressure_file','CR_sweep','Ignition_sweep','Pressure_sweep','Lambda_sweep'};


	% stripping all excel data into a single structure
	dbraw = excelstrip(ExcelProperties,VariableList1,VariableList2,xlsversion);

	% adding pressure files to the structure
	dbraw.Pressure_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.Motoring_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.hi_res_pressure_file.val = cell(size(dbraw.Pressure_file.txt));
	dbraw.Dp_flowmeter.val = cell(size(dbraw.Pressure_file.txt));
	for i = 1:length(dbraw.Pressure_file.txt)

		if ~isempty(dbraw.Pressure_file.txt{i})
			dbraw.Pressure_file.val{i} = dlmread(['..\',dbraw.DAQ_folder.txt{i},'\',dbraw.Pressure_file.txt{i},'.txt']);
			dbraw.Motoring_file.val{i} = dlmread(['..\',dbraw.DAQ_folder.txt{i},'\',dbraw.Motoring_file.txt{i},'.txt']);

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
	db.Engine.L = 0.254;                             % m
	db.Engine.S = 0.1143;                            % m
	db.Engine.B = 0.0826;                            % m
	db.Engine.R = db.Engine.S/2;                     % m
	db.Engine.Vd = pi/4*db.Engine.B^2*db.Engine.S;   % m^3
    db.Engine.gamma = 1.35                           %[-] Heat capacity ratio
	db.Engine.N = dbraw.Engine_speed.val(1);            % rpm


	%db.CR = dbraw.CR.val;      % m^3/m^3
	%db.Vc = db.Vd/(db.CR-1);   % m^3

	% fuel specs


	% general data
	db.totaltests = length(dbraw.Test_nr.val);
    
    % Using custom functions to calculate important values
    for i = 1:db.totaltests
        %Loading pressure and motor file for each test run
        fired_pressure_signal = dbraw.Pressure_file.val{i};
        motored_pressure_signal = dbraw.Motoring_file.val{i};
        
        % Using functions to calculate desired values
        [Final_Motored_signal,Final_Fired_signal, ave_pressure, Rep_index, theta] = process_engine_cycles(motored_pressure_signal, fired_pressure_signal, 0.5, 0.5, 10,48);
        [IMEP, PMEP, V, AHRR, AHR, T] = EngineAnalysis(theta, ave_pressure, db.Engine.S, db.Engine.B, db.Engine.L, dbraw.CR.val(i), dbraw.T_intake.val(i), db.Engine.gamma);
        
        %Saving to db work file
        db.AvePressure{i} = ave_pressure;
        db.FinalMotoredSignal{i} = Final_Motored_signal;
        db.FinalFiredSignal{i} = Final_Fired_signal;
        
        %Saving calculated values to db work file
        db.IMEP{i} = IMEP;
        db.PMEP{i} = PMEP;
        db.V{i} = V;
        db.AHRR{i} = AHRR;
        db.AHR{i} = AHR;
        db.T{i} = T;


    end
    db.theta = theta;
    db.repIndex = Rep_index;

    
    % general calculations
	%db.mf_diesel = db.rho_diesel*dbraw.DV_diesel.val./dbraw.Dt_diesel.val/1000; % g/s
	%db.mf_DME = dbraw.Dm_DME.val./dbraw.Dt_DME.val; % g/s
	%db.BMEP = 4*pi*dbraw.torque.val/(1000*db.Vd); % kPa

	save(WorkDataBaseFileName,'db');

elseif  LoadWorkDataBase

	load(WorkDataBaseFileName);

end
