function  [subjSurveyDat] = fSurveyDat(biosemi,surveyData)
%% FUNCTION SET-UP
% create output cellarray
subjSurveyDat = cell(1,size(surveyData,2));
t = 1;

for iSurvey = 2:length(surveyData)
    
    subjID = biosemi{1} == surveyData{iSurvey,2}(1:2);
    
    if sum(subjID) == 2
        subjSurveyDat(t,:) = surveyData(iSurvey,:);
        t=t+1;
    end
end