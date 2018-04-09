% site specific script to load site information
% NREL Solar Farm 2017 - "1341","CR5000.Std.07","CPU:NREL-Summer-2017-Tower.CR5","45983","Sonic20Hz_"

% enter orientation of sonics.  Sonic order: tables sorted alphabetically followed by columns sorted in ascending order
info.sonicOrientation = [135, 135, 135]; %[135, 135, 135];

% enter manufacturer of SAT.  1 for Campbell, 0 for RMYoung.  RMYoung v = Campbell u!
info.sonicManufact = [1, 1, 1];  % ES5

% enter orientation of tower relative to sonic head
info.tower = 135+180; %150; % ES5

% tower elevation
info.siteElevation = 1609.3; % (m) Denver

% enter expected table names.  Missing tables will be filled with NaNs to create consistency 
% when multiple output files are concatnated with getData.m
info.tableNames = {'Sonic20Hz'};

% enter table scan frequencies corresponding to tableNames
info.tableScanFrequency = [20];  %[Hz]

% enter number of columns in each .csv table.  Note that the number of columns in the output structure will 
% be 3 less than the number in the .csv file.  This is because the 4 column date vector is replaced with a Matlab's 
% single-column serial time.  Also, note that View Pro frequently cuts of column 1 (the year!) of the .csv file. 
info.tableNumberOfColumns = [19];
