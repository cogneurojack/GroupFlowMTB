function  [subjSData] = fSurveyDat(biosemi,sData,fDate,trialNum)
%% FUNCTION SET-UP
% create output cellarray
t = 1;
subjSData = sData(t,:);
%% LOOP THROUGH SURVEY DATA FILE
for iSrvy = 2:size(sData,1)
    
    % format survey data datestamp to be same as file data datestamp
    sDate = datevec(sData{iSrvy,1});
    sDate = [num2str(sDate(3)) '/' num2str(sDate(2)) '/' num2str(sDate(1))];
    %% CHECK IF SAME AS TEST DATA
    
    if all(biosemi{1} ==  sData.ParticipantName{iSrvy}) == true...  % same subjID
            && str2num(sData.Trial{iSrvy})==trialNum...             % same trial
            && all(sDate == fDate)==true                            % same day
        subjSData(t,:) = sData(iSrvy,:);
        t=t+1;
    end
end
end
