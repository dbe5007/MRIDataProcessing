%% Preprocess Functional Data
%  Daniel Elbich
%  Cognitive Aging & Neuroimaging Lab
%  7/24/19

% This script is designed to batch multiple subjects through a preprocessing
% pipeline designed to collect ALL AVAIABLE FUNCTIONAL RUNS USING WILDCARDS,
% and PREPROCESSING THEM ALLTOGETHER. Function scans are realigned to the
% first image of each run, respectively.
%
% This file structure is setup for BIDS compliant organization. It does not
% require that file names be in precise BIDS formatting, but does assume
% separate anat & func directories, and all subject names begin with
% 'sub-'. If this is not the case for your data, consider using this file
% structure or edit 'User Input Step 1' to fit your setup.
%
% In additon, this script will create & copy data to a separate folder for
% preprocessing. This is performed to protect integrity of raw data and
% prevent overwriting.
%

%% User Input

% User Input Step 1: The subjects array
% List the subjects to preprocess in a cell array
dataDir='/path/to/subject/directories';
processDir='/path/to/preprocessing/output/directory';
setenv('dataDir',dataDir);
setenv('processDir',processDir);
funcFolders=dir(dataDir);

% Remove non-subject directories
for i=1:length(funcFolders)
    subFlag(i)=~isempty(strfind(funcFolders(i).name,'sub-'));
end
funcFolders = funcFolders(subFlag);

% Remove potential files in subject directories
dirFlags = [funcFolders.isdir];
subfolders = funcFolders(dirFlags);

for i=1:length(subfolders)
    subjects{i}=subfolders(i).name;
end

% User Input Step 2: The Flag
% Set the flag to 1 to look at the parameters interactively in the GUI
% and 2 to actually run the parameters through SPM 12directories
flag = 2;

% User Input 3: Wildcards
% Please specify a regular expression (google regular expressions) that
% will select only the the raw image functional series and the raw
% anatomical image respectively.

wildcards.func = '^*bold.nii';
wildcards.anat = '^*T1w.nii';
wildcards.runs = 'run.*';

% User Input 4: Directories
% Please secify the paths to the directories that hold the functional
% images and anatomic images respectively

directories.func    = processDir;
directories.anat    = processDir;
directories.psfiles = [processDir '/psfiles'];
!mkdir -p $processDir/psfiles;

%% Routine

spm('defaults', 'FMRI'); % load SPM default options
spm_jobman('initcfg')    % Configure the SPM job manger

for csub = subjects % for each subject...
    
    % Copy data from raw BIDS dir
    
    setenv('subject',csub{1,1});
    % Copy & unzip single T1
    !mkdir -p $processDir/$subject/anat
    !cp $dataDir/$subject/anat/sub* $processDir/$subject/anat
    !gunzip $processDir/$subject/anat/sub*
    
    % Copy & unzip all functional runs
    !mkdir -p $processDir/$subject/func
    !cp $dataDir/$subject/func/*nii.gz $processDir/$subject/func
    !gunzip $processDir/$subject/func/sub*
    
    % Create separate directories for each run - set for 4 runs, each a
    % 4D nifti image - change as needed
    !mkdir -p $processDir/$subject/func/{run1,run2,run3,run4}
    !mv $processDir/$subject/func/*run-1* $processDir/$subject/func/run1
    !mv $processDir/$subject/func/*run-2* $processDir/$subject/func/run2
    !mv $processDir/$subject/func/*run-3* $processDir/$subject/func/run3
    !mv $processDir/$subject/func/*run-4* $processDir/$subject/func/run4
    
    % Create the path to this subjects' functional folder
    subjectFuncFolder = fullfile(directories.func, csub{:}, 'func');
    
    % Select run folders
    runs = cellstr(spm_select...
        ('FPList', subject_funcfolder, 'dir', wildcards.runs));
    
    
    %% Defining Session Parameters
    
    % Tag each file of 4D nifti images for each run
    for crun = 1:length(runs)
        
        crun_folder  = runs{crun}; % path to the current run folder
        images.raw{crun} = cellstr(spm_select...
            ('ExtFPList', crun_folder, wildcards.func, Inf)); % collect paths to ALL .nii images in this folder
        
    end
    
    % Set number of preprocessing parameters
    params = 7;
    matlabbatch=cell(1,7);
    
    for i=1:params
        switch i
            case 1
                % Run Independent Realightment Parameters
                matlabbatch{i}.spm.spatial.realign.estwrite.data = images.raw; % Paths to all images to realign for this run
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.rtm     = 1; % Register to mean of the image
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
                matlabbatch{i}.spm.spatial.realign.estwrite.eoptions.weight  = '';
                matlabbatch{i}.spm.spatial.realign.estwrite.roptions.which   = [2 1]; % Create resliced images of all runs and mean
                matlabbatch{i}.spm.spatial.realign.estwrite.roptions.interp  = 4;
                matlabbatch{i}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
                matlabbatch{i}.spm.spatial.realign.estwrite.roptions.mask    = 1;
                matlabbatch{i}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';
            case 2
                % Run Independent Slicetiming Parameters
                for a=1:length(runs)
                    images.reslice{1,a} = strrep(images.raw{1,a},[csub{:} '_task'],...
                        ['r' csub{:} '_task']);
                end
                matlabbatch{i}.spm.temporal.st.nslices  = 58;
                matlabbatch{i}.spm.temporal.st.tr       = 2.5;
                matlabbatch{i}.spm.temporal.st.ta       = 2.5-(2.5/58);
                % Set as Interleaved Slice Acquisition - odd slices collected 1st, then
                % evens, starting foot to head
                matlabbatch{i}.spm.temporal.st.so       = [1:2:58 2:2:58];
                matlabbatch{i}.spm.temporal.st.refslice = 2;
                matlabbatch{i}.spm.temporal.st.prefix   = 'a';
                
            case 3
                % Ashburner Fix for Better Normalization
                meanImage = dir([subjectFuncFolder '/run1/mean*']);
                matlabbatch{i}.spm.util.imcalc.input(1)       = {[meanImage(1).folder '/' meanImage(1).name]};
                matlabbatch{i}.spm.util.imcalc.output         = 'ashburnerReferenceImage';
                matlabbatch{i}.spm.util.imcalc.outdir         = {subject_funcfolder};
                matlabbatch{i}.spm.util.imcalc.expression     = 'i1 + randn(size(i1))*50';
                matlabbatch{i}.spm.util.imcalc.var            = struct('name', {}, 'value', {});
                matlabbatch{i}.spm.util.imcalc.options.dmtx   = 0;
                matlabbatch{i}.spm.util.imcalc.options.mask   = 0;
                matlabbatch{i}.spm.util.imcalc.options.interp = 1;
                matlabbatch{i}.spm.util.imcalc.options.dtype  = 4;
            case 4
                % Run Independent Coregistration Parameters
                %Ashburner
                anat_directory = fullfile(directories.anat, csub{:}, 'anat');
                matlabbatch{i}.spm.spatial.coreg.estimate.ref = {spm_select('ExtFPListRec', anat_directory, wildcards.anat)};
                matlabbatch{i}.spm.spatial.coreg.estimate.source = {[processDir ...
                    filesep csub{:} filesep 'func' filesep ...
                    matlabbatch{i-1}.spm.util.imcalc.output '.nii']};
                
                for a=1:length(runs)
                    images.slicetime{a,1} = [runs{a} '/ar' csub{:} '_task-mp_run-' num2str(a) '_bold.nii'];
                    if a==5
                        images.slicetime{a,1} = [processDir filesep csub{:} filesep ...
                            'func' filesep 'allRegions.nii'];
                    end
                end
                
                matlabbatch{i}.spm.spatial.coreg.estimate.other = images.slicetime;
                matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
                matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
                matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
                matlabbatch{i}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            case 5
                % Run Independent Segmentation Parameters
                % Find the TPM image on the MATLAB search path
                spm_segment_image = which('TPM.nii');
                matlabbatch{i}.spm.spatial.preproc.channel.vols(1)  = matlabbatch{i-1}.spm.spatial.coreg.estimate.ref;
                matlabbatch{i}.spm.spatial.preproc.channel.biasreg  = 0.001;
                matlabbatch{i}.spm.spatial.preproc.channel.biasfwhm = 60;
                matlabbatch{i}.spm.spatial.preproc.channel.write    = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(1).tpm    = {[spm_segment_image ',1']};
                matlabbatch{i}.spm.spatial.preproc.tissue(1).ngaus  = 1;
                matlabbatch{i}.spm.spatial.preproc.tissue(1).native = [1 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(1).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(2).tpm    = {[spm_segment_image ',2']};
                matlabbatch{i}.spm.spatial.preproc.tissue(2).ngaus  = 1;
                matlabbatch{i}.spm.spatial.preproc.tissue(2).native = [1 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(2).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(3).tpm    = {[spm_segment_image ',3']};
                matlabbatch{i}.spm.spatial.preproc.tissue(3).ngaus  = 2;
                matlabbatch{i}.spm.spatial.preproc.tissue(3).native = [1 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(3).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(4).tpm    = {[spm_segment_image ',4']};
                matlabbatch{i}.spm.spatial.preproc.tissue(4).ngaus  = 3;
                matlabbatch{i}.spm.spatial.preproc.tissue(4).native = [1 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(4).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(5).tpm    = {[spm_segment_image ',5']};
                matlabbatch{i}.spm.spatial.preproc.tissue(5).ngaus  = 4;
                matlabbatch{i}.spm.spatial.preproc.tissue(5).native = [1 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(5).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(6).tpm    = {[spm_segment_image ',6']};
                matlabbatch{i}.spm.spatial.preproc.tissue(6).ngaus  = 2;
                matlabbatch{i}.spm.spatial.preproc.tissue(6).native = [0 0];
                matlabbatch{i}.spm.spatial.preproc.tissue(6).warped = [0 0];
                matlabbatch{i}.spm.spatial.preproc.warp.mrf         = 1;
                matlabbatch{i}.spm.spatial.preproc.warp.cleanup     = 1;
                matlabbatch{i}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
                matlabbatch{i}.spm.spatial.preproc.warp.affreg      = 'mni';
                matlabbatch{i}.spm.spatial.preproc.warp.fwhm        = 0;
                matlabbatch{i}.spm.spatial.preproc.warp.samp        = 3;
                matlabbatch{i}.spm.spatial.preproc.warp.write       = [0 1];
            case 6
                % Run Indepenedent Normalization: Normalizaing the Functional Images
                for a=1:length(images.slicetime)
                    images.coreg{a,1} = [matlabbatch{i-2}.spm.spatial.coreg.estimate.other{a} ',1'];
                end
                
                images.coreg{a+1,1} = matlabbatch{i-2}.spm.spatial.coreg.estimate.ref{1};
                matlabbatch{i}.spm.spatial.normalise.write.subj.def = {[anat_directory '/y_' csub{:} '_T1w.nii']};
                matlabbatch{i}.spm.spatial.normalise.write.subj.resample = images.coreg;
                matlabbatch{i}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                    78 76 85];
                matlabbatch{i}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
                matlabbatch{i}.spm.spatial.normalise.write.woptions.interp = 4;
                matlabbatch{i}.spm.spatial.normalise.write.woptions.prefix = 'w';
            case 7
                % Run Indepednent Smoothing Parameters
                for a=1:length(runs)
                    images.norm{a,1} = strrep(images.coreg{a,1},...
                        ['ar' csub{:} '_task'],['war' csub{:} '_task']);
                end
                
                matlabbatch{i}.spm.spatial.smooth.data = images.norm;
                matlabbatch{i}.spm.spatial.smooth.fwhm    = [6 6 6];
                matlabbatch{i}.spm.spatial.smooth.dtype   = 0;
                matlabbatch{i}.spm.spatial.smooth.im      = 0;
                matlabbatch{i}.spm.spatial.smooth.prefix  = 's';
        end
        
    end
    
    %% Run batch
    
    if flag == 1
        
        spm_jobman('interactive', matlabbatch)
        pause
        
    elseif flag == 2
        
        % Configure SPM graphics window. Ensures a .ps file is saved during
        % preprocessing
        spm_figure('GetWin','Graphics');
        
        % Make psfiles the working directory. Ensures .ps file is saved in
        % this directory
        cd(directories.psfiles)
        
        % Run preprocessing
        spm_jobman('run', matlabbatch);
        
        % Rename the ps file from "spm_CurrentDate.ps" to "SubjectID.ps"
        temp = date;
        date_rearranged = [temp(end-3:end) temp(4:6) temp(1:2)];
        movefile(['spm_' date_rearranged '.ps'],sprintf('%s.ps',csub{:}))
        
    end
end
