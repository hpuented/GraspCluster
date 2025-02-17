%% Step 1. Internal Validation

ch_names = ["FCz", "C1", "Cz", "C2"];
int_val = zeros(8,4); % Matrix 8x4. First 4 rows = T1 (4 channels), Last 4 rows = T2 (4 channels).

counter = 1;
for taxonomy = 1:2
    if taxonomy == 1
        tax_name = "T1";
        k = 3; % Number of clusters (k)
    else
        tax_name = "T2";
        k = 2;
    end
   
    for channel = 1:4
        filename = strcat(tax_name,"_AvgFeatMatrix_",ch_names(channel),'.mat');
        load(filename);
        [int_val(counter,1), int_val(counter,2), int_val(counter,3), int_val(counter,4)] = kmeans_InternalValidation(avg_features, k, 5);
        counter = counter+1;
    end
end

%% Step 2. Matrix selection (based on internal validation) and External validation
ext_val = zeros(2,3); % Matrix 2x3. First row = T1, Second row = T2.

for taxonomy = 1:2
    if taxonomy == 1
        load T1_AvgFeatMatrix_C2.mat
        k = 3;
        [ext_val(taxonomy,1), ext_val(taxonomy,2), ext_val(taxonomy,3)] = kmeans_ExternalValidation(avg_features, k);
        
    else
        load T2_AvgFeatMatrix_C2.mat
        k = 2;
        [ext_val(taxonomy,1), ext_val(taxonomy,2), ext_val(taxonomy,3)] = kmeans_ExternalValidation(avg_features, k);
    end 
end
