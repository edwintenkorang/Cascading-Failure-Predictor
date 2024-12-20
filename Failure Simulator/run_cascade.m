function [mpc, load_shed, total_islands, initial_islands, n_failed_lines] = run_cascade(mpc, mpc_original, load_shed, total_islands, initial_islands, is_first_iteration, n_failed_lines)

define_constants; %names the columns with abbreviations - etcc PF or QF in apparent function

% Find islands and run power flow for each island
[groups, ~] = find_islands(mpc);
num_islands = length(groups);
if is_first_iteration
    initial_islands = num_islands;
    n_failed_lines = 0;
    disp('cascade began')
end

total_islands = total_islands + num_islands; %update islands total
cascade_continues = false; %initialize

for i = 1:num_islands
    sub_mpc = extract_islands(mpc, groups, i); %extracting the different islands

    if sum(sub_mpc.bus(:,2)) == length(sub_mpc.bus(:,2))
        load_shed = load_shed + sum(apparent(sub_mpc.bus(:, PD),sub_mpc.bus(:,QD)));
        disp(sum(apparent(sub_mpc.bus(:, PD),sub_mpc.bus(:,QD))))
        continue;
    end %to prevent crash of cascade due to abscence of PV bus. No PV bus means no slack bus and therefore no analysis.
    %in abscence of slack bus assume lost load.
        % Run power flow
        [result, success] = runpf(sub_mpc, mpoption('out.all', 0));
        
        if success
            % Check for overloaded lines (Apparent power)
            S = apparent(result.branch(:,PF), result.branch(:,QF));
            overloads = S - result.branch(:, RATE_A);
            overloaded = find(overloads > 0 & result.branch(:, RATE_A) > 0);
            
            if ~isempty(overloaded)
                % Find the most overloaded line
                [~, max_overload_idx] = max(overloads(overloaded));
                max_overloaded_line = overloaded(max_overload_idx);
                result.branch(max_overloaded_line, BR_STATUS) = 0;
                n_failed_lines = n_failed_lines + 1;
                % Update mpc with the changes in this island
                mpc = update_mpc_island(mpc, result, groups{i});
                
                %if overloaded line is found, cascade continues
                cascade_continues = true;
            end
        else
            % If power flow doesn't converge, consider all loads in this island shed
            load_shed = load_shed + sum(apparent(sub_mpc.bus(:, PD),sub_mpc.bus(:,QD)));
        end

end

% Calculate load shed
load_shed = load_shed + sum(apparent(mpc_original.bus(:, PD),mpc_original.bus(:,QD))) - sum(apparent(mpc.bus(:, PD), mpc.bus(:,QD)));

% Continue cascade if any line was tripped
if cascade_continues
    [mpc, load_shed, total_islands, initial_islands, n_failed_lines] = run_cascade(mpc, mpc_original, load_shed, total_islands, initial_islands, false, n_failed_lines);
end

end