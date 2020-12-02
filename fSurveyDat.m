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

%% TESTING NEW METHODS TO TRY AND ENSURE WE GET DATE INFO

testData = readtable('/Users/jackmoore/Desktop/allSurveyClean.csv');

 testData(15,1); % the datetime of the sruvey data (14 is the last rwo it works correctly for :\
 testData = datevec(testData{15,1});
 testData = [num2str(x(3)) '/' num2str(x(2)) '/' num2str(x(1))]
 
 fileDat = dataFilesInfo(1).date; % the datetime of the performance data file
 
myDateNum = datenum( fileDat);
 
y = datevec(myDateNum, 'DD/MM/YYYY')

y = [num2str(x(3)) '/' num2str(x(2)) '/' num2str(x(1))]

 testData == y