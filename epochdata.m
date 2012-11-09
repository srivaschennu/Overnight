function epochdata(basename)

loadpaths

%% EPOCH LENGTH
epochlength = 30; %sec

EEG = pop_loadset('filepath',filepath,'filename',[basename '_orig.set']);

%make bipolar EOG channels
eogpairs = {
    'E8'   'E126'
    'E25'  'E127'
    'E125' 'E128'
    };

fprintf('\nCalculating EOG channels.\n');
for p = 1:size(eogpairs,1)
    ch1idx = find(strcmp(eogpairs{p,1},{EEG.chanlocs.labels}));
    ch2idx = find(strcmp(eogpairs{p,2},{EEG.chanlocs.labels}));
    eogdata = EEG.data(ch1idx,:) - EEG.data(ch2idx,:);
    EEG.data(ch1idx,:) = eogdata;
    EEG.chanlocs(ch1idx).labels = sprintf('EOG%d',p);
    EEG = pop_select(EEG,'nochannel',ch2idx);
end


events = (0:epochlength:EEG.xmax)';
events = cat(2,repmat({'EVNT'},length(events),1),num2cell(events));
assignin('base','events',events);

EEG = pop_importevent(EEG,'event',events,'fields',{'type','latency'});
evalin('base','clear events');
EEG = eeg_checkset(EEG,'makeur');
EEG = eeg_checkset(EEG,'eventconsistency');

fprintf('\nSegmenting into %d sec epochs.\n',epochlength);
EEG = pop_epoch(EEG,{'EVNT'},[0 epochlength]);

EEG = pop_rmbase(EEG,[]);

EEG = eeg_checkset(EEG);

EEG.setname = [basename '_epochs'];
EEG.filename = [basename '_epochs.set'];
fprintf('Saving %s%s.\n',EEG.filepath,EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', filepath);

end