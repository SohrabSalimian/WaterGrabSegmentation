function [MeanCorrDist, Edges, RoiDist] = NeuroDistCorr(NoiseCorr, RoiLocations, SigRois, BinWidth)
%NeuroPilDistCorr Distance calculate
%Takes as input a noise correlation matrix, roi locations,significant rois, 
%BinWidth and returns a bar plot of the noise correlations binned by distance. 

RoiLocations = RoiLocations(SigRois, :);



RoiDist = zeros(length(SigRois), length(SigRois));
for i=1:length(RoiLocations)
    RoiDist(:, i) = sqrt(sum((RoiLocations(i, :) - ...
        RoiLocations(:, :)).^2, 2));
    
end

NanVec = NaN(1, length(SigRois));
RoiDist = RoiDist - diag(diag(RoiDist)) + diag(NanVec);
MaxDist = max(RoiDist, [], 'all');
MinDist = min(RoiDist, [], 'all');

NoiseCorrDist = NoiseCorr - diag(diag(NoiseCorr));

Edges = MinDist:BinWidth:MaxDist+100;

[Allocate, ~] = discretize(RoiDist, Edges);

MeanCorrDist = zeros(length(Edges), 1);
for i=1:length(Edges)
    indices = Allocate == i;
    MeanCorrDist(i, 1) = nanmean(NoiseCorrDist(indices));   
end


end

