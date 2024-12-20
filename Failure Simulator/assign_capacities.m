function branch_data = assign_capacities(branch_data)
        %starting point for while loop iteration
        index = 1; 
        %quantize capacities between 30 - 500
     while index <= length(branch_data)
         index_power = apparent(branch_data(index, 14),branch_data(index,15));
        if index_power < 30 
            branch_data(index,6) = 30;
        elseif index_power < 100
                branch_data(index,6) = 100;
        elseif index_power < 200
                branch_data(index,6) = 200;
        elseif index_power < 500
                branch_data(index,6) = 500;
        else 
            branch_data(index,6)= 800;
        end
        index = index + 1;
     end
end