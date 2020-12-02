function  [subjSurveyDat] = fSurveyDat(biosemi,surveyData)
%% FUNCTION SET-UP
% create output cellarray
subjSurveyDat = cell(1,size(surveyData,2));
t = 1;

for iSurvey = 2:length(surveyData)
    if sum(biosemi{1} == surveyData{iSurvey,2}(1:2)) == 2
        subjSurveyDat(t,:) = surveyData(iSurvey,:);
        t=t+1;
    end
end

%% TESTIG NEW METHODS

testData = readtable('/Users/jackmoore/Desktop/allSurveyClean.csv');

 testData{14,1}
