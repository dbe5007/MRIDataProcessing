%% CONN Batch Processing
%  Daniel Elbich
%  6/19/19
%
%  This script is designed to create a batch file containg all subjects to
%  be used with CONN toolbox (https://web.conn-toolbox.org/). It is setup
%  to work with BIDS-style structure and fmriprep processing. Subject
%  specific anatomical and functional data are converted from gunzip format
%  to work with SPM and added to the batch file. The final file is saved at
%  the project directory level.
%

%% Setup data paths

% Script for batch processing data through conn toolbox.
projectDir='/path/to/project/directory';
processedData=[projectDir 'processed/fmriprep/directory'];

funcFolders=dir(processedData);

% Remove non-subject directories
for i=1:length(funcFolders)
    subFlag(i)=~isempty(strfind(funcFolders(i).name,'sub-'));
end
funcFolders = funcFolders(subFlag);

% Remove potential files in subject directories
dirFlags = [funcFolders.isdir];
subfolders = funcFolders(dirFlags);

% Task name
task = 'face';

% Space
space = 'MNI152NLin2009cAsym';

clear funcFolders dirFlags subFlag;

%% Main Code

for i=1:length(subfolders)
    
    % Gunzip subject anatomical and functional data
    subj.anat = [processedData '/' subfolders(i).name '/anat/' subfolders(i).name...
        '_space-' space '_desc-preproc_T1w.nii'];
    
    subj.GM = [processedData '/' subfolders(i).name '/anat/' subfolders(i).name...
        '_space-' space '_label-GM_probseg.nii'];
    
    subj.WM = [processedData '/' subfolders(i).name '/anat/' subfolders(i).name...
        '_space-' space '_label-WM_probseg.nii'];
    
    subj.CSF = [processedData '/' subfolders(i).name '/anat/' subfolders(i).name...
        '_space-' space '_label-CSF_probseg.nii'];
    
    subj.func = [processedData '/' subfolders(i).name '/func/' ...
        subfolders(i).name '_task-' task '_space-' space '_desc-preproc_bold.nii'];
    
    try
        
        setenv('anat',[subj.anat '.gz']);
        setenv('GM',[subj.GM '.gz']);
        setenv('WM',[subj.WM '.gz']);
        setenv('CSF',[subj.CSF '.gz']);
        setenv('func',[subj.func '.gz']);
        
        if ~isfile(subj.anat)
            !gunzip $anat
        end
        if ~isfile(subj.GM)
            !gunzip $GM
        end
        if ~isfile(subj.WM)
            !gunzip $WM
        end
        if ~isfile(subj.CSF)
            !gunzip $CSF
        end
        if ~isfile(subj.func)
            !gunzip $func
        end
        
    catch
        error(['Data for ' subfolders(i).name ...
            ' failed to unzip. Set to debug mode.']);
    end
    
    % Split fmriprep covariates into separate files for CONN
    covariates=tdfread([processedData '/' subfolders(i).name '/func/' ...
        subfolders(i).name '_task-' task '_desc-confounds_regressors.tsv']);
    
    try
        % Create dvars covariate file
        if ~isfile([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_dvars_covariate.txt'])
            
            fileID = fopen([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_dvars_covariate.txt'],'w');
            
            for ii=1:length(covariates.dvars)
                if ii==1
                    dvars(ii)=0;
                else
                    dvars(ii)=str2double(covariates.dvars(ii,:));
                end
            end
            
            fprintf(fileID,'%f\n',dvars);
            fclose(fileID);
            
        end
        
        if ~isfile([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_fwd_covariate.txt'])
            
            fileID = fopen([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_fwd_covariate.txt'],'w');
            
            for ii=1:length(covariates.framewise_displacement)
                if ii==1
                    framewise(ii)=0;
                else
                    framewise(ii)=str2double...
                        (covariates.framewise_displacement(ii,:));
                end
            end
            
            fprintf(fileID,'%f\n',framewise);
            fclose(fileID);
        end
        
        if ~isfile([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_motion_covariate.txt'])
            
            fileID = fopen([processedData '/' subfolders(i).name '/func/' ...
                subfolders(i).name '_task-' task '_motion_covariate.txt'],'w');
            
            motionMatrix = [covariates.trans_x,covariates.trans_y,...
                covariates.trans_z,covariates.rot_x,covariates.rot_y,...
                covariates.rot_z];
            
            for a = 1:size(motionMatrix,1)
                fprintf(fileID,'%g\t',motionMatrix(a,:));
                fprintf(fileID,'\n');
            end
            fclose(fileID);
            
        end
        
    catch
        error(['Unable to load or create covariate files for ' ...
            subfolders(i).name '!']);
        
    end
    
    % Set paths in final BATCH file
    
    % functional
    BATCH.Setup.functionals{i} = subj.func;
    
    % structural
    BATCH.Setup.structurals{i} = subj.anat;
    
    % Grey Matter Mask
    BATCH.Setup.masks.Grey.files{i} = subj.GM;
    
    % White Matter Mask
    BATCH.Setup.masks.White.files{i} = subj.WM;
    
    % CSF Mask
    BATCH.Setup.masks.CSF.files{i} = subj.CSF;
    
    % Covariates/Motion
    BATCH.Setup.covariates.names={'motion' 'dvars' 'fwd'};
    
    BATCH.Setup.covariates.files{1}{i}{1} = [processedData '/' ...
        subfolders(i).name '/func/' subfolders(i).name '_task-' task...
        '_motion_covariate.txt'];
    
    BATCH.Setup.covariates.files{2}{i}{1} = [processedData '/' ...
        subfolders(i).name '/func/' subfolders(i).name '_task-' task...
        '_dvars_covariate.txt'];
    
    BATCH.Setup.covariates.files{3}{i}{1} = [processedData '/' ...
        subfolders(i).name '/func/' subfolders(i).name '_task-' task...
        '_fwd_covariate.txt'];
    
    clear subj covariates dvars framewise motionMatrix;
    
end

%% Save & run BATCH

save([projectDir 'conn_' task '.mat'],'BATCH');
