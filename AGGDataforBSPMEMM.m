%AGGDataforBSPMEMM outputs a .csv file to use for BSPMEMM
%  Acoustic Analysis Guided Data for Bayesian Semiparametric Mixed Effects
%         Markov Models
%
%  This will prepare data outputted by MSA1.5 and run through 
%  Acoustic_Analysis_Guided. It will read the data that is put 
%  in the third sheet labeled "Removing the Unclassified"
%  Name information for either animals or recordings (depending on usage)
%  is taken from the fifth sheet labeled "Data" in the AF column at the far right
% 
%  This script is written for the preferred folder and file arrangement
%  Under a parent folder there are folders for each Social Contex under study
%  Possibilities are 
%     UR = urine
%     LF = life female
%     AF = anesthetized female
%     AM = anesthetized male
%  Within each context folder are the files to be processed. 
%  These files are preferrably named as follows
%     condition_genotype_*.xlsx
%     examples:
%         AF_het_recordingInfo.xlsx
%         UR_wt_1-10.xlsx
%     the genotype for the saved csv files is take from 
%     between two underscores "_"
% 
%  Change USVFolderLocation to where your context folders are
%  Change the contexts being used to the current study
%  Please follow ReadMe file for BSPMEMM for clarity on what integer 
%  identities refer to THIS IS IMPORTANT FOR Contexts ARRAY
%
%  Bayesian Semiparametric Mixed Effects Markov Models With 
%    Application to Vocalization Syntax
%  Sarkar et al., 2018, Journal of the American Statistical Association 
%  https://amstat.tandfonline.com/doi/full/10.1080/01621459.2018.1423986?scroll=top&needAccess=true#.XXVpkpNKhE4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

USVFolderLocation = '/Users/cesarvargas/Desktop/MouseExperiments/VocalRecordings/Yoko/2019.Feb_Nova1pm_usv';
Contexts = ["UR", "LF", "AF"];

for C = 1:length(Contexts) 
    USVFolder = fullfile(USVFolderLocation, Contexts(C));
    filestoOpen = dir(USVFolder);
    %first two rows of directory struct are non important
    %see https://stackoverflow.com/questions/27337514/matlab-dir-without-and
    filestoOpen([1 2],:) = []; 
    numFiles = length(filestoOpen);
    animalID = 1;
    
    for F = 1:length(filestoOpen)
        if contains(filestoOpen(F).name,'DS_Store') || ...
                contains(filestoOpen(F).name,'$')
            continue
            %for some reason sometimes invisible files of .DS_Store and
            %others starting with $ (which are temp files) are written
            %this lets the script ignore these files
        end
        disp(['Processing: ' filestoOpen(F).name])
        filetoRead = fullfile(filestoOpen(F).folder, filestoOpen(F).name);
        [syldata, namesNsyllables, raw] = xlsread(filetoRead, 3);

        namesNsyllables(1,:) = [];
        [len, wide] = size(namesNsyllables);
        namesNsyllables(:,3:wide) = [];
        %removes top row of variable names
        [~, names, ~] = xlsread(filetoRead, 4, 'AF7:AF50');
        
        %For some reason this script crashes when there's only one USV
        %One USV can't be used for BSPMEMM anyway
        if len<2
            disp(['Skipped: ' filestoOpen(F).name])
            continue
        end
        
        markovNNS = zeros(size(namesNsyllables));
        %NNS refers to names and syllables (namesNsyllables)
        currentMouse = namesNsyllables(1);
        markovNNS(1,1) = animalID;
        for n = 2:len
            if strcmp(namesNsyllables(n), namesNsyllables(n-1))
                markovNNS(n) = animalID;
            else 
                animalID = animalID+1;
                markovNNS(n) = animalID;
            end
        end
        animalID = animalID+1; %This ensures the next file starts at a new value
        clear n 

        NaNloci = zeros(len, 1);
        for i = 1:len
            A = isnan(syldata(i,3));
            if A == 1
                NaNloci(i,:) = A;
            end
        end
        NaNloci = find(NaNloci);
        clear i ans A


        % [d,m,s,u,x]=[1,2,3,4,5]
        for s = 1:len
            if strcmp(namesNsyllables(s,2), 'd')
                markovNNS(s, 2) = 1;
            elseif strcmp(namesNsyllables(s,2), 's')
                markovNNS(s, 2) = 3;
            elseif strcmp(namesNsyllables(s,2), 'u')
                markovNNS(s, 2) = 4;
            elseif strcmp(namesNsyllables(s,2), 'x')
                markovNNS(s, 2) = 5;
            else %for when the syllable is m
                markovNNS(s, 2) = 2;
            end
        end
        clear s

        %counter number of times ISI >0.2500
        numXs = 0;
        for i = 1:len
            if syldata(i,3) > 0.2500
                numXs = numXs + 1;
            end
        end
        clear i

        %Add silent X syllables to an array
        NNSwX = zeros(len+numXs, 2);
        xholder = 1;
        for z = 1:len
            NNSwX(xholder,1) = markovNNS(z,1);
            NNSwX(xholder,2) = markovNNS(z,2);
            if isnan(syldata(z,3))
                NNSwX(xholder,1) = markovNNS(z,1);
                NNSwX(xholder,2) = markovNNS(z,2);
            elseif syldata(z,3) > 0.2500 
                xholder = xholder+1;
                NNSwX(xholder,1) = markovNNS(z,1);
                NNSwX(xholder,2) = 5;
            end
            xholder = xholder + 1;
        end

        finalNNS = zeros(length(NNSwX), 5);
        for f = 1:length(NNSwX)
            finalNNS(f,1) = NNSwX(f,1);
            finalNNS(f,5) = NNSwX(f,2);
        end

        whichrec = 1;
        finalNNS(1,4) = finalNNS(1,5);
        for q = 1:length(NNSwX)
            if finalNNS(q,1) ~= whichrec
                finalNNS(q,4) = finalNNS(q,5);
                whichrec = whichrec + 1;
            end
        end
        recstartsites = find(finalNNS(:,4));


        for p = 2:setdiff(length(finalNNS), recstartsites)
            if any(p == recstartsites)
                continue
            end
                finalNNS(p,4) = finalNNS(p-1,5);
        end

        ranges = [1 2 3; 4 5 6; 7 8 9; 10 11 12; 13 14 15; 16 17 18;...
            19 20 21; 22 23 24; 25 26 27; 28 29 30; 31 32 33;];


        %Reassign animalID numbers so that three trials match one animal
        for IDrange = 1:length(ranges)
            for a = 1:length(finalNNS)
                if any(finalNNS(a) == ranges(IDrange,1:3))
                    finalNNS(a,1) = IDrange;
                end
            end
        end

        %fill genotype and context
        genotype = extractBetween(filestoOpen(F).name, "_", "_");
        if strcmp(genotype, 'het')
            finalNNS(:,2) = 1;
        elseif strcmp(genotype, 'pm')
            finalNNS(:,2) = 2;
        elseif strcmp(genotype, 'wt')
            finalNNS(:,2) = 3;
        end
        
        if strcmp(Contexts(C), 'UR')
            finalNNS(:,3) = 1;
        elseif strcmp(Contexts(C), 'LF')
            finalNNS(:,3) = 2;
        elseif strcmp(Contexts(C), 'AF')
            finalNNS(:,3) = 3;
        end

        
        savefileName = extractBefore(filestoOpen(F).name, ".");
        csvwrite(strjoin({filestoOpen(F).folder, '/', savefileName, ...
            '.csv'}, ''), finalNNS); 
        clear p q a f z 
    end
end
fprintf('Thanks for waiting! \n ')
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
uiwait(msgbox({'\fontsize{20} All done!'; ...
    '\fontsize{30} <(^\wedge.^\wedge<) ';},'Success',CreateStruct));


