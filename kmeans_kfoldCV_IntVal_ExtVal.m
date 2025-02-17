% In clustering, k-fold cross-validation can be used to evaluate the internal validation 
% of the model.
% Internal validation: Internal metrics assess the quality of clusters based on 
% intrinsic properties of the data, without relying on external labels or ground truth information.
% Instead, you use metrics that evaluate the cohesion and separation of the clusters 
% based on the intrinsic properties of the data.

% For evaluating external validity, you would typically reserve a separate dataset (often called a validation or test set) 
% that was not used during the training or cross-validation process. 
% After training your model on the training set and tuning hyperparameters using cross-validation, 
% you assess its performance on the unseen test set to get an indication of how well it generalizes to new data.
% External validation: external metrics evaluate the clustering results by 
% comparing them to external ground truth or known labels.

%% Step 1. Internal Validation
addpath C:\Users\helen\Documentos\UT\2A\3.Code\Scripts\data\Avg_features

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
