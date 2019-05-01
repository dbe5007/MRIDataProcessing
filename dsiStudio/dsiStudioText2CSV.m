%% Import DSI Studio Text Files
%  Daniel Elbich
%  6/15/15
%
%  Load text file output from DSI Studio and concatenate
%  into CSV files


%% Main Code

mkdir output;

for a=1:length(subjID)
    
    s=a+1;
       
        fileID = fopen(subjID{a,1});
        data = textscan(fileID,'%s','Delimiter','\n');
        tempcsv = cell(size(data{1,1},1),48);
        
        for b=1:length(data{1,1})
            limbo=strsplit(data{1,1}{b,1}, '\t');
            for c=1:length(limbo)
                tempcsv{b,c}=limbo{1,c};
            end
            clear limbo;
        end
        
        tempcsv = strrep(tempcsv, '(', '');
        tempcsv = strrep(tempcsv, ')', '');
        tempcsv = strrep(tempcsv, '_/', '');
        tempcsv = strrep(tempcsv, '-', '');
        
        if a == 1
            for z=1:48
                final.(regions{z,1})=tempcsv(:,1);
            end
        end
        
        % Add to final sheet
        for z=1:48
            final.(regions{z,1})(:,s)=tempcsv(:,z+1);
            final.(regions{z,1}){1,s}=subjID{a,1};
        end
            

end

% Output
file = fopen([regions{x,1} '.csv'], 'w');

for a=1:size(final.(regions{x,1}),1)
    for b=1:size(final.(regions{x,1}),2)

        var = eval(['final.(regions{x,1})']);

        fprintf(file, '%s', var);
        fprintf(file, ' ');

    end
    fprintf(file, '\n');
end
fclose(file);
