%% Delete Overlapping Voxels
%  Daniel Elbich
%  3/15/19
%
%
%  Identifies overlapping voxels between two VOI files and deletes
%  them from the first VOI file (chosen arbitrarily - could do
%  second as well).
%
%  UNDER DEVELOPMENT
%

fid = fopen('/path/to/region1.voi');
region1 = textscan(fid,'%s','Delimiter','\n');

fid = fopen('/path/to/region2.voi');
region2 = textscan(fid,'%s','Delimiter','\n');

fclose(fid);
    
for z=1:length(region1{1,1})
    
    limbo=strsplit(region1{1,1}{z,1},' ');
    
    for p=1:length(limbo)
        
        region1Vox{z,p}=limbo{1,p};
        
    end
    clear limbo;
end

for z=1:length(region2{1,1})
    
    limbo=strsplit(region2{1,1}{z,1},' ');
    
    for p=1:length(limbo)
        
        region2Vox{z,p}=limbo{1,p};
        
    end
    clear limbo;
end

