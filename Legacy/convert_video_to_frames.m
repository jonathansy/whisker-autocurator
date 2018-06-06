%CONVERT_VIDEO_TO_FRAMES(INVID) is a simple function that takes in a video
%and returns an array of frames in that video that can then be furthr processed.

function [outVid] = convert_video_to_frames(inVid)
  currentVid = VideoReader(inVid);
  buildVideoNormal = []; %Create cell array of number of frames to increase speed
  counter = 1;
  while hasFrame(currentVid)
    newFrame = readFrame(currentVid);
    newFrame = newFrame(:,:,1); %RGB values are the same because vid is mono
    buildVideoNormal{counter} = newFrame;
    counter = counter + 1;
    newFrame = [];
  end
  %Put array of video frames into larger array of videos
  outVid.video = buildVideoNormal;
end % ==========================================================================
