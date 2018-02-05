% Ad hoc code to read video file
function [output] = quick_mp4_reader(vidIn)
v = VideoReader(vidIn);
counter = 1;
while hasFrame(v)
    newFrame = readFrame(v);
    newFrame = newFrame(:,:,1);
    output{counter} = newFrame;
    counter = counter + 1;
    newFrame = [];
end
end