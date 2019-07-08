%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on: A Feature-Preserving Adaptive Smoothing Method for Early
% Vision;  Ke Chen. 
% 
% Adrian Lam
% ayplam@gmail.com

function out = adaptiveSmoothing(img,iter)

if ~exist('iter','var')
    iter = 3;
end

sz = size(img);
 
theta = 0.2;
R = 1;
alpha = 10;    % What extent of important features preserved in terms of context
S = 10;   % What extent of local discontinuities preserved in terms of smoothing

sig = getContextDiscont(img,R);
n = exp(-alpha * (sig > theta).* sig);
localDiscont = getLocalDiscont(img);
y = exp(-localDiscont/S);

% Initialize the img_adaptive
out = img;

% Iterate away!
lwa = zeros(size(out));
for it = 1:iter
    for row = R+1:sz(1)-R
        for col = R+1:sz(2)-R
            img_nbrhd = getContextNeighborhood(out,[row col],R);
            n_nbrhd = getContextNeighborhood(n,[row col],R);
            y_nbrhd = getContextNeighborhood(y,[row col],R);            
            
            lwa(row,col,:) = getLocalWeightedAverage(img_nbrhd,n_nbrhd,y_nbrhd);
            out(row,col,:) = out(row,col,:) + lwa(row,col,:);
           
        end
    end
    
    y = exp(-getLocalDiscont(out) / S);
end