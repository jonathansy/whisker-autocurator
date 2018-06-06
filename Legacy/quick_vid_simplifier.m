function [aFrames] = quick_vid_simplifier(vid)
nFrames = length(vid);
for i = 1:nFrames
    aFrames.edge{i} = edge(vid{i});
    aFrames.graph{i} = sum(aFrames.edge{i}(50:end,:));
    aFrames.graph{i} = smooth(aFrames.graph{i},20);
    aFrames.cut{i} = aFrames.edge{i}(205:305,255:355);
    aFrames.cgraph{i} = sum(aFrames.cut{i});
    aFrames.tot(i) = sum(aFrames.cgraph{i});
    aFrames.cgraph{i} = smooth(aFrames.cgraph{i});
    
end 
end 