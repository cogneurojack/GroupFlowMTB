%% BREAK UP AND RE-BUILD ROB CODE
%% STARTING VALUES FOR SCRIPT

clear all

% Central pixel of the screen
ScreenCenterX = 1050/2;
ScreenCenterY = 1400/2;

% size of the red central circle
height = 35*105/100;
width = 28*140/100;

circle = height*width/4;
circle = circle^2;


%% LOAD EACH PAIRS FOLDER & SURVEY DATA

% NEED TO CHANGE TO CSV [num, text, surveyData]= xlsread('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/allSurveyClean.xlsx');
matrixFolder = 'E:\\DATA\\groupFlow_S\\';
outputFolder = 'E:\\DATA\\groupFlow_trialDat\\';
infoMat=[];
% % TEST FOLDERS
% matrixFolder = '/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/';
% outputFolder = '/Users/jackmoore/Desktop/';


cd(matrixFolder);
matrixFolderInfo = dir(matrixFolder);
matrixFolderInfo = matrixFolderInfo(3:end);
% these two settings draw the [folder] which is currently being evaluated
% (starts at 3 as first to docs are related to system settings)


% work out total number of subject folder we have
numFolder = length(matrixFolderInfo);


% set headers for output data
headers = {'groupName' 'groupNum' 'trialName' 'trialLength' 'trialNum' ...
    'ifWin' 'winPercent' 'COCpercent'};
iFolder=1;
%% load each subject group folder in turn
for iFolder = 1:length(matrixFolderInfo)
    % Draw the [file] within each folder that
    % is currently being evaluated (starts at 3 as first to docs are
    % related to system settings)
    file = 1;
    trial = 1;
    % create a variable that will allow us to call each [subjFolder] in
    % turn
    subjFolder = matrixFolderInfo(iFolder);
    subjFolderName = subjFolder.name;
    subjFolder = [matrixFolder subjFolderName];
    
    % make the current subject folder the current working directory
    cd(subjFolder);
    subjFolderInfo = dir(subjFolder);
    
    dataFiles = ([subjFolder '/' '*.dat']);
    dataFilesInfo = dir(dataFiles);
    % work out total number of files we have for that pair and create an
    % output file with the length of the number of files
    numFiles = length(dataFilesInfo);
    PB = 1; % number to cycle if PB trial
    
%% LOAD FILE AND SET OUTPUT FILE VAUES AND SIZE
    for i = 1:numFiles     
        
        % create a variable that will allow us to call each [subjFile] in
        % turn
        fileName = dataFilesInfo(i).name;
        loadFile = [subjFolder '/' fileName];
        thisFile = importdata(loadFile);
        data = thisFile.data;                 % Each file's data
        totalTime = length(data);             % Length of tile
        trialLength = totalTime/15;           % 15 = sample rate
        trialNum = data(1,3);                 % trialNum
        
        fDate = dataFilesInfo(i).date;        % File date
        fDate = datenum(fDate);
        fDate = datevec(fDate);
        fDate = [num2str(fDate(3)) '/' num2str(fDate(2)) '/' num2str(fDate(1))];
        
        % Cut the last 45s of each trial
        if totalTime > 675;data = data((totalTime-675:totalTime),:);   
        end
       
      
      
        
        %create a matrix to look at responses in each trial
        totalTime = length(data);           % Length of tile
        winMatrix = nan(totalTime,9);       % output matrix
        winMatrix(:, 1:2) = data(:,[3 1]);  % column1 = trial num; column2 = sample
        Nsheep = 5;                         % We had 5 sheep
        
       
        % creat response for if all sheep contained
        winLog = nan(1,5);                  % vector for if each sheep contained
        TotalSheepWinTime = 0;              % var for each all sheep contained
        
        
        for frame = 1:length(data)
            SheepX = data(:,[4 6 8 10 12]);
            SheepY = data(:,[5 7 9 11 13]);
            
            % for loop to check in each frame if each sheep is inside
            for sheep = 1:Nsheep
                
                % check if sheep are in the red area
                % cpw2sq is square of radius of red area in px
                SheepdX = SheepX(frame,sheep)-ScreenCenterX;
                SheepdY = SheepY(frame,sheep)-ScreenCenterY;
                SheepD = (SheepdX^2)+(SheepdY^2);
                
                
                % if the sheep is not in the circle for that frame then SheepIn = false
                
                sheepWinLog  = double(SheepD < circle);
                winLog(sheep) = sheepWinLog;
            end
            
            winMatrix(frame,3:7) = winLog;
            
            if sum(winLog) == 5
                TotalSheepWinTime = TotalSheepWinTime+1;
            else
                TotalSheepWinTime;
            end
            
            winMatrix(frame,8) = TotalSheepWinTime;
            
            winMatrix(frame,9) = 100*(TotalSheepWinTime/676);
           
            
        end
        
        ifWin = TotalSheepWinTime >= 470;
        
        
        practiceFiles = ([subjFolder '/' '*' 'practice.dat']);
        practiceFilesInfo = dir(practiceFiles);
        practice=length(practiceFilesInfo);
        
        fileName = dataFilesInfo(i).name;
        x = length(fileName);
        
        if  fileName([x-5:x]) ==  'PB.dat'
            ifWin = 9;
            winMatrix(totalTime,8) = 0;
            winMatrix(totalTime,9) = 0;
            PB=PB+1;
        elseif (dataFilesInfo(i).name(6))=='p' || dataFilesInfo(i).name(6)=='t'
            i = numFiles;
        end
        
        
        % Central pixel of the screen for COC
        PolePosxy = [ScreenCenterX ScreenCenterY];
        polePos = nan(totalTime,1);
        polePos(:,1)=PolePosxy(1);
        names = thisFile.textdata;
        
        % create var for position of sheepdog to work out COC
        dog1 = data(:,18:19);
        dog2 = data(:,19:20);
  
  
        % Output matrix column: GOUPNAME | GROUPNUM | TRIALNAME | TRIALNUM |
        % IFWIN | WINPERCENT | COCPERCENT
        fileName = fileName(1:end-4);
        
        % 1 = subjFolderName 
        % 2 = fileName
        % 3 = Trial number
        % 4 = length of trial
        % 5 = ifWin
        trialOutput = table({0},{subjFolderName}, {fileName}, ...
            {trialNum}, {trialLength}, {ifWin});
        trialOutput.Properties.VariableNames{'Var1'} = 'TimeStamp';
        trialOutput.Properties.VariableNames{'Var2'} = 'DyadName';
        trialOutput.Properties.VariableNames{'Var3'} = 'fileName';
        trialOutput.Properties.VariableNames{'Var4'} = 'Trial';
        trialOutput.Properties.VariableNames{'Var5'} = 'Length';
        trialOutput.Properties.VariableNames{'Var6'} = 'ifWin';
        
if file == 1
            subjOutput = trialOutput;
        elseif i<=numFiles
            subjOutput = [subjOutput ; trialOutput];
        elseif i == numFiles
            subjOutput = trialOutput;
        end
        
        
simpMat = subjOutput;
        
        trial = trial+1;
        file = file+1;
    end
    

    %% SAVE EACH GROUP AS AN EXCEL FILE
    % set headers for output data
        
    outputName = [outputFolder subjFolderName '.csv'];
    writetable(subjOutput, outputName);
    infoMatName = [outputFolder 'InfoMatrix.csv'];
    infoMat = [infoMat;subjOutput];
    writetable(infoMat, infoMatName);
    disp(['script is ' num2str(round((100/numFolder)*iFolder)) '% complete'])
end

