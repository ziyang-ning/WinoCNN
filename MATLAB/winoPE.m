% out_U and out_V will be the same (n,r) as the in_U and in_V

function [out_U, out_V, Y] = winoPE(in_U, in_V, size, input_n, input_r, middle_n, middle_r, Y_n, Y_r)
% if size is 0, 3*3 filter
% if size is 1, 5*5 filter
    
    in_U = fi(in_U, 1, input_n, input_r);
    in_V = fi(in_V, 1, input_n, input_r);
    out_U = in_U;
    out_V = in_V;
    
    if (size == 0)
        s0 = 0;
        s1 = 1;
    elseif (size == 1)
        s0 = 1;
        s1 = 0;
    end
    A_T = [1, 1, 1, 1, 1, 0;
           0, 1,-1, 2, -1, s0;
           0, 1, 1, 4, 4, 0;
           0, 1, -1,8,-8, s1];
       
   A_T = fi(A_T, 1, middle_n, middle_r);
   
   Y = A_T * (in_U .* in_V) * A_T.';
   Y = fi(Y, 1, Y_n, Y_r);

end


%     G = [1/4,   0,      0;
%         -1/6,  -1/6,    -1/6;
%         -1/6,   1/6,    -1/6;
%         1/24,   1/12,   1/6;
%         1/24,   -1/12,  1/6;
%         1/24,   -1/12,  1/6;
%         s0,     0,      s1];