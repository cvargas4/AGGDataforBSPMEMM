USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = {'UR', 'LF', 'AF'};
mkdir(USVFolderLocation, 'MergedCSVs')
for C = 1:length(Contexts)
    USVFolder = fullfile(USVFolderLocation, Contexts{C});
    cd(USVFolder);
    filestoOpen = dir('*_*.csv');
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
        if contains(filestoOpen(F).name,'pm') || contains(filestoOpen(F).name,'wt')
            currentFile = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = currentFile ;
        end
    end
    mergedFiles = cell2mat(mergedFiles) ;
    
    %clean up for BSPMEMM format
    %Currently (September, 2019), BSPMEMM can ONLY take two genotypes and
    %must be coded as 1 or 2
    for i = 1:length(mergedFiles)
        
    end
    
    
    disp(['Saving: ' strjoin({Contexts{C}, '-pm-wt','.csv'}, '')]);
    savemergedPath = fullfile(USVFolderLocation, 'MergedCSVs');
    csvwrite(strjoin({savemergedPath, '/', Contexts{C}, ...
        '-pm-wt','.csv'}, ''), mergedFiles);
    
    clear d 
end

%% Merge the merges

USVFolder = fullfile(USVFolderLocation, 'MergedCSVs');
cd(USVFolder);
filestoOpen = dir('*-*.csv');
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
        if contains(filestoOpen(F).name,'pm') || contains(filestoOpen(F).name,'wt')
            currentFile = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = currentFile ;
        end
    end
end
mergedFiles = cell2mat(mergedFiles) ;

%clean up for BSPMEMM format
%Currently (September, 2019), BSPMEMM can ONLY take two genotypes and
%must be coded as 1 or 2
for i = 1:length(mergedFiles)

end

mergedFiles = sortrows(mergedFiles,3);

disp(['Saving: ' strjoin({'URLFAF', '_pmwt','.csv'}, '')]);
savemergedPath = fullfile(USVFolderLocation, 'MergedCSVs');
csvwrite(strjoin({savemergedPath, '/', 'URLFAF', ...
    '_pmwt','.csv'}, ''), mergedFiles);

clear d 
