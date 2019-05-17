%% Import DSI Studio Text Files
%  Daniel Elbich
%  6/15/15
% 							
%  Load saved ROI text file output from DSI Studio and 
%  concatenate into CSV file
%

%% Main Code

mkdir output;

fileLength=48;

for a=1:length(subjID)
       
        fileID = fopen(subjID{a,1});
        data = textscan(fileID,'%s','Delimiter','\n');
        tempcsv = cell(size(data{1,1},1),fileLength);
        
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
            for z=1:fileLength
                final.(regions{z,1})=tempcsv(:,1);
            end
        end
        
        % Add to final sheet
        for z=1:fileLength
            final.(regions{z,1})(:,a+1)=tempcsv(:,z+1);
            final.(regions{z,1}){1,a+1}=subjID{a,1};
        end
            

end

%% Write Output File
file = fopen([regions{x,1} '.csv'], 'w');

for a=1:size(final.(regions{x,1}),1)
    for b=1:size(final.(regions{x,1}),2)

        var = eval(['final.(regions{x,1}){a,b}']);

        fprintf(file, '%s', var);
        fprintf(file, ' ');

    end
    fprintf(file, '\n');
end
fclose(file);
