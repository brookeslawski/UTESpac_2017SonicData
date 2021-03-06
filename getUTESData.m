function outputStruct = getUTESData(rootFolder, startDate, endDate, varargin)
% getUTESData loads and vertically concatnates processed data from UTESpac.
% rootFolder:  location of site folders e.g. 'F:\'
% options:
% 'site' - string of site name beginning with 'site'.  e.g. 'siteMySite'
% 'avgPer' - averaging period in minutes e.g. 5
% 'qualifier' - data qualifier that precedes date e.g. 'LPF', 'LPF_ConstDet', 'GPF', 'LinDet', etc.
% 'rows' - array corresponding to processed dates in alphanumerical order.  e.g. 0; [5:20];

if nargin < 4
    varargin = 0;
end

% initialize output structure subfields
outputStruct = struct;

% find possible sites of interest
sitesStruct = dir(strcat(rootFolder,filesep,'site*'));

% find location of 'site' option if it exists
siteOptionLocation = strcmp(varargin,'site');
if ~max(siteOptionLocation) % if 'site' option not used, display all sites
    % display possible sites to command window
    for ii = 1:length(sitesStruct)
        display(sprintf('%g. %s',ii,sitesStruct(ii).name));
    end
    
    % ask user to select appropriate site
    site = sitesStruct(input('Please indicate site of interest: ')).name; clc;
else
    site = sitesStruct(varargin{find(siteOptionLocation)+1}).name;
end
siteFolder = strcat(rootFolder,filesep,site);

% find output file avgPer
avgPerOptionLocation = strcmp(varargin,'avgPer');
if max(avgPerOptionLocation)
    avgPer = varargin{find(avgPerOptionLocation)+1};
else
    avgPer = [];
end

% find output file qualifier
qualifierOptionLocation = strcmp(varargin,'qualifier');
if max(qualifierOptionLocation)
    qualifier = varargin{find(qualifierOptionLocation)+1};
else
    qualifier = [];
end

% find possible output files of interest
if varargin==0
    filesStruct = dir(strcat(siteFolder,filesep,'output',filesep, '*.mat'));
else
    filesStruct = dir(strcat(siteFolder,filesep,'output',filesep,'*',num2str(avgPer),'*',qualifier,'*mat'));
end

% find location of 'rows' option if it exists
rowsOptionLocation = strcmp(varargin,'rows');
if max(rowsOptionLocation)
    rows = varargin{find(rowsOptionLocation)+1};
else
    % display possible output files to command window
    display('Displaying all output files')
    for ii = 1:length(filesStruct)
        display(sprintf('%g. %s',ii,filesStruct(ii).name));
    end
    
    % ask user to select appropriate outputfiles
    rows = input('Plese input dates of interest. e.g. [1 3 4:7] or ''0'' for all dates: ');clc;
end
% if '0' input, make rows of interest equal to all possible dates
if rows == 0
    rows = 1:numel(filesStruct);
end

% store output file name in outputFileNames cell
for ii = 1:length(rows)
    outputFileName{ii} = strcat(siteFolder,filesep,'output',filesep,filesStruct(rows(ii)).name);
end

% iterate through all file names
for ii = 1:numel(outputFileName)
    
    % load local output
    try
        output = load(outputFileName{ii});
        if isfield(output,'rawFlux')
            tmp = output.rawFlux;
            clear output
            output =tmp;
            clear tmp;
        else
            tmp = output.output;
            clear('output')
            output=tmp;
            clear('tmp')
        end
    catch err
        warning('Problem loading %s output structure: %s',outputFileName{ii},err.message)
        pause(2)
    end
    
    % find all fields of local output
    outputFields = fields(output);
    
    % find expected number of rows from averaged data tables
    if isfield(output,'tableNames')  % use averaged tables for avg data
        standardField = 'tableNames';
        numStandardFields = numel(output.(standardField));
    elseif isfield(output,'t') % use time stams for raw data
        standardField = 't';
        numStandardFields = 1;
    end
   
    for jj = 1:numStandardFields
        if strcmp(standardField,'tableNames')
            try
                numRows(jj) = size(output.(output.(standardField){jj}),1);
            catch err
               error('Problem loading %s output structure: %s',outputFileName{ii},err.message)
            end
        elseif strcmp(standardField,'t')
            numRows(jj) = size(output.(standardField),1);
        end
    end
    
    % if the number of rows in all tables is not the same, continue to next file
    if numel(unique(numRows)) > 1
        warning('Number of rows in %s inconsistent accross tables, date will be skipped',outputFileName{ii})
        continue
    end
    
    %Account for missing files (fill as NaNs)
    missingFlag = 0;
    endFlag = 0;
    rowDisplace = 0;
    if ii~=1 && ii~=numel(outputFileName)
        check = abs(outputStruct.(outputFields{1})(end, 1)-output.(outputFields{1})(1, 1));
        if check>0.5
            missingFlag = 1;
            rowDisplace = check*(1440)/30-1;
        end
    elseif ii==1
        check = abs(startDate-output.(outputFields{1})(1, 1));
        if check>0.5
            missingFlag = 1;
            rowDisplace = check*(1440)/30-1;
        end
    elseif ii==numel(outputFileName)
        check = abs(endDate-output.(outputFields{1})(end, 1));
        if check>0.5
            missingFlag = 1;
            endFlag = 1;
            rowDisplace = check*(1440)/30;
        end
    end
    
    if size(output.rotatedSonic, 2)<4
        output.rotatedSonic = [output.H(:, 1), output.rotatedSonic];
        output.rotatedSonicHeader = ['time', output.rotatedSonicHeader];
    end

    % iterate through allFields
    for jj = 1:numel(outputFields)
        % find local data
        localData = output.(outputFields{jj});
        
        % fill in from missing files
        if missingFlag
            if and(isempty(logical(strfind(outputFields{jj}, 'eader'))), ~iscell(localData))
                if endFlag
                    if or(output.(outputFields{jj})(end, 1)<datenum(1500,0, 0), isnan(output.(outputFields{jj})(end, 1)))
                        tmpTime = nan.*ones(round(rowDisplace, 0), 1);
                    else
                        tmpTime = (endDate-check:30/1440:endDate-30/1440)';
                    end
                    tmpFill = [...
                        tmpTime,...
                        nan.*ones(round(rowDisplace, 0), size(localData, 2)-1)];
                    localData = [localData; tmpFill];   
                else
                    if or(output.(outputFields{jj})(1, 1)<datenum(1500,0, 0), isnan(output.(outputFields{jj})(1, 1)))
                        tmpTime = nan.*ones(round(rowDisplace, 0), 1);
                    else
                        tmpTime = ...
                            (output.(outputFields{jj})(1, 1)-check+30/1440:30/1440:output.(outputFields{jj})(1, 1)-30/1440)';
                    end
                    %Display sizes if they are off
                    if size(tmpTime, 1)~=size(nan.*ones(round(rowDisplace, 0), size(localData, 2)-1), 1)
                        disp(size(tmpTime))
                        disp(size(nan.*ones(round(rowDisplace, 0), size(localData, 2)-1)))
                    end
                    tmpFill = [...
                        tmpTime,...
                        nan.*ones(round(rowDisplace, 0), size(localData, 2)-1)];
                    localData = [tmpFill; localData];                                     
                end
            end
        end
        
        % partition local data
        if ~isfield(outputStruct,outputFields{jj}) % if field does not exist in outputStruct, create it
            outputStruct.(outputFields{jj}) = localData;
            if ii > 1
                warning('Field %s initialized for ii = %g.  Rows may be inconsistent accross fields',outputFields{jj},ii)
            end
        elseif max(strfind(outputFields{jj},'eader')) % if header, do not vertically concatnate
            continue
        elseif max(strfind(outputFields{jj},'tableNames')) % if tableNames, do not vertically concatnate
            continue
%         elseif max(strfind(outputFields{jj},'z')) % if z for raw tables, do not vertically concatnate
%             continue
        elseif iscell(localData)
            if ~isempty(localData{1})
                [cellRows, cellCols] = size(localData);
                outputStruct.(outputFields{jj})(end+1:end+cellRows,1:cellCols) = localData;
            end
        else % for regular data, check size and then vertically concatenate
            numLocalCols = size(localData,2);
            numLocalRows = size(localData,1);
            numExpectedRows = numRows(1);
            numExpectedCols = size(outputStruct.(outputFields{jj}),2);
            
            if numLocalCols ~= numExpectedCols || numLocalRows ~= numExpectedRows
                if ~strfind(outputFields{jj}, 'Struct')
                    localData = nan(numExpectedRows,numExpectedCols);

                    warning('File: %s.  Field: %s.  Expected Size = [%g %g].  Actual Size = [%g %g].  NaN(expected size) will be used.',outputFileName{ii},outputFields{jj},numExpectedRows,numExpectedCols,numLocalRows,numLocalCols)
                else
                    %Ignore expected size if Structure param
                end
            end
                
            outputStruct.(outputFields{jj}) = [outputStruct.(outputFields{jj}); localData];
        end
        
        clear localData
    end
end