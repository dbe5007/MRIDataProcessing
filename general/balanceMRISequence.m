%% Generate Balanced fMRI Sequence
%  Daniel Elbich
%  10/4/17
%
%
%  Create a balanced sequence for stimuli presentation. Based on idea for
%  msequence (each condition preceeds each other equally) but written
%  with the case of only 2 conditions and equal number of blocks, where a
%  true msequence is mathematically impossible.


% program where condtion 1 and 2 have equal probability of following one
% another (as equal as possible mathematically)

vector=[1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2];

order_cond={'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' ...
    'B' 'B' 'B' 'B' 'B' 'B' 'B' 'B' 'B' 'B' 'B' 'B'};

struct.A_BEFORE_A=0;
struct.A_AFTER_A=0;
struct.A_BEFORE_B=0;
struct.A_AFTER_B=0;
struct.B_BEFORE_A=0;
struct.B_AFTER_A=0;
struct.B_BEFORE_B=0;
struct.B_AFTER_B=0;

flag=0;
tic;
while flag==0;

order_cond=order_cond(randperm(length(order_cond)));


for p=1:24
    
    switch order_cond{p}
        case 'A'
            
            if p==1
                
                if order_cond{p+1}=='A'
                    struct.A_BEFORE_A=struct.A_BEFORE_A+1;
                end
                
                if order_cond{p+1}=='B'
                    struct.A_BEFORE_B=struct.A_BEFORE_B+1;
                end
                
            elseif p<24
                
                if order_cond{p-1}=='A'
                    struct.A_AFTER_A=struct.A_AFTER_A+1;
                end
                
                if order_cond{p-1}=='B'
                    struct.A_AFTER_B=struct.A_AFTER_B+1;
                end
                
                if order_cond{p+1}=='A'
                    struct.A_BEFORE_A=struct.A_BEFORE_A+1;
                end
                
                if order_cond{p+1}=='B'
                    struct.A_BEFORE_B=struct.A_BEFORE_B+1;
                end
                
            elseif p==24
                
                if order_cond{p-1}=='A'
                    struct.A_AFTER_A=struct.A_AFTER_A+1;
                end
                
                if order_cond{p-1}=='B'
                    struct.A_AFTER_B=struct.A_AFTER_B+1;
                end
                
            end
            
        case 'B'
            
            if p==1
                
                if order_cond{p+1}=='A'
                    struct.B_BEFORE_A=struct.B_BEFORE_A+1;
                end
                
                if order_cond{p+1}=='B'
                    struct.B_BEFORE_B=struct.B_BEFORE_B+1;
                end
                
            elseif p<24
                
                if order_cond{p-1}=='A'
                    struct.B_AFTER_A=struct.B_AFTER_A+1;
                end
                
                if order_cond{p-1}=='B'
                    struct.B_AFTER_B=struct.B_AFTER_B+1;
                end
                
                if order_cond{p+1}=='A'
                    struct.B_BEFORE_A=struct.B_BEFORE_A+1;
                end
                
                if order_cond{p+1}=='B'
                    struct.B_BEFORE_B=struct.B_BEFORE_B+1;
                end
                
            elseif p==24
                
                if order_cond{p-1}=='A'
                    struct.B_AFTER_A=struct.B_AFTER_A+1;
                end
                
                if order_cond{p-1}=='B'
                    struct.B_AFTER_B=struct.B_AFTER_B+1;
                end
                
            end
            
    end
    
    
    
end

if (struct.A_BEFORE_A+struct.B_BEFORE_A+struct.A_AFTER_A+...
        struct.A_AFTER_B+struct.B_BEFORE_A+struct.B_AFTER_A+...
        struct.B_BEFORE_B+struct.B_AFTER_B)==46
    flag=1;
    
else
    struct.A_BEFORE_A=0;
    struct.A_AFTER_A=0;
    struct.A_BEFORE_B=0;
    struct.A_AFTER_B=0;
    struct.B_BEFORE_A=0;
    struct.B_AFTER_A=0;
    struct.B_BEFORE_B=0;
    struct.B_AFTER_B=0;
end

end

run_time=toc;

%clear struct.A_BEFORE_A struct.A_AFTER_A struct.A_BEFORE_B...
%    struct.A_AFTER_B struct.B_BEFORE_A struct.B_AFTER_A...
%    struct.B_BEFORE_B struct.B_AFTER_B;

