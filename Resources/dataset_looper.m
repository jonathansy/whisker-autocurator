% note: 11, 12, 
tArrayDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\loopTArrays';
cArrayDir = 'C:\SuperUser\CNN_Projects\Phil_Pipeline\cArrays';
tArrayList = dir([tArrayDir '/*.mat']);
vids = 'Z:/Data\Video\PHILLIP';
jobIdx = 125;

for i = 1:length(tArrayList)
    tName = tArrayList(i).name;
    tPath = [tArrayDir filesep tName];
    sessName = regexp(tName, '_[1234567890]+', 'match');
    if numel(sessName) ~= 1
        error('Name search failed')
    else
        sessName = sessName{1};
        cArrayName = ['ConTA' sessName '.mat'];
    end
    T = load(tPath);
    T = T.T;
    mouse = T.mouseName;
    session = T.sessionName;
    vDir = [vids filesep mouse filesep session];
    if ~exist(vDir)
        vDir = ['Y:\Whiskernas\Data\Video\PHILLIP' filesep mouse filesep session];
    end
    tDir = [tArrayDir filesep tName]; 
    cDir = [cArrayDir filesep cArrayName]; 
    % Auto-create contact array 
    [contacts, params] = autoContactAnalyzerSi(T);
    save(cDir, 'contacts', 'params'); 
    
   %Make job name
   jobName = ['Pipeline_' num2str(jobIdx)];
   autocurator_master_function(vDir, tDir, cDir, jobName);
   jobIdx = jobIdx + 1;
end