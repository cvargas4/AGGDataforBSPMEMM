% Run the top section first to get all your genotype pairs merged together
% for each context
% THEN - if you need to renumber - run second section
% Otherwise will be done best by just running first and third sections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = {'UR', 'LF', 'AF'};
mkdir(USVFolderLocation, 'NewGtypeRenumMergedCSVs')
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
        if contains(filestoOpen(F).name,'het') || contains(filestoOpen(F).name,'pm')
            Data = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = Data ;
        end
    end
    mergedFiles = cell2mat(mergedFiles) ;
    
    
    disp(['Saving: ' strjoin({Contexts{C}, '-het-pm-ng___norenum','.csv'}, '')]);
    savemergedPath = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
    csvwrite(strjoin({savemergedPath, '/', Contexts{C}, ...
        '-het-pm-ng___norenum','.csv'}, ''), mergedFiles);
    
    clear d 
end
cd(fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs'));
%% renumber contexts if needed
    %clean up for BSPMEMM format
    %Currently (September, 2019), BSPMEMM can ONLY take two genotypes and
    %must be coded as 1 or 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
% Contexts = {'UR', 'LF', 'AF'};
% USVFolder = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
% cd(USVFolder);
% filestoOpen = dir('*-*___*.csv');
% %first two rows of directory struct are non important
% %see https://stackoverflow.com/questions/27337514/matlab-dir-without-and
% for d = 1:length(filestoOpen)
%     if contains(filestoOpen(d).name,'$')
%         filestoOpen(d) = [];
%         %for some reason sometimes invisible files that 
%         %start with $ (which are temp files) are written
%         %this lets the script ignore these files
%     end
% end
% gtype1 = 'het';
% %het 1-10
% gtype2 = 'pm';
% %pm 11-17
% gtype3 = 'wt';
% %wt 18-23
% 
% for F = 1:length(filestoOpen)
%     currentFile = filestoOpen(F).name;
%     Data = csvread(currentFile);
%     MouseID = zeros(length(Data), 1);
%     if contains(currentFile,'het-pm')
%         for i = 1:length(Data)
%             if Data(i,2) == 2
%                 Data(i,2) = 1;
%             elseif Data(i,2) == 3
%                 Data(i,2) = 2;
%             end
%         end
%         disp(['Saving: ', currentFile]);
%         savemergedPath = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
%         csvwrite(strjoin({savemergedPath, '/', currentFile}, ''), Data);
%     elseif contains(currentFile,'wt-pm')
%         for j = 1:length(Data)
%             if Data(j,2) == 3
%                 Data(j,2) = 2;
%             end
%         end
%         disp(['Saving: ', currentFile]);
%         savemergedPath = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
%         csvwrite(strjoin({savemergedPath, '/', currentFile}, ''), Data);
%     else
%         continue
%     end
% end

%% Merge the merges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = {'UR', 'LF', 'AF'};
USVFolder = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
cd(USVFolder);
filestoOpen = dir('*-*___*.csv');
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
        if contains(filestoOpen(F).name,'wt-het')
            Data = csvread(filestoOpen(F).name) ;
            mergedFiles{F} = Data ;
        end
    end
end
mergedFiles = cell2mat(mergedFiles) ;



mergedFiles = sortrows(mergedFiles,3);
mergedFiles = sortrows(mergedFiles,2);

disp(['Saving: ' strjoin({'URLFAF', '_wthettest','.csv'}, '')]);
savemergedPath = fullfile(USVFolderLocation, 'NewGtypeRenumMergedCSVs');
csvwrite(strjoin({savemergedPath, '/', 'URLFAF', ...
    '_wthettest','.csv'}, ''), mergedFiles);

clear d 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n All Merged! Thanks for waiting!')
