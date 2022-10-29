%% Luigi Raiano, v1, 02-06-2020
%%
function n_pcs = Get_Number_PCs_Used_v1(subjs_in)
out = [];

n_pcs = [];

for i=1:length(subjs_in) % loop su soggetti
    speed_list = fieldnames(subjs_in(i).data);
    
    for j=1:length(speed_list) % loop su speed
        n_pcs(i,j) = size(subjs_in(i).data.(speed_list{j}).PCA.textile_rot_reduced,2);
    end % end for j
    
end % end for i
end