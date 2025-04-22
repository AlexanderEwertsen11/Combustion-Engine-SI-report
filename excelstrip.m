function dbraw = excelstrip(ExcelProperties,VariableList1,VariableList2,xlsversion)
%
% Strips data from a list of excel workbooks and collect all the data into a
% single data structure (dbraw). The excel sheet has to follow some standards:
%	- It should contain two tables:
%		1)	The first table should have one header row and below that, one data row.
%			The width of the table is unlimited and it does not have to start
%			in first column of the sheet.
%		2)	The second table should have one header row and below that, unlimited
%			number of data rows. The width of the table is unlimited but it 
%			should start in the same column as the first table.
%	- The header cells should not contain nummeric data. The data cells may contain
%	  nummeric data or text. Empty cells within the table will become NaN and [] in
%	  the data structure (dbraw);
%
% =============================================================================
% Arguments
%
% Excelproperties: Cell array containing the filename of the excel workbook (with
% or without path) in the first column. Sheetname or index number of worksheet in
% the second row. Third and fourth column should contain the index number for the
% first and second table header row, respectively. 
%
% Example: 
% ExcelProperties = {
% 'Group 1\HCCI test scheme1200 rpm.xls'					'Sheet1'		2		5
% 'Group 1\HCCI test scheme1200 rpm.xls'					'Sheet2'		2		5
% 'Group 3\HCCI test scheme1800 rpm.xls'					'Sheet1'		2		5
% 'Group 3\HCCI test scheme1800 rpm.xls'					'Sheet2'		2		5
% '..\last year\Group 3\HCCI test scheme1800 rpm.xls'		1				4		9
% '..\last year\Group 3\HCCI test scheme1800 rpm.xls'		2				4		9
% '..\last year\Group 3\HCCI test scheme1800 rpm.xls'		3				4		9
% };
%
% VariableList1: Should contain a cell array with variable names that you wish to give
% the column data from the first table of the sheet. VariableList1 should have at least
% same length as the first table in the sheet with the widest table.
%
% Example:
% VariableList1 = {
% 'operator','T_atm','p_atm','date','N','CR','fuel','pressure_file_dir','motoring_file'
% };
%
% VariableList2: Same as VariableList1 but with regard to the second table.
%
% xlsversion: Options are 'xls97' and 'xls95'. 'xls95' is ~5x faster than 'xls97'
% but also less flexible regarding data compatibility.
%
% MAC users has to run xls95 and make sure that the workbook is saved as so. To
% ensure this save the sheet as 95 version xls, close the sheet and reopen
% and save it again...... Don't ask me why it is necessary to save it two times 
% as 95 version to enforce it to happen. Ask Bill Gates.
%
% ========================================================================
% Output
% dbraw is a single data structure containing all the data from all the
% the specified excelsheets.
%
% dbraw will contain substructures with the names specified in VariableList1
% and VariableList2. Each substructure contain three fields: head, txt and val.
%	-head is a cell array of header text from the respective sheet and column.
%	-txt is a cell array of cell text from the respective sheet, column and row.
%	-val is a vector with nummeric value from the respective sheet, column and row.
%
% In addition to the substructures specified in VariableList1 and VariableList2
% fields are made with the names: GeneralDataHeader, GeneralDataTxt, GeneralDataVal,
% TestHeader, TestDataTxt, TestDataVal.
% They contain large cell arrays with all sheet content as either header text,
% cell text or nummeric values. GeneralData means data from the first table in
% the excel sheets. TestData means data from the second table. General data from
% each sheet has been copied to fit the number of test data rows.
%
% A field called xlsFileName is made. It contains the filename with partial path
% relative to the working directory. 
% excelsheet from which the row data has been stripped.
% 
% A field called WorkingDir contain the full path of the working directory
% where the matlab script was run.  

TestDataVal = {};
TestDataTxt = {};
TestDataHeader = {};
TestDataSizes = [];

GeneralDataVal = {};
GeneralDataTxt = {};
GeneralDataHeader = {};
GeneralDataSizes = [];

xlsFileName = {};
xlsSheet = {};

for i = 1:size(ExcelProperties,1)

	sheet = ExcelProperties{i,2};
	header1row = ExcelProperties{i,3};
	header2row = ExcelProperties{i,4};

	if strcmp(xlsversion,'xls95')
		[dum,dum,raw] = xlsread(ExcelProperties{i,1},sheet,'A1:B2','basic');
	elseif strcmp(xlsversion,'xls97')
		[dum,dum,raw] = xlsread(ExcelProperties{i,1},sheet);
	else
		[dum,dum,raw] = xlsread(ExcelProperties{i,1},sheet);
	end

	raw1 = raw(header1row:header1row+1,:);
	textcells1 = cellfun(@isstr,raw1);
	raw1strless = raw1;
	raw1strless(textcells1) = {'-'};
	emptycells1 = cellfun(@isnan,raw1strless);
	valcells1 = ~emptycells1 & ~textcells1;
	firstcol = find(any(~emptycells1,1),1,'first');
	lastcol = find(any(~emptycells1,1),1,'last');
	raw1 = raw1(:,firstcol:lastcol);
	emptycells1 = emptycells1(:,firstcol:lastcol);
	textcells1 = textcells1(:,firstcol:lastcol);
	valcells1 = ~emptycells1 & ~textcells1;


	raw2 = raw(header2row:end,:);
	textcells2 = cellfun(@isstr,raw2);
	raw2strless = raw2;
	raw2strless(textcells2) = {'-'};
	emptycells2 = cellfun(@isnan,raw2strless);
	firstcol = find(any(~emptycells2,1),1,'first');
	lastcol = find(any(~emptycells2,1),1,'last');
	lastrow = find(any(~emptycells2,2),1,'last');
	raw2 = raw2(1:lastrow,firstcol:lastcol);
	emptycells2 = emptycells2(1:lastrow,firstcol:lastcol);
	textcells2 = textcells2(1:lastrow,firstcol:lastcol);
	valcells2 = ~emptycells2 & ~textcells2;

	headerraw = raw2(1,:);
	dataraw = raw2(2:end,:);
	TestDataSizes = [TestDataSizes; size(dataraw)];

	TestDataHeader{i} = cell(headerraw);
	TestDataHeader{i}(textcells2(1,:)) = headerraw(textcells2(1,:));
	TestDataHeader{i} = repmat(TestDataHeader{i},TestDataSizes(i,1),1);

	TestDataVal{i} = nan(size(dataraw));
	TestDataVal{i}(valcells2(2:end,:)) = [dataraw{valcells2(2:end,:)}];

	TestDataTxt{i} = cell(size(dataraw));
	TestDataTxt{i}(textcells2(2:end,:)) = dataraw(textcells2(2:end,:));

	headerraw = raw1(1,:);
	dataraw = raw1(2,:);
	GeneralDataSizes = [GeneralDataSizes; size(dataraw)];

	GeneralDataHeader{i} = cell(headerraw);
	GeneralDataHeader{i}(textcells1(1,:)) = headerraw(textcells1(1,:));
	GeneralDataHeader{i} = repmat(GeneralDataHeader{i},TestDataSizes(i,1),1);

	GeneralDataVal{i} = nan(size(dataraw));
	GeneralDataVal{i}(valcells1(2,:)) = [dataraw{valcells1(2,:)}];
	GeneralDataVal{i} = repmat(GeneralDataVal{i},TestDataSizes(i,1),1);

	GeneralDataTxt{i} = cell(size(dataraw));
	GeneralDataTxt{i}(textcells1(2,:)) = dataraw(textcells1(2,:));
	GeneralDataTxt{i} = repmat(GeneralDataTxt{i},TestDataSizes(i,1),1);

	xlsFileName{i} = repmat(ExcelProperties(i,1),TestDataSizes(i,1),1);
	xlsSheet{i} = repmat(ExcelProperties(i,2),TestDataSizes(i,1),1);

end

dbraw.general.head = {};
dbraw.general.txt = {};
dbraw.general.val = [];

dbraw.test.head = {};
dbraw.test.txt = {};
dbraw.test.val = [];

dbraw.xlsFileName = {};
dbraw.xlsSheet = {};

GeneralMaxRows = max(GeneralDataSizes(:,2));
TestMaxRows = max(TestDataSizes(:,2));

for i = 1:size(ExcelProperties,1)

 	dbraw.general.head = [dbraw.general.head;...
 		[GeneralDataHeader{i} cell(TestDataSizes(i,1),GeneralMaxRows-GeneralDataSizes(i,2))]];
	dbraw.general.txt = [dbraw.general.txt; ...
		[GeneralDataTxt{i} cell(TestDataSizes(i,1),GeneralMaxRows-GeneralDataSizes(i,2))]];
	dbraw.general.val = [dbraw.general.val; ...
		[GeneralDataVal{i} nan(TestDataSizes(i,1),GeneralMaxRows-GeneralDataSizes(i,2))]];

	dbraw.test.head = [dbraw.test.head;...
		[TestDataHeader{i} cell(TestDataSizes(i,1),TestMaxRows-TestDataSizes(i,2))]];
	dbraw.test.txt = [dbraw.test.txt; ...
		[TestDataTxt{i} cell(TestDataSizes(i,1),TestMaxRows-TestDataSizes(i,2))]];
	dbraw.test.val = [dbraw.test.val; ...
		[TestDataVal{i} nan(TestDataSizes(i,1),TestMaxRows-TestDataSizes(i,2))]];

	dbraw.xlsFileName = [dbraw.xlsFileName; xlsFileName{i}];
	dbraw.xlsSheet = [dbraw.xlsSheet; xlsSheet{i}];

end

for i = 1:length(VariableList1)

 	dbraw = setfield(dbraw,VariableList1{i},struct('head',{dbraw.general.head(:,i)},...
			'txt',{dbraw.general.txt(:,i)},'val',{dbraw.general.val(:,i)}));

end

for i = 1:length(VariableList2)

 	dbraw = setfield(dbraw,VariableList2{i},struct('head',{dbraw.test.head(:,i)},...
			'txt',{dbraw.test.txt(:,i)},'val',{dbraw.test.val(:,i)}));

end

	wd = what;
	dbraw.WorkingDir = wd.path;
