% Load case
mpc = loadcase('case118');
mpc = runpf(mpc, mpoption('out.all', 0)); %to initialize and mandem
disp('about to begin')
% Get number of branches
n_branches = size(mpc.branch, 1);
mpc.branch = assign_capacities(mpc.branch);
% Generate all unique contingency pairs using nchoosek
%use if running for large dataset
%contingency_pairs = nchoosek(1:n_branches, 2);

%else single contingency
contingency_pairs = [1,2];

% Define loading factors and capacity errors ranges
loading_factors = 0.5:0.05:1;
capacity_errors = 0.05:0.05:0.2;
%for single instances use below
%loading_factors = 1;
%capacity_errors = 0.05;
dataset = [];
% Iterate through all combinations
for i = 1:size(contingency_pairs, 1)
    initial_contingencies = contingency_pairs(i, :);
    
    for loading_factor = loading_factors
        for capacity_error = capacity_errors
            % Adjust loading and capacity
            mpc_adjusted = adjust_mpc(mpc, loading_factor);
            disp('we dey simulate')
            disp(initial_contingencies)
            % Simulate blackout
            [failed_lines_rated_power, failed_lines_actual_power, load_shed, total_islands, initial_islands, avg_shortest_path, n_failed_lines] = simulate_blackout(mpc_adjusted, initial_contingencies, capacity_error);
            
            % Store results in dataset for prediction
            dataset = [dataset; initial_contingencies, loading_factor, capacity_error, failed_lines_rated_power', failed_lines_actual_power', total_islands, initial_islands, avg_shortest_path,n_failed_lines, load_shed];
        end
    end
end