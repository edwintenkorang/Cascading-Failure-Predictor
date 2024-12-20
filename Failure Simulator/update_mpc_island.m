unction mpc = update_mpc_island(mpc, island_mpc, island_buses)
% This function updates the main mpc with changes from the island_mpc
define_constants;

% Update bus data
mpc.bus(island_buses, :) = island_mpc.bus(:, :);

% Update gen data
gen_indices = ismember(mpc.gen(:, GEN_BUS), island_buses);
mpc.gen(gen_indices, :) = island_mpc.gen(:, :);

% Update branch data
from_bus_indices = ismember(mpc.branch(:, F_BUS), island_buses);
to_bus_indices = ismember(mpc.branch(:, T_BUS), island_buses);
branch_indices = from_bus_indices & to_bus_indices;
mpc.branch(branch_indices, :) = island_mpc.branch(:, :);

% Update gencost if it exists
if isfield(mpc, 'gencost') && isfield(island_mpc, 'gencost')
    mpc.gencost(gen_indices, :) = island_mpc.gencost(:, :);
end

end