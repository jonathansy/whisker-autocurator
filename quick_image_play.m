function [] = quick_image_play(input)
nFrames = length(input.edge);
for i = 1:nFrames
    subplot(2,2,1)
    imshow(input.edge{i})
    
    subplot(2,2,3)
    plot(input.graph{i})
    ylim([0 60])
    
    subplot(2,2,2)
    imshow(input.cut{i})
    
    subplot(2,2,4)
    plot(input.cgraph{i})
    ylim([0 40])
    drawnow
end 
end