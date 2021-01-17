
    function [trlInf ] = dataInfo(trlInf, EEG, grpInf, trigNum)
    trlNum = 1;
    t = trigNum;
    
    % put the relevant EEG data in the relevant columns
    for i = 1:length(EEG.event)
        %     Only include the start trial triggers
        p3x = num2str(EEG.event(i).type);
        y = num2str(t);
        if contains(p3x,y)
            if i < length(EEG.event)
            trlInf(trlNum,4) = (EEG.event(i+1).latency-EEG.event(i).latency)/512;
            trlInf(trlNum,5) = EEG.event(i).urevent;
            trlInf(trlNum,6) = (EEG.event(i).type);
            trlInf(trlNum,7) = EEG.event(i+1).urevent;
            trlInf(trlNum,8) = (EEG.event(i+1).type);
            else % copy info for the penultimate trial for last trial
            trlInf(trlNum,4) = (EEG.event(i-1).latency-EEG.event(i-2).latency)/512;
            trlInf(trlNum,5) = EEG.event(i).urevent;
            trlInf(trlNum,6) = (EEG.event(i).type);
            trlInf(trlNum,7) = EEG.event(i-1).urevent;
            trlInf(trlNum,8) = (EEG.event(i-1).type);
             end
%             if trlNum == 1 % Appears that event num adds 2 for first trial
%                 t=t+2;
%                 trlNum = trlNum+1;
%             else
                trlNum = trlNum+1;
                t=t+1;
            %end
        end
    end
    
    i=1;
    while i < length(trlInf)
        if trlInf(i,:)==0
            trlInf(i:end,:)=[];
        end
        i=i+1;
    end
    
    
    % Check how many trials we are expecting to have to help  trial rejection
    % later on.
    size((grpInf),1)
    end