
tArrayDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\tArrays';
cArrayDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\cArrays';
tArrayList = dir([tArrayDir '/*.mat']);
vids = 'Z:/Data\Video\PHILLIP\';

for i = 1:length(tArrayList)
    tName = tArrayList(i).name;
    tPath = [tArrayDir filesep tName];
    T = load(tPath);
    T = T.T;
    mouse = T.mouseName;
    session = T.sessionName;
    vDir = [vids filesep mouse filesep session];
    tDir = tName
end