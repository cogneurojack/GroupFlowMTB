function  [trialSData_1, trialSData_2] = fSurveyDat(fileName,sData,fDate)
%% FUNCTION SET-UP
% create output cellarray
biosemi = {fileName(4:5) fileName(6:7)};
trialName = regexp(fileName,'_','split');
trialName = trialName{2}(1:end-4);
  gotD = [0 0];
%% LOOP THROUGH SURVEY DATA FILE
for iSrvy = 1:size(sData,1)
    
    % format survey data datestamp to be same as file data datestamp
    sDate = datenum(sData{iSrvy,1});
    sDate = datevec(sDate);
    sDate = [num2str(sDate(3)) '/' num2str(sDate(2)) '/' num2str(sDate(1))];
    %% CHECK IF SAME AS TEST DATA
    if length(sData.Activity(iSrvy))== length(trialName)...
        && length(sDate) == length(fDate)
        if all(biosemi{1} ==  sData.ParticipantName{iSrvy}(1:2)) == true...  % same subjID
                && all(sData.Activity{iSrvy}==trialName)==true...             % same trial
                && all(sDate == fDate)==true                            % same day
            trialSData_1 = sData(iSrvy,:);
             gotD(1)=1;
        elseif all(biosemi{2} ==  sData.ParticipantName{iSrvy}(1:2)) == true...  % same subjID
                && all(sData.Activity{iSrvy}==trialName)==true...             % same trial
                && all(sDate == fDate)==true                            % same day
            trialSData_2 = sData(iSrvy,:);
             gotD(2)=1;
        end
    end
 end
 if gotD(1)==0, trialSData_1 = sData(1,:); end
 if gotD(2)==0, trialSData_2 = sData(1,:); end
end