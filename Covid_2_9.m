%% GROUP FLOW - VIRTUAL SHEPHERDING
%% DATA SEGMENTING AND EVENT CLEANING
% Jack D Moore - contact: j.d.moore@gold.ac.uk

% Script will cylce go through each participant pair,
%1) locate correct triggers indicating beginning and end of each trial in subjact A
%2) add in any missing end-point triggers
%3) delete any unused trials
%4) add a end-45s trigger (as primalrily interested in last 45s when they
% either 'win', or lose, the game)
%5) locate the trigger indiciating the begnning of the first trial in subject B
%6) cut both A&B data to 1s before the the start of trial 1
%7) copy and past the triggers from subject A into subject B
%8) cut-out each trial (+&- 1s)
%9) Save both data sets as  filt_ica_trim.
clear all
close all
format shortG % This sets the format of values toprevent use of paower function (so I can see actual values)
eeglab nogui
i=1;
 for i =[1 4:length('D:\groupFlow_trialDat\')] % first 4 pairs need to be checked by hand
    %% LOAD GAME DATA
    cd('D:\groupFlow_trialDat\')
    Bx = dir('D:\groupFlow_trialDat\*.xls');
    
    % Sort data
    grpInf = readtable(Bx(i).name);
    % remove practic'e' trials
    idx = cell2mat(cellfun(@(x) contains(x,'e'), table2cell(grpInf(:,2)),'UniformOutput', false));
    grpInf(idx,:) = [];
    [~, idx] = sort(table2array(grpInf(:,3)));
    grpInf = grpInf(idx,:);
    
    %% LOAD FIRST SUBJECT EEG DATA
    % Load the correct directory
    cd('D:\groupFlow_3\ICA\');
    p3x = dir('D:\groupFlow_3\ICA\*.set');
    p = num2str(i);
    p3 = '_3';
    
    % Look through all the EEG files and indicate possible matches
    for j = 1:length(p3x)
        if contains(p3x(j).name,strcat(p,p3))
             if contains(p3x(j).name,'EC_filt')
                 %EC = Eyes Closed; i.e. the baseline measure
             else
                Bx(i).name
                p3x(j).name
                checkFile = input('Press 1 if correct file ID: '); %INPUT%
                if checkFile
                    data = p3x(j).name;
                    j = length(p3x);
                else
                end
            end
        else
        end
    end
    
    EEG = pop_loadset('filename',data,'filepath','D:\\groupFlow_3\\ICA\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
    EEG = eeg_checkset( EEG );
    % eeglab redraw
    %% 1) CREATE SPREADSHEET COMPARING IT TO STIMULUS DATA
    % Create new table that will have both the behave and EEG data in it
    trlInf = zeros(length(EEG.event),8);
    stimTrialNum = table2array(grpInf(:,3));
    stimTrialLngth = table2array(grpInf(:,4));
    
    %create a column that will indicate if a behave trial is PB or not
    idx = cell2mat(cellfun(@(x) contains(x,'PB'), table2cell(grpInf(:,2)),'UniformOutput', false));
    trlInf(idx,1)=99;
    trlInf(~idx,1)=0;
    trlInf(1:length(stimTrialNum),2:3) = [stimTrialNum stimTrialLngth];
    
    
    [[EEG.event(1:length(EEG.event)).type]; [EEG.event(1:length(EEG.event)).latency]/512]'
    trigNum = input('Check start trigger num as it appears this can change: '); %INPUT%
    
    cd('C:\Users\Jack Moore\OneDrive - Goldsmiths College\Projects\Group Flow\GroupFlowMTB');
    [trlInf] = dataInfo(trlInf, EEG, grpInf, trigNum);
    %% SAVE AS NEW FILE FOR TRIMMED EEG DATA
    filename = strcat(EEG.filename(1:end-4), '_trim');
    filepath = strcat(EEG.filepath(1:end-5), '\\Trim\\');
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    %% remove the first event as just trial start event
    EEG.event(1)=[];
    
    %% 2) ADD IN END-POINT EVENTS FOR PB TRIALS
    [[EEG.event.type]; [EEG.event.latency]/512]'
    endTrig = input('What is the end-point trigger number: '); %INPUT%
    
    idx = cell2mat({EEG.event(:).type}) == endTrig; %logical if end-point trigger
    ept_n = 0; % number of end point triggers currently reported
    for l = 1:length(idx)% for all events
        if ~idx(l) &&... % if the current event is not end-point trigger
                EEG.event(l+1).type ~= endTrig % and the next event is not end-point trigger
            
                n_events=length(EEG.event); % give no. of events a var name 
                EEG.event(n_events+1).type = endTrig; % add new event (with end-point var name)
                EEG.event(n_events+1).latency =((EEG.event(l).latency) + ...
                table2array(grpInf(l+ept_n,4))*512);  % change latency in line with end of trial no
                EEG.event(n_events+1).urevent = n_events+1;
        else 
            ept_n=ept_n+1;
        end
    end
    
    % The last trial is PB and thus neved has a end-point event
    EEG.event(n_events+2).type = endTrig;
    EEG.event(n_events+2).latency =((EEG.event(l).latency) + ...
                table2array(grpInf(end,4))*512);
    EEG.event(n_events+2).urevent = n_events+1;
    
    %% REMOVE ANY UNUSED TRIALS
    % In case there are trials which are void
    cd('C:\Users\Jack Moore\OneDrive - Goldsmiths College\Projects\Group Flow\GroupFlowMTB');
    [trlInf] = dataInfo(trlInf, EEG, grpInf, trigNum) ;
    array2table(trlInf(:,4:end),'VariableNames',...
        {'trlLength',...
        'ON_urevent',...
        'ON_type',...
        'OFF_urevent',...
        'OFF_type'})
    void = input( 'Input the urevent number of any events that will not be used, such as unused trials: '); %INPUT%
    
    idx = cell2mat(cellfun(@(x) ismember(x,void), {EEG.event.urevent},'UniformOutput', false));
    EEG.event(idx) = [];
    
    %% SAVE THE DATA-SET WITH ONLY CORRECT EVENTS
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %% RENAME THE EVENTS
    
    
    if length(EEG.event) ~= size((grpInf),1)*2
        {EEG.event.type}'
        'incorrect number of trials. Check all triggers are correct';
        pause
    else
        pause('off')
        trl = 1;
        if EEG.event(l).type == endTrig
            EEG = pop_editeventvals(EEG,'changefield',{l 'type' '999'});
        else
            % Name = Trial Number | Trial Type ((PB/~PB) | Outcome
            % (Win/Lose)
            name = [table2array(grpInf(trl,3)) trlInf(trl,1) table2array(grpInf(trl,5))];
            if trlInf(trl,1) == 99
                name(3) = trlInf(trl-1,5);
            end
            %                              name = [num2str(name(1)) num2str(name(2)) num2str(name(3))...
            %                                  num2str(name(4)) num2str(name(5)) num2str(name(6))];
            %                              name = str2num(name);
            EEG = pop_editeventvals(EEG,'changefield',{l 'type' name});
            trl=trl+1;
        end
        
        endfor l = 1:length(EEG.event)
    end
   %% ADD -45S TRIGGER
   % Get the latencies (data point indices) for all '999' type events...
   endLatencies = [EEG.event(find(strcmp(999,{EEG.event.type}))).latency];
%    
%     EEG = eeg_checkset( EEG );
%     EEG = pop_saveset( EEG, 'savemode','resave');
%     [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
   % for each end_latencies add a new event type '45s' with a latency of
   
   for l=1:length(endLatencies);
       n_events=length(EEG.event);
       EEG.event(n_events+1).type='45s';
       EEG.event(n_events+1).latency=(endLatencies(l)-45*EEG.srate)-1;
       EEG.event(n_events+1).urevent=n_events+1;
   end
   % check for consistency and reorder the events chronologically...
   EEG=eeg_checkset(EEG,'eventconsistency');
   
   
    %% SAVE THE FINALISED DATA-SET 
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
  %%  PUT DATA-SET INFO INTO TABLE FOR COMPARISON
  % put the relevant EEG data in the relevant coumns
  for j = 1:length(EEG.event)-1
      prevCheck(j,1) = EEG.event(j).urevent;
      prevCheck(j,2) = (EEG.event(j).type(1));
      prevCheck(j,3) = (EEG.event(j+1).type(1));
      prevCheck(j,4) = EEG.event(j).latency;
      prevCheck(j,5) = (EEG.event(j+1).latency - EEG.event(j).latency)/512;
  end
  
  prevCheck(:,4)= prevCheck(:,4) - prevCheck(1,4) ;
  
  %% LOAD OTHER DATA-SET
  
    cd('D:\groupFlow_1\ICA\');
    p1x = dir('D:\groupFlow_1\ICA\*.set');
    p1 = '_1';
    
       % Look through all the EEG files and indicate possible matches
    for j = 1:length(p1x)
        if contains(p1x(j).name,strcat(p,p1))
             if contains(p1x(j).name,'EC_filt')
             else
                Bx(i).name
                p1x(j).name
                checkFile = input('Press 1 if correct filD: ') %INPUT%
                if checkFile
                    data = p1x(j).name;
                    j = length(p1x);
                else
                end
            end
        else
        end
    end
    
    EEG = pop_loadset('filename',data,'filepath','D:\\groupFlow_1\\ICA\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
  %% REMOVE START OF TRIAL TRGGER
EEG.event(1)=[]
    
    %% ADD INFO TO TABLE 
  
  % put the relevant EEG data in the relevant coumns
  for j = 1:length(EEG.event)-1
      prevCheck(j,6) = EEG.event(j).urevent;
      prevCheck(j,7) = (EEG.event(j).type);
      prevCheck(j,8) = (EEG.event(j+1).type);
      prevCheck(j,9) = EEG.event(j).latency;
      prevCheck(j,10) = (EEG.event(j+1).latency - EEG.event(j).latency)/512;
  end
  
  prevCheck(:,9)= prevCheck(:,9)-prevCheck(1,9);
   
   %% SAVE AS NEW FILE FOR TRIMMED EEG DATA
    filename = strcat(EEG.filename(1:end-4), '_trim');
    filepath = strcat(EEG.filepath(1:end-5), '\\Trim\\');
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    eeglab redraw
    EEG = eeg_checkset( EEG );
    %% CUT BOTH DATA SETS TO -1 BEFORE FIRST TRIAL
    
    removeStart = [-EEG.event(1).latency/512 -1];
    EEG = pop_editeventvals(EEG,'changefield',{1 'type' 1});

    EEG = pop_rmdat( EEG, '1', removeStart ,0);
    EEG.event=[];
     
    % change from current data-est to other participants dataset
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0);


   removeStart = [-EEG.event(1).latency/512 -1];
    
   EEG = pop_rmdat( EEG, EEG.event(1).type, removeStart ,0);

  
  

 end