%% BREAK UP AND RE-BUILD ROB CODE
%% STARTING VALUES FOR SCRIPT

% Central pixel of the screen
ScreenCenterX = 1050/2;
ScreenCenterY = 1400/2;

% size of the red central circle
height = 35*105/100;
width = 28*140/100;

circle = height*width/4;
circle = circle^2;


%% LOAD EACH PAIRS FOLDER & SURVEY DATA

[num, text, surveyData]= xlsread('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/allSurveyClean.xlsx');
matrixFolder = '/Volumes/HYPERSCAN/groupFlow_S/';
outputFolder = '/Volumes/HYPERSCAN/';
infoMat=[];
% % TEST FOLDERS
% matrixFolder = '/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/';
% outputFolder = '/Users/jackmoore/Desktop/';


cd(matrixFolder);
matrixFolderInfo = dir(matrixFolder);

% these two settings draw the [folder] which is currently being evaluated
% (starts at 3 as first to docs are related to system settings)


% work out total number of subject folder we have
numFolder = length(matrixFolderInfo);


% set headers for output data
headers = {'groupName' 'groupNum' 'trialName' 'trialLength' 'trialNum' ...
    'ifWin' 'winPercent' 'COCpercent'};
iFolder=3;
%% load each subject group folder in turn
for iFolder = 3:length(matrixFolderInfo)
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
    i=1;
    for i = 1:numFiles
        
        
        % create a variable that will allow us to call each [subjFile] in
        % turn
        loadFile = [subjFolder '/' dataFilesInfo(i).name];
        thisFile = importdata(loadFile);
        data = thisFile.data;                 % Each file's data
        totalTime = length(data);             % Length of tile
        trialLength = totalTime/15;           % 15 = sample rate
        
        % Cut the last 45s of each trial
        if totalTime >= 675;data = data((totalTime-675:totalTime),:);   
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
        elseif practice==0
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
        
        % work out the shepherding classification
        cd('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/GroupFlowMTB');
        [dog1_theta, dog2_theta] = cartesian2polar(dog1, dog2, polePos);
        [dog1Classification, dog2Classification]= ShepherdingClassification(dog1_theta, dog2_theta);
       
        
        %% Survey function
        
        biosemi = {subjFolderName(1:2) subjFolderName(3:4)};
        
        [subjSurveyDat] = fSurveyDat(biosemi,surveyData)
        
        % Output matrix column: GOUPNAME | GROUPNUM | TRIALNAME | TRIALNUM |
        % IFWIN | WINPERCENT | COCPERCENT
        fileName = fileName(1:end-4);
        
        trialNum = data(1,3);
        sheepFrames = winMatrix(totalTime,8);
        sheepPercent = winMatrix(totalTime,9);
        
        % 1 = subjFolderName 
        % 2 = fileName
        % 3 = Trial number
        % 4 = length of trial
        % 5 = ifWin
        % 6 = How much of the trial sheep were contatined (will only be
        % over %69 if they were contained from the start of th trial
        % 7 = Number of frames the sheep were contained
        % 8 = dog1Classification
        % 9 = dog2Classification
        trialOutput = table({0},{subjFolderName}, {fileName}, ...
            {trialNum}, {trialLength}, {ifWin}, {sheepFrames},...
            {sheepPercent}, {dog1Classification}, {dog2Classification},...
            {0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},...
            {0},{0},{0},{0},{0},{0},{0},{0},{0},{0});
        trialOutput.Properties.VariableNames{'Var1'} = 'TimeStamp';
        trialOutput.Properties.VariableNames{'Var2'} = 'DyadName';
        trialOutput.Properties.VariableNames{'Var3'} = 'fileName';
        trialOutput.Properties.VariableNames{'Var4'} = 'Trial';
        trialOutput.Properties.VariableNames{'Var5'} = 'Length';
        trialOutput.Properties.VariableNames{'Var6'} = 'ifWin';
        trialOutput.Properties.VariableNames{'Var7'} = 'sheepFrame';
        trialOutput.Properties.VariableNames{'Var8'} = 'sheepPercent';
        trialOutput.Properties.VariableNames{'Var9'} = 'dog1Classification';
        trialOutput.Properties.VariableNames{'Var10'} = 'dog2Classification';
        trialOutput.Properties.VariableNames{'Var11'} = 'Activity';
        trialOutput.Properties.VariableNames{'Var12'} = 'IF_PB';
        trialOutput.Properties.VariableNames{'Var13'} = 'L_shared01self100_control_of_sheep';
        trialOutput.Properties.VariableNames{'Var14'} = 'L_working_in_harmony_with_the_other_player';
        trialOutput.Properties.VariableNames{'Var15'} = 'L_experience_being_in_control_over_the_movement_of_the_sheep';
        trialOutput.Properties.VariableNames{'Var16'} = 'L_take_ownership_over_the_movement_of_the_sheep';
        trialOutput.Properties.VariableNames{'Var17'} = 'L_Were_the_demands_of_the_task_well_matched_to_your_ability';
        trialOutput.Properties.VariableNames{'Var18'} = 'L_How_much_did_you_enjoy_this_activity';
        trialOutput.Properties.VariableNames{'Var19'} = 'L_YesNo_Flow_Question';
        trialOutput.Properties.VariableNames{'Var20'} = 'L_Event_Experience_Scale';
        trialOutput.Properties.VariableNames{'Var21'} = 'L_Flow_Synchronisation_Scale';
        trialOutput.Properties.VariableNames{'Var22'} = 'L_Sense_of_Agency';
        trialOutput.Properties.VariableNames{'Var23'} = 'R_shared01self100_control_of_sheep';
        trialOutput.Properties.VariableNames{'Var24'} = 'R_working_in_harmony_with_the_other_player';
        trialOutput.Properties.VariableNames{'Var25'} = 'R_experience_being_in_control_over_the_movement_of_the_sheep';
        trialOutput.Properties.VariableNames{'Var26'} = 'R_take_over_the_movement_of_the_sheep';
        trialOutput.Properties.VariableNames{'Var27'} = 'R_Were_the_demands_of_the_task_well_matched_to_your_ability';
        trialOutput.Properties.VariableNames{'Var28'} = 'R_How_much_did_you_enjoy_this_activity';
        trialOutput.Properties.VariableNames{'Var29'} = 'R_YesNo_Flow_Question';
        trialOutput.Properties.VariableNames{'Var30'} = 'R_Event_Experience_Scale';
        trialOutput.Properties.VariableNames{'Var31'} = 'R_Flow_Synchronisation_Scale';
        trialOutput.Properties.VariableNames{'Var32'} = 'R_Sense_of_Agency';
        if file == 1
            subjOutput = trialOutput;
        elseif i<=numFiles
            subjOutput = [subjOutput ; trialOutput];
        elseif i == numFiles
            subjOutput = trialOutput;
        end
        
        

        
        trial = trial+1;
        file = file+1;
    end
    
    %% SAVE EACH GROUP AS AN EXCEL FILE
%     % set headers for output data
%         
%     outputName = [outputFolder subjFolderName '.csv'];
%     writetable(subjOutput, outputName);
%     folder = folder+1;
    infoMatName = [outputFolder 'InfoMatrix.csv'];
    infoMat = [infoMat;subjOutput];
    writetable(infoMat, infoMatName);
    disp(['script is ' num2str(round((100/numFolder)*iFolder)) '% complete'])
end

