%% createContrasts
%  Daniel Elbich
%  Cognitive Aging & Neuroimaging Lab
%  7/24/19

% This script creates weighted contrasts from the estimated SPM models for
% each subject separately. Relies on processing being performed by
% estimateModel script.
%
% See also:  estimateModel.m

%% User Input
% You should ONLY (!!!!!!) need to edit this highlighted section of the
% script.
% User Input Step 1: Directories

% Please specify the name of the current analysis, the directory the
% current analysis is in.
Analysis.name = 'DescriptiveProjectName';
Analysis.directory = fullfile('/path/to/analysis/output', Analysis.name);

% User Input Step 2: Subjects
% Subjects must be listed in a 1 x N cell array.
% List subject folders in analysis directory
subfolders = dir(Analysis.directory);

% Remove non-subject directories
for i=1:length(subfolders)
    subFlag(i)=~isempty(strfind(subfolders(i).name,'sub-'));
end
subfolders = subfolders(subFlag);

% Create array of subject IDs
for i=1:length(subfolders)
    subjects{i} = subfolders(i).name;
end

% User Input Step 3: Options

% Set the following jobman_option to 'interactive' to view in SPM parameters the GUI.
% Press any key into the command window to continue to next one sample t test.
% Set the following jobman option to 'run' to skip the viewing of the
% SPM parameters in the GUI and go directly to running of the one
% sample t-tests

jobman_option      = 'run'; % 'run' or 'interactive'.
cons2run           = 'all'; % [1:3 7];
deletecons         = 1;     % delete existing contrasts? 1 = yes, 0 = no

%% Setting Analysis specifics contrasts

clc
fprintf('Analysis: %s\n\n', Analysis.name)
disp('Analysis Directory:')
disp(Analysis.directory)

% Inialize Number.OfContrasts to 0
Number.OfContrasts = 0;

% Example 1
% Number.OfContrasts = Number.OfContrasts+1;
% Contrasts(Number.OfContrasts).names    = { 'Face_>_Object' };
% Contrasts(Number.OfContrasts).positive = { 'Faces' };
% Contrasts(Number.OfContrasts).negative = { 'Objects' };
%
% Example 2
% Number.OfContrasts = Number.OfContrasts+1;
% Contrasts(Number.OfContrasts).names    = { 'Face_>_Object' };
% Contrasts(Number.OfContrasts).positive = { 'MaleFaces' 'FemaleFaces'};
% Contrasts(Number.OfContrasts).negative = { 'BedObjects' 'GameObjects'};

%% Routine
% Should not need to be edited

% Set SPM Defaults
spm('defaults','FMRI')
spm_jobman('initcfg')
Count.ProblemSubjs = 0;

fprintf('\n')
fprintf('Number of Contrasts Specified: %d \n\n', length(Contrasts))

for indexS = 1:length(subjects)
    %% Build Contrast Vectors
    
    pathtoSPM = fullfile(Analysis.directory, subjects{indexS}, 'SPM.mat');
    fprintf('Building Contrast Vectors...\n\n')
    
    % Step 1: load the labels of each column of the design matrix
    SPM = [];
    load(pathtoSPM)
    Regressors.Names = SPM.xX.name;
    pos_neg = {'positive' 'negative'};
    Regressors.Estimability = spm_SpUtil('isCon',SPM.xX.X);
    
    % Step 2: Build an array that tells you how many times each TT involved in
    % the specified contrasts occurs in our design matrix. Because our TT are
    % subject behavior defined, they may not occur in each run.
    
    for indexC = 1:length(Contrasts)
        for indexPN = 1:2
            for indexQ = 1 : length(Contrasts(indexC).(pos_neg{indexPN}))
                TT_occurance{indexC}.(pos_neg{indexPN})(indexQ) = 0;
                for indexV = 1 : length(Regressors.Names)
                    if ~isempty(strfind(Regressors.Names{indexV},...
                            Contrasts(indexC).(pos_neg{indexPN}){indexQ}))...
                            && Regressors.Estimability(indexV)
                        TT_occurance{indexC}.(pos_neg{indexPN})(indexQ) = ...
                            TT_occurance{indexC}.(pos_neg{indexPN})(indexQ) + 1;
                    end
                end
            end
        end
    end
    
    % Step 3: Build contrast vectors and apply appropriate weights.
    % Contrast vectors are weighted by:
    % 1.) the number of runs that they occur in
    % 2.) by the number of included trial types in a given contrast
    
    for indexC = 1:length(Contrasts)
        Contrasts(indexC).vector = zeros(1,length(Regressors.Names));
        for indexPN = 1:2
            for indexQ = 1 : length(Contrasts(indexC).(pos_neg{indexPN}))
                for indexV = 1 : length(Regressors.Names)
                    if ~isempty(strfind(Regressors.Names{indexV},...
                            Contrasts(indexC).(pos_neg{indexPN}){indexQ}))...
                            && Regressors.Estimability(indexV)
                        
                        % Weight Contrasts
                        % Calc number of trials of interest in contrast
                        divsor=0;
                        for i = 1:length(TT_occurance{indexC}.(pos_neg{indexPN}))
                            if TT_occurance{indexC}.(pos_neg{indexPN})(i) ~= 0
                                divsor = divsor+1;
                            end
                        end
                        
                        % Calc number of trials of interest per run
                        number=0;
                        for k = 1:length(Regressors.Names)
                            if ~isempty(strfind(Regressors.Names{k},...
                                    Contrasts(indexC).(pos_neg{indexPN})...
                                    {indexQ})) && Regressors.Estimability(k)
                                number = number+1;
                            end
                        end
                        
                        % Step 3: Acutally Calculate the Weight
                        weight = 1/divsor/number;
                        
                        if indexPN == 1
                            Contrasts(indexC).vector(indexV) = round...
                                (weight,5,'significant');
                        elseif indexPN == 2
                            Contrasts(indexC).vector(indexV) = round...
                                (-weight,5,'significant');
                        end
                    end
                end
            end
        end
    end
    
    
    %% Run SPM Contrast Manager
    
    if strcmp(jobman_option,'interactive')
        fprintf('Displaying SPM Job for Subject %s ...\n\n', subjects{indexS})
    elseif strcmp(jobman_option,'run')
        fprintf('Running SPM Job for Subject %s ...\n\n', subjects{indexS})
    end
        
    if strcmp(cons2run,'all')
        k = 1:length(Contrasts);
    else
        k = cons2run;
    end
    
    matlabbatch{1}.spm.stats.con.spmmat = cellstr(pathtoSPM);
    count = 0;
    for curCon = k
        count = count + 1;
        fprintf('Contrast %d: %s\n', curCon, Contrasts(curCon).names{1})
        matlabbatch{1}.spm.stats.con.consess{count}.tcon.name    = Contrasts(curCon).names{1};
        matlabbatch{1}.spm.stats.con.consess{count}.tcon.convec  = Contrasts(curCon).vector;
        matlabbatch{1}.spm.stats.con.consess{count}.tcon.sessrep = 'none';
    end
    matlabbatch{1}.spm.stats.con.delete = deletecons;
    
    try
        spm_jobman(jobman_option, matlabbatch)
        if strcmp(jobman_option, 'interactive')
            pause
        end
    catch error
        display(subjects{indexS})
        Count.ProblemSubjs = Count.ProblemSubjs + 1;
        pause
        problem_subjects{Count.ProblemSubjs} = subjects{indexS};
    end
    
    fprintf('\n')
    clear matlabbatch;
    
end

if exist('problem_subjects','var')
    
    fprintf('There was a problem running the contrasts for these subjects:\n\n')
    disp(problem_subjects)
    
end

disp('All finished!');
