% out_U and out_V will be the same (n,r) as the in_U and in_V
% middle_n and middle_r are the (n,r) used for A_T

function [out_U, out_V, Y] = winoPE(in_U, in_V, size_k, U_n, U_r, V_n, V_r, ...
                            middle_n, middle_r, Y_n, Y_r, ...
                            file_generation, output_folder_name, filename_count)
% if size_k is 0, 3*3 filter
% if size_k is 1, 1*1 filter
    
% original approach
%     in_U = double(fi(in_U, 1, U_n, U_r));
%     in_V = double(fi(in_V, 1, 12, 11));

% new approach
    in_U = fi(in_U, 1, U_n, U_r);
    in_V = fi(in_V, 1, V_n, V_r);
    
%     in_V = double(fi(in_V, 1, U_n, U_r));
    
    out_U = in_U;
    out_V = in_V;
    
    if (size_k == 0)
        s0 = 0;
        s1 = 1;
    elseif (size_k == 1)
        s0 = 0;
        s1 = 0;
    end
    
    A_T = [1, 1, 1, 1, 1, 0;
           0, 1,-1, 2, -2, s0;
           0, 1, 1, 4, 4, 0;
           0, 1, -1,8,-8, s1];
       
    if (size_k == 1)
        A_T = A_T(1:2, :);
    end
       
   A_T = double(fi(A_T, 1, middle_n, middle_r));
   
   
   
%    UV = double(fi(in_U .* in_V, 1, middle_n, middle_r));
   UV = in_U .* in_V;
   UV = double(fi(UV, 1, middle_n, middle_r));
   
   Y = A_T * UV * A_T.';
   Y = fi(Y, 1, Y_n, Y_r);
   
   if(file_generation == 1)
       writematrix(Y.int, fullfile(output_folder_name, strcat(string(filename_count) ,'output.txt')), 'Delimiter', ' ');
   end
   
   Y = double(Y);


%    Y = A_T * (in_U .* in_V) * A_T.';
%    Y = double(fi(Y, 1, Y_n, Y_r));

end