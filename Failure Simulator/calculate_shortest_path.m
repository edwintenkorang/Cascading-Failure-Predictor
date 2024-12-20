function avg_shortest_path = calculate_shortest_path(mpc, initial_contingencies)
    define_constants;
    
    % Create a graph from the branch data
    from_bus = mpc.branch(:, F_BUS);
    to_bus = mpc.branch(:, T_BUS);
    G = graph(from_bus, to_bus);
    
    % Get the buses connected by the contingency branches
    branch1_buses = mpc.branch(initial_contingencies(1), [F_BUS, T_BUS]);
    branch2_buses = mpc.branch(initial_contingencies(2), [F_BUS, T_BUS]);
    
    % Calculate shortest paths between all combinations of branch endpoints
    total_path_length = 0;
    num_paths = 0;
    
    for i = 1:2
        for j = 1:2
            try
                path = shortestpath(G, branch1_buses(i), branch2_buses(j));
                if ~isempty(path)
                    total_path_length = total_path_length + length(path) - 1;  % -1 because path includes start and end nodes
                    num_paths = num_paths + 1;
                end
            catch
                % Path doesn't exist, do nothing
            end
        end
    end
    
    % Calculate average shortest path length
    if num_paths > 0
        avg_shortest_path = total_path_length / num_paths;
    else
        avg_shortest_path = Inf;  % If no valid paths exist
    end
end