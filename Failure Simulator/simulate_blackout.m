function [failed_lines_rated_power, failed_lines_actual_power, load_shed, total_islands, initial_islands, shortest_path, n_failed_lines] = simulate_blackout(mpc, initial_contingencies, capacity_error)
%this is a function to simulate a full cascading failure instance involving
%line failure from a single point. The parameters are the initial power
%system data (mpc), initial lines failed (initial_contingencies),
%capacity_error (a probability that the actual line capacity is different
%from the installed capacity due to aging). The cascade returns several
%variables which are fed into a dataset for processing and prediction.
% Load MATPOWER 
define_constants;
mpc_original = mpc; %necessary as there will be further mpc updates along the way

% Assign line capacities and start initial contingency
%can equally be done with the assign_capacities function
failed_lines_rated_power = sum(mpc.branch(initial_contingencies, RATE_A));
mpc.branch(:, 6) = mpc.branch(:, 6) * (1 - capacity_error);
shortest_path = calculate_shortest_path(mpc,initial_contingencies);%calculate shortest path beween branches 
%mpc = runpf(mpc);
%record a variable from branch data before starting cascade
failed_lines_actual_power = sum(apparent(mpc.branch(initial_contingencies, PF), mpc.branch(initial_contingencies, QF)));
for i = 1:length(initial_contingencies)
    mpc.branch(initial_contingencies(i), BR_STATUS) = 0;
end

% Initialize variables for dataset
load_shed = 0;
total_islands = 0;
initial_islands = 0;
n_failed_lines = 0;
% Run cascade
[mpc, load_shed, total_islands, initial_islands, n_failed_lines] = run_cascade(mpc, mpc_original, load_shed, total_islands, initial_islands, true, n_failed_lines);
end