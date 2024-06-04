function [all_strk_len_vec,  strk_lmts_idx_array] = findConsecStreaks(binaryArray) %return start and end col
%can determine the bounds of a streak/run of trials for vectors and martices (2-D) (edges,bounds, limits, extentents 

    num_rows = size(binaryArray, 1);
    binaryArray = [zeros(num_rows, 1) binaryArray zeros(num_rows, 1)];
    startStopArray = diff(binaryArray, 1, 2);

    run_vecs = struct('bgn_vec', [], 'end_vec', []); % for recording initiation and termination of rusn start/stop/begin/end
    
    %num_trials = size(startStopArray, 2) + 1; %or insted of plus one do diff in function 
    %If array is 1-D (vector) can ignore rows of find
    [start_row, start_col] = find(startStopArray == 1); 
    [end_row, end_col] = find(startStopArray == -1); 


    if size(start_row, 1) == 1
       %make column vectors
       start_row = start_row.';
       start_col = start_col.';
       end_row = end_row.';
       end_col = end_col.';
    end
    %create two column matrix, sort rows to separate targets' run begining
    %and 
    bgn_max_run_mat = sortrows([start_row start_col]);
    end_max_run_mat = sortrows([end_row end_col]);
    
    strk_lmts_idx_array = [start_col (end_col-1)];
    
    temp_run_len_vec = [];
    for i=1:num_rows
        
        run_vecs.bgn_vec = bgn_max_run_mat((bgn_max_run_mat(:, 1) == i), 2);

        run_vecs.end_vec = end_max_run_mat((end_max_run_mat(:, 1) == i), 2);
        
        %check the length can either miss start at begining or
        %finish at end
        if ~isempty(run_vecs.bgn_vec) %|| ~isempty(targ_run_vecs(c).end_vec)
            
            %collapse across targets
            temp_run_len_vec = [temp_run_len_vec ; (run_vecs.end_vec - run_vecs.bgn_vec)];
        end
        

    end
    
    all_strk_len_vec = temp_run_len_vec;

end