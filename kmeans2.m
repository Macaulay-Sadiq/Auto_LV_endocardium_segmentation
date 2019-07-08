% kmeans2 separates the intensities of images into k-groups by minimizing
% the total difference between the image intensity and the closest cluster
% across the entire image
% [mask,mu] = kmeans2(ima,k)


function [mask, mu]=kmeans2(ima,k)

% check image
ima=double(ima);
copy=ima;         % make a copy
ima=ima(:);       % vectorize ima
mn=min(ima);      % deal with negative 
ima=ima-mn+1;     % and zero values
mx=ceil(max(ima));

% create image histogram

closestCluster = zeros(1,mx);

% Create histogram of the intensities in an image
[intCount,intBins] = hist(ima,1:mx);
% Find number of unique int values
inds = find(intBins);

% Initialize centroids by equally spacing them across all intensities

mu=(1:k)*mx/(k+1);
cnt = 1;

% Iterate centroid calculation
while(true)
  
  % Current location of centroids
  oldmu=mu;
 
  % Get the minimum cluster
  for i=inds
      % c is the distance for each cluster from the int value
      dist=abs(intBins(i)-mu);
      [~,idx] = min(dist);
      
      % Store the closest cluster to the particular int value
      closestCluster(intBins(i))=idx(1);      
  end
  
  % Recalculate centroids
  for i=1:k
      
      % What are the int values for which a cluster the was the
      % "closest cluster"? This is also the index for the number of times
      % the cluster appears
      closestClusterInt=find(closestCluster==i);
      
      % Get all the int values for which it was the "closest cluster"
      % and find the associated counts 
      
      % Weight the int values by the number of times it actually
      % appears. Divide it by the sum of all counts. These are the new
      % centers.
     
      mu(i)=sum(closestClusterInt.*intCount(closestClusterInt)) ...
          /sum(intCount(closestClusterInt));
  end
  
  if isnan(sum(mu-oldmu))
      keyboard
  end
  
  if (mu==oldmu) | cnt > 10
      break
  end
  
  cnt = cnt + 1;
  
end

% calculate mask
sz=size(copy);
mask=zeros(sz);
for i = 1:numel(copy)
  c=abs(copy(i)-mu);
  [~,idx] = min(c);
  mask(i)=idx(1);
end

mu=mu+mn-1;   % recover real range