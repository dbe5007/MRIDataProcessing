%% Create b-files from b-table
%  Daniel Elbich
%  2/6/19
%
%  Created separate bvec and bval files to use with FSL
%  from DSI Studio btable.
%
%

%% Main Code
fid=fopen(datafiles(a).name);
data = textscan(fid,'%s','Delimiter','\n');
tempcsv = cell(70,4);

% Parse data into readable format using tab delimiter
for z=1:length(data{1,1})
    
    limbo=strsplit(data{1,1}{z,1},'\t');
    
    for p=1:length(limbo)
        tempcsv{z,p}=limbo{1,p};
    end
    
    clear limbo;
end

% Put b-table into separate bval and bvec files
bval=tempcsv(:,1);
bvec=tempcsv(:,2:4);

% Save bval table
file = fopen('bval', 'w');

for a=1:size(bval,1)
    
    for b=1:size(bval,2)
        
        var = eval(['bval{a,b}']);
        %var = final(a,b);
        
        fprintf(file, '%s', var);
        %fprintf(file, ',');
        
    end
    
    fprintf(file, '\n');
    
end
fclose(file);

% Save bvec table
file = fopen('bvec', 'w');

for a=1:size(bvec,1)
    
    for b=1:size(bvec,2)
        
        var = eval(['bvec{a,b}']);
        %var = final(a,b);
        
        fprintf(file, '%s', var);
        fprintf(file, ' ');
        
    end
    
    fprintf(file, '\n');
    
end
fclose(file);

