USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = {'UR', 'LF', 'AF'};
mkdir(USVFolderLocation, 'RenumAllMergedCSVs')
for C = 1:length(Contexts)
    USVFolder = fullfile(USVFolderLocation, Contexts{C});
    cd(USVFolder);
    filestoOpen = dir('*___*.csv');
    %first two rows of directory struct are non important
    %see https://stackoverflow.com/questions/27337514/matlab-dir-without-and
    for d = 1:length(filestoOpen)
        if contains(filestoOpen(d).name,'$')
            filestoOpen(d) = [];
            %for some reason sometimes invisible files that 
            %start with $ (which are temp files) are written
            %this lets the script ignore these files
        end
    end
    numFiles = length(filestoOpen);
    
    mergedFiles = cell(length(filestoOpen),1);
    for F = 1:length(filestoOpen)
        if contains(filestoOpen(F).name,'het') || ...
                contains(filestoOpen(F).name,'pm') ||...
                contains(filestoOpen(F).name,'wt')
            Data = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = Data ;
        end
    end
    mergedFiles = cell2mat(mergedFiles) ;
    
    %clean up for BSPMEMM format
    %Currently (September, 2019), BSPMEMM can ONLY take two genotypes and
    %must be coded as 1 or 2
%     for i = 1:length(mergedFiles)
%         
%     end
    
    
    disp(['Saving: ' strjoin({Contexts{C}, '-wt-het-pm___renum','.csv'}, '')]);
    savemergedPath = fullfile(USVFolderLocation, 'RenumAllMergedCSVs');
    csvwrite(strjoin({savemergedPath, '/', Contexts{C}, ...
        '-wt-het-pm___renum','.csv'}, ''), mergedFiles);
    
    clear d 
end
cd(fullfile(USVFolderLocation, 'RenumMergedCSVs'));
%% 

USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = {'UR', 'LF', 'AF'};
USVFolder = fullfile(USVFolderLocation, 'RenumAllMergedCSVs');
cd(USVFolder);
filestoOpen = dir('*-*-*___*.csv');
%first two rows of directory struct are non important
%see https://stackoverflow.com/questions/27337514/matlab-dir-without-and
for d = 1:length(filestoOpen)
    if contains(filestoOpen(d).name,'$')
        filestoOpen(d) = [];
        %for some reason sometimes invisible files that 
        %start with $ (which are temp files) are written
        %this lets the script ignore these files
    end
end
numFiles = length(filestoOpen);

mergedFiles = cell(length(filestoOpen),1);
for F = 1:length(filestoOpen)
    if contains(filestoOpen(F).name,'UR') || contains(filestoOpen(F).name,'LF')...
            || contains(filestoOpen(F).name,'AF')
        if contains(filestoOpen(F).name,'wt-het-pm')
            Data = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = Data ;
        end
    end
end
mergedFiles = cell2mat(mergedFiles) ;



mergedFiles = sortrows(mergedFiles,3);
mergedFiles = sortrows(mergedFiles,2);

disp(['Saving: ' strjoin({'URLFAF', '_wthetpmtest_renum','.csv'}, '')]);
savemergedPath = fullfile(USVFolderLocation, 'RenumAllMergedCSVs');
csvwrite(strjoin({savemergedPath, '/', 'URLFAF', ...
    '_wthetpmtest_renum','.csv'}, ''), mergedFiles);

clear d 