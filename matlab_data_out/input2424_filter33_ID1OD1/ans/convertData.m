% Read the file
inputFile = 'Y_HEX.txt'; % Input filename
outputFile = 'Y_HEX_modified.txt'; % Output filename

% Open the input file for reading
fid_in = fopen(inputFile, 'r');
if fid_in == -1
    error('Error opening the input file.');
end

% Open the output file for writing
fid_out = fopen(outputFile, 'w');
if fid_out == -1
    fclose(fid_in);
    error('Error opening the output file.');
end

% Process each line
while ~feof(fid_in)
    line = fgetl(fid_in); % Read a line
    if ischar(line)
        % Add 20 zeros at the beginning
        modifiedLine = '00000000000000000000'; % 20 zeros
        
        % Split the line into groups of 12 hexadecimal numbers
        lineLength = length(line);
        for i = 1:12:lineLength
            % Extract the 12-character chunk
            chunk = line(i:min(i+11, lineLength));
            % Append the chunk and 6 zeros to the modified line
            modifiedLine = [modifiedLine, chunk, '000000'];
        end
        
        % Add 42 zeros at the end
        modifiedLine = [modifiedLine, '000000000000000000000000000000000000000000'];
        
        % Write the modified line to the output file
        fprintf(fid_out, '%s\n', modifiedLine);
    end
end

% Close the files
fclose(fid_in);
fclose(fid_out);

disp('File processing complete. Modified file saved as Y_HEX_modified.txt.');
