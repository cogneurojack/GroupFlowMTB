%% LOAD THE SURVEY DATA
% THIS WILL NOT BE NEEDED ONCE ADE INTO A FUNCTION
[num, text, surveyData]= xlsread('/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Group Flow/Data/allSurveyClean.xlsx');

biosemi = {subjFolderName(1:2) subjFolderName(3:4)};

subjSurveyDat = cell(1,size(surveyData,2));
t = 1;

for iSurvey = 2:length(surveyData)
    
    subjID = biosemi{1} == surveyData{iSurvey,2};
    
    if sum(subjID) == 2
        subjSurveyDat(t,:) = surveyData(iSurvey,:);
        t=t+1;
    end
end