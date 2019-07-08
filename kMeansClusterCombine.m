function combinedClusters = kMeansClusterCombine(kInfo)

% Basically make a map of ALL clusters and see what needs to be combined.
combinedClusters = zeros(size(kInfo.mask));
Ltot = zeros(size(kInfo.mask));

parfor im = 1:size(kInfo.mask,3)
        
    % Combine clusters based on the intensity differences between the clusters
    disp(['Current image... ',num2str(im)])
    
    % Difference matrix
    currKGroup = kInfo.grps(im,:);
    diffKGroup = zeros(15);
    for i = 1:15
        for j = 1:15
            diffKGroup(i,j) = abs(currKGroup(i) - currKGroup(j));
        end
    end
    
    % Intensity threshold for whether to combine two separate groups or not
    bDiffKGroup = diffKGroup < 50;

    Lgrps = zeros(15,2);
    
    currLtot = Ltot(:,:,im);
    
    % Label all your groups. Each kGroup blob is a different group.
    for i = 1:15
        [~,L] = bwboundaries(kInfo.mask(:,:,im) == i,'noholes');
        L(L~=0) = L(L~=0) + max(currLtot(:));
        Lgrps(i,:) = [min(L(L~=0)) max(L(L~=0))];
        currLtot = currLtot + L;
    end
    
    Ltot(:,:,im) = currLtot;
    
    Lconn = [];
    currMask = kInfo.mask(:,:,im);
    
    % Find all adjacent groups
    for i = 1:15
        
        for grp = Lgrps(i,1):Lgrps(i,2)
            
            % Dilate a single group to see what's nearby.
            adjMask = imdilate(currLtot == grp,ones(3));
            
            % Which kGroup blobs do the mask touch?
            adjKGroups = adjMask .* currMask;
            validKGroups = ismember(adjKGroups,find(bDiffKGroup(i,:)));
            uniqKGroups = unique(validKGroups .* currLtot);
            
            % Remove all zeros (due to the it being a mask
            uniqKGroups(uniqKGroups==0) = [];
            % Remove all self groups
            uniqKGroups(uniqKGroups == grp) = [];
            % Remove any "previous" groups because they've already been
            % collected.
            uniqKGroups(uniqKGroups < grp) = [];
            
            if isempty(uniqKGroups)
                continue
            else
                % Append to the Lconn holder.
                Lconn = [Lconn; [repmat(grp,length(uniqKGroups),1) uniqKGroups]];
            end
            
        end
        
    end
        
    Lconn_connections = cell(15,1);
    curr_conn = 0;
    % Start combining everything!!!!
    while any(Lconn)
        curr_conn = curr_conn + 1;
        if curr_conn == 35
            break;
        end
        srch = Lconn(1,:);
        Lconn(1,:) = [];
        while true
            [row,~] = find(ismember(Lconn,srch(:)));
            if isempty(row)
                Lconn_connections{curr_conn} = srch(:);
                break
            else
                row = unique(row);
                tmp = Lconn(row,:);
                srch = unique([srch(:); tmp(:)]);
                Lconn(row,:) = [];
            end
        end
    end
    
    Lconn_connections = Lconn_connections(~cellfun(@isempty,Lconn_connections));
    for i = 1:length(Lconn_connections)
        combinedClusters(:,:,im) = combinedClusters(:,:,im) + ismember(currLtot,Lconn_connections{i}) * i;
    end
    
end
