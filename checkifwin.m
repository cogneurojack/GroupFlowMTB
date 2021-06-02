
 for i =[1 2 4 5 7 11:14 27 28]% first 4 pairs need to be checked by hand
    %% 0) Open trialDat file
    cd('E:\DATA\groupFlow_trialDat\');
    Bx = dir('E:\DATA\groupFlow_trialDat\*.xls');
    
    % Sort data
    grpInf = readtable(Bx(i).name);
    
    
    % remove practic'e' trials
    idx = cell2mat(cellfun(@(x) contains(x,'e'), table2cell(grpInf(:,3)),'UniformOutput', false));
    grpInf(idx,:) = [];
    [~, idx] = sort(table2array(grpInf(:,4)));
    grpInf = grpInf(idx,:)
    
 end
    