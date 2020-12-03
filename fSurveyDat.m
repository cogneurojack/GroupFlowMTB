function  [trialSData] = fSurveyDat(fileName,sData,fDate)
%% FUNCTION SET-UP
% create output cellarray
biosemi = {fileName(1:2) fileName(3:4)};
trialName = regexp(fileName,'_','split');
trialName = trialName{2}(1:end-4);


%% LOOP THROUGH SURVEY DATA FILE
for iSrvy = 1:size(sData,1)
    
    % format survey data datestamp to be same as file data datestamp
    sDate = datevec(sData{iSrvy,1},'DD/MM/YYYY');
    sDate = [num2str(sDate(3)) '/' num2str(sDate(2)) '/' num2str(sDate(1))];
    %% CHECK IF SAME AS TEST DATA
    if length(sData.Activity{iSrvy})== length(trialName)
        if all(biosemi{1} ==  sData.ParticipantName{iSrvy}(1:2)) == true...  % same subjID
                && all(sData.Activity{iSrvy}==trialName)==true...             % same trial
                && all(sDate == fDate)==true                            % same day
            trialSData = sData(iSrvy,:);
        end
    end
end
end