function mpc_adjusted = adjust_mpc(mpc, loading_factor)
    % Adjust load when loading factor <1
    mpc_adjusted = mpc;
    mpc_adjusted.bus(:, 3) = mpc.bus(:, 3) * loading_factor;
    mpc_adjusted.bus(:, 4) = mpc.bus(:, 4) * loading_factor;
    
    % Adjust generation
    total_load = sum(mpc_adjusted.bus(:, 3));
    total_gen = sum(mpc.gen(:, 2));
    gen_factor = total_load / total_gen;
    mpc_adjusted.gen(:, 2) = mpc.gen(:, 2) * gen_factor;
    
    % Adjust branch capacity
    mpc_adjusted = runpf(mpc_adjusted, mpoption('out.all', 0));
end