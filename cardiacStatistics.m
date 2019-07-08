

function cavitiVolume = cardiacStatistics(LVseg)

sz = size(LVseg);

thickness = 5;
dist = 5;
ar = dist + thickness;

maskArea = [];

for i = 2 : sz(3)
        
    stats = regionprops(LVseg(:,:,i), 'Area'); %to get region properties
    if ~isempty(stats)
        x = stats.Area;
        pixArea = x * 1.5625;
        
        maskArea = [maskArea, pixArea];
    end
end
cavitiVolume = ar * sum(maskArea);