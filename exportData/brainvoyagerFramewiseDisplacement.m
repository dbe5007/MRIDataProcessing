%% Framewise Displacement from Brainvoyager MAP files
%  Daniel Elbich
%  Penn State University
%  5/31/17
%
%  Reads in Brainvoyager .map files obtained using Motion Correction
%  plugin found here:
%  https://support.brainvoyager.com/brainvoyager/available-tools/86-available-plugins/70-motion-correction-processor)
%
%  Requires Neuroelf Toolbox (formerly BVQX Toolbox) found here:
%  http://neuroelf.net/
%
%

%% Main Code

for x=1:length(map_list)

    % Read in BV .map files
    temp_map = xff(map_list{x,1});

    % Average all FD values for all voxels with a slice
    for p=1:length(temp_map.Map)
        a(:,p)=mean(mean(temp_map.Map(p).Data));
    end
    
    % Add values to output
    final{x,1}=map_list{x,1};
    for y=1:length(a)
        final{x,y+1}=a(1,y);
    end

    % Cleanup loop variables
    clear a y;
    
end

%% Export Data to CSV File
file = fopen('all_FD_output.csv', 'w');

for a=1:size(final,1)

    for b=1:size(final,2)

        var = eval(['final{a,b}']);
        %var = final(a,b);

        fprintf(file, '%s', var);
        fprintf(file, ',');

    end

    fprintf(file, '\n');

end

% Close file and cleanup variables
fclose(file);
clear a b var file;

