%% %% GROUP FLOW - VIRTUAL SHEPHERDING
%% DATA SEGMENTING AND EVENT CLEANING
% Jack D Moore - contact: j.d.moore@gold.ac.uk

% Script will cycle go through each participant pair,
%0) Open trialDat file
%0.1) open Biosemi 3 subject data
%1.1) save as new file in _trim directory
%1) locate correct triggers indicating beginning and end of each trial in Biosemi 3
%2) Remove start trigger
%3) Add in any missing end-point triggers
%4) Delete any unused trials 
%5) Rename start triggers
%6) Add -45 triggers
%8) Cut new file to -1 berfore trial 1
%9) Copy all triggers (type and latency) to spreadsheet)
%10) Open Biosemi 1 for that pair
%10.1) save as new file
%11) locate the trigger indiciating the begnning of the first trial in subject B
%12) cut to -1s before that trigger
%13) Save both data sets as  filt_ica_trim.
%14) copy and past the triggers from subject A into subject B
%15) cut-out each trial for both stubjects  and save to subject folder (+&- 1s)

clear all
close all
format shortG % This sets the format of values toprevent use of power function (so I can see actual values)
eeglab nogui

 for i =1 % repeating for subjects that had file saved over
    %% 0) Open trialDat file
    cd('E:\DATA\groupFlow_trialDat\');
    Bx = dir('E:\DATA\groupFlow_trialDat\*.xls');
    
    % Sort data
    grpInf = readtable(Bx(i).name);
    
    % create folder for each subject & subject pair
    foldername = ['E:\\DATA\\clean EEG data\\' (Bx(i).name(4:7))];
    mkdir(foldername);
    
    % remove practic'e' trials
    idx = cell2mat(cellfun(@(x) contains(x,'e'), table2cell(grpInf(:,3)),'UniformOutput', false));
    grpInf(idx,:) = [];
    [~, idx] = sort(table2array(grpInf(:,4)));
    grpInf = grpInf(idx,:);
    
   %% 0.1) open Biosemi 3 subject data
   % Load the correct directory
   cd('E:\DATA\groupFlow_3\ICA\');
   p3x = dir('E:\DATA\groupFlow_3\ICA\*.set');
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
        end
    end
    
    % Create a folder for that subject
    subj3Folder = ([foldername '\\' data(6:7)]);
    mkdir(subj3Folder);
    
    % load their EEG data
    EEG = pop_loadset('filename',data,'filepath','E:\\DATA\\groupFlow_3\\ICA\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
    EEG = eeg_checkset( EEG );
    
    
    %% 1) locate correct triggers indicating beginning and end of each trial in Biosemi 3
    
    % Create new table that will have both the behave and EEG data in it
    trlInf = zeros(length(EEG.event),9);
    stimTrialNum = table2array(grpInf(:,4));
    stimTrialLngth = table2array(grpInf(:,5));
    
    %create a column that will indicate if a behave trial is PB or not
    idx = cell2mat(cellfun(@(x) contains(x,'PB'), table2cell(grpInf(:,3)),'UniformOutput', false));
    trlInf(idx,1)=99;
    trlInf(~idx,1)=0;
    trlInf(1:length(stimTrialNum),2:3) = [stimTrialNum stimTrialLngth];
    
    % locate trigger for trial 1
    [[EEG.event(1:5).type]; [EEG.event(1:5).latency]/512]'
    trigNum = input('Check start trigger num as it appears this can change: '); %INPUT%
    
    % add tor comparison table for use later
    cd('C:\Users\Jack Moore\OneDrive - Goldsmiths College\Projects\Group Flow\GroupFlowMTB');
    [trlInf] = dataInfo(trlInf, EEG, grpInf, trigNum);
    
%% 1.1) save as new file in _trim directory
    filename = strcat(EEG.filename(1:end-4), '_trim');
    filepath = strcat(EEG.filepath(1:end-5), '\\Trim\\');
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    
%% 2) Remove start trigger
%    remove the first event as just trial start event
    EEG.event(1)=[];
    
    EEG = eeg_checkset( EEG );
%% 4) delete any unused trials

    % output a table showing the time between each trial
    cd('C:\Users\Jack Moore\OneDrive - Goldsmiths College\Projects\Group Flow\GroupFlowMTB');
    [trlInf] = dataInfo(trlInf, EEG, grpInf(:,3), trigNum) ;
    array2table(trlInf ,'VariableNames',...
        {'if PB'...
        ['StimComp urevent']...
        'Approx trlLength'...
        'trlLength',...
        'ON_urevent',...
        'ON_type',...
        'OFF_urevent',...
        'OFF_type',...      
        '+-45s'})
    
    void = input( ['Input the urevent number of any events that will not be used, such as unused trials' newline...
        'use the stimComp urevent to seee if there were any trials that were restarted, then compare with ON_urevents: '] ); %INPUT%
    
    % Delete any unused trials
    idx = cell2mat(cellfun(@(x) ismember(x,void), {EEG.event.urevent},'UniformOutput', false));
    EEG.event(idx) = [];

    % re-save the file
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, CURRENTSET );
    EEG = eeg_checkset( EEG );

    %% 3) add in any missing end-point triggers
    % Determine the 'type' for end point triggers    
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
                 ((EEG.event(l-1).latency) -(EEG.event(l-2).latency)));  % change latency in line with end of trial no
                 EEG.event(n_events+1).urevent = n_events+1; 
        else 
            ept_n=ept_n+1;
        end
    end
    
    EEG=eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset( EEG );
    
    % If last trial does not have end point trigger
    if EEG.event(end).type~=endTrig
    EEG.event(n_events+2).type = endTrig;
    EEG.event(n_events+2).latency =((EEG.event(l).latency) + ...
    ((EEG.event(l-1).latency) -(EEG.event(l-2).latency)));
    EEG.event(n_events+2).urevent = n_events+1;
    end
    % Re-save file with only correct events
    if length(EEG.event) ~= size((grpInf),1)*2
        {EEG.event.type}'
        'incorrect number of trials. Check all triggers are correct'
        pause
    end
    % check for consistency and reorder the events chronologically...
    EEG=eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% 5) Rename start and end triggers

    idx = ismember([EEG.event.type],endTrig);
    trl=1;
    for l = 1:length(EEG.event)
        if idx(l)==0
        EEG.event(l).type = num2str([ (trl) trlInf(trl,1) table2array(grpInf(trl,5))]);
        
        trl=trl+1;
        else 
        EEG.event(l).type = '999';
        end
    end

%% 6) Add -45 triggers
%    % Get the latencies (data point indices) for all '999' type events...
%    for j = 1:size(EEG.event,2),EEG.event(j).type=num2str(EEG.event(j).type);end
%    endLatencies = [EEG.event(find(strcmp('999',{EEG.event.type}))).latency];
   
   % Go through file and add -45s triggers
   for l=2:2:length(EEG.event)
       %But only if the file >= 45 secs
       if (EEG.event(l).latency - EEG.event(l-1).latency)/512 >=45
       n_events=length(EEG.event);
       EEG.event(n_events+1).type='45';
       EEG.event(n_events+1).latency=(EEG.event(l).latency-(45*EEG.srate));
       EEG.event(n_events+1).urevent=n_events+1;
       
       % record if trial is +- 45s
       trlInf(l/2,9) = 1;
       else
       trlInf(l/2,9) = 0;
       end
       
   end
   
   % check for consistency and reorder the events chronologically...
   EEG=eeg_checkset(EEG,'eventconsistency');
   
   % Re-save the dataset
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% 8) Cut file to -1 berfore trial 1

    EEG = eeg_checkset( EEG );
    EEG = pop_rmdat( EEG, {EEG.event(1).type}, [-1 EEG.pnts/512],0 );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
    %remove start trigger boundary
    EEG.event(1) = [];
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% 9) Copy  triggers (type and latency) to spreadsheet)

 trigCheck = [];
 for trig_l =1:5
trigCheck(trig_l,1) = str2num(EEG.event(trig_l).type(1));
trigCheck(trig_l,2) = [EEG.event(trig_l).latency]/512;
 end
 'Check trigger are correct'
 trigCheck
 pause
 
 b3_trig = EEG.event;
 
%% 10) Open Biosemi 1 for that pair
    % Load the correct directory
    cd('E:\DATA\groupFlow_1\ICA\');
    p1x = dir('E:\DATA\groupFlow_1\ICA\*.set');
    p = num2str(i);
    p1 = '_1';
    
    % Look through all the EEG files and indicate possible matches
    for j = 1:length(p1x)
        if contains(p1x(j).name,strcat(p,p1))
             if contains(p1x(j).name,'EC_filt')
                 %EC = Eyes Closed; i.e. the baseline measure
             else
                Bx(i).name
                p1x(j).name
                checkFile = input('Press 1 if correct file ID: '); %INPUT%
                if checkFile
                    data = p1x(j).name;
                    j = length(p1x);
                else
                end
            end
        else
        end
    end
    
    % make folder for that subject
    subj1Folder = ([foldername '\\' data(6:7)]);
    mkdir(subj1Folder);
    
    % open the dataset
    EEG = pop_loadset('filename',data,'filepath','E:\\DATA\\groupFlow_1\\ICA\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
    EEG = eeg_checkset( EEG );
    

%% 10.1) save as new file

    filename = strcat(EEG.filename(1:end-4), '_trim');
    filepath = strcat(EEG.filepath(1:end-5), '\\Trim\\');
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
%% 11) locate the trigger indicating the beginning of the first trial in subject B

    trigCheck = [trigCheck [EEG.event(1:5).latency]'/512 [EEG.event(1:5).type]'];
    [grpInf(1:5,3:4)...
        array2table(trigCheck,'VariableNames',...
        {'B3 trigger',...
        'B3 latency',...
        'B1 latency',...
        'B1 trigger'})]
    strt_trgr = input('which trigger number (i.e. 1st, 2nd, 3rd trigger etc) indicates the beginning of the first trial?');
    EEG.event([1:strt_trgr-1 strt_trgr+1:end])=[];
    
%% 12) cut to -1s before that trigger
    EEG = eeg_checkset( EEG );
    EEG = pop_rmdat( EEG, {num2str(EEG.event.type)}, [-1 EEG.pnts/512],0 );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'overwrite','on','gui','off'); 
    EEG.event(1) = [];
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
%% 14) copy and past the triggers from subject A into subject B
    
    % cycle through all triggers from Biosemi 3 and add to Biosemi 1
    b3_trig;
    for b1_trgr=1:length(b3_trig)
        EEG.event(b1_trgr).type = b3_trig(b1_trgr).type;
        EEG.event(b1_trgr).latency = b3_trig(b1_trgr).latency;
        EEG.event(b1_trgr).urevent = EEG.event(end).urevent+1;
    end
    
   % Re-save the dataset
    EEG = eeg_checkset( EEG );
    EEG = pop_rmdat( EEG, {1}, [-1 EEG.pnts/512],0 ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'overwrite','on','gui','off'); 
    if cell2mat({EEG.event(1).type(1)}) == 'b',  EEG.event(1) = []; end
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% 15) cut-out each trial for both stubjects  and save to subject folder (+&- 1s)
    
    % conduct segmentsing on Biosemi 3 first, so call the specific variable
    % outside the for loop. Biosemi 1 info is caled after the main loop so
    % will be ready for the second iteration.
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0);
    dir_trl = [subj3Folder '\\'];
    for eachSubj = 1:2
        % Ensure looking at correct data set
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',eachSubj*2,'study',0);
        
        % trigger number
        trigNum=1;
        for epoch = 1:size(grpInf,1)
            % check if +<45s
            if trlInf(epoch,9)==1, if45 = 2; else; if45 = 1; end 
            epoch_trial = [(EEG.event(trigNum+if45).latency-EEG.event(trigNum).latency)/512+1]; % get the time of the trial
     
            % create file name
            filename_trl = [EEG.filename(1:end-4) '_t' num2str(epoch) '.set'];
            
            % cut our trials
            EEG = eeg_checkset( EEG );
            EEG = pop_rmdat( EEG, {EEG.event(trigNum).type}, [-1 epoch_trial],0 ); %cut our trials
            
            % save file
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, eachSubj*2,'savenew',[dir_trl filename_trl],'gui','off'); %save trial
            if cell2mat({EEG.event(1).type(1)}) == 'b',  EEG.event(1) = []; end
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG, 'savemode','resave');
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            ALLEEG(5)=[];
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'retrieve',eachSubj*2,'study',0);
            trigNum = trigNum+if45+1
        end
        

        dir_trl = [subj1Folder '\\'];
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',4,'study',0);
        end
    
    % clear all EEG file  in preperation for the next pair
    ALLEEG = [];

 end