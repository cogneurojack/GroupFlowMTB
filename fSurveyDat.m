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

surveyData = readtable('/Users/jackmoore/Desktop/allSurveyClean.csv');

% will have to look call this within the function
sDate = datevec(surveyData{iSurvey,1});
sDate = [num2str(sDate(3)) '/' num2str(sDate(2)) '/' num2str(sDate(1))];

% can call this for each subj pair
fileDate = dataFilesInfo(1).date; % the datetime of the performance data file
fDate = datenum(fileDate);
fDate = datevec(fDate, 'DD/MM/YYYY');
fDate = [num2str(x(3)) '/' num2str(x(2)) '/' num2str(x(1))];

sDate == fDate