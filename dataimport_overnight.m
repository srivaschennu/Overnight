function dataimport_overnight(basename,sessnum)

chanlocpath = '/Users/chennu/Work/EGI/';
rawpath = '/Volumes/iStorage/Overnight/';
filepath = '/Users/chennu/Data/Overnight/';

auxchan = [8 25 57 100 125 126 127 128];

filenames = dir(sprintf('%s%s*', rawpath, basename));

if isempty(filenames)
    error('No files found to import!\n');
end

mfffiles = filenames(logical(cell2mat({filenames.isdir})));
if length(mfffiles) > 1
    error('Expected 1 MFF recording file. Found %d.\n',length(mfffiles));
else
    filename = mfffiles.name;
    fprintf('\nProcessing %s.\n\n', filename);
    
    mffjarpath = which('MFF-1.0.d0004.jar');
    javaaddpath(mffjarpath);
    evt = read_mff_event(sprintf('%s%s', rawpath, filename));
    javarmpath(mffjarpath);
    
    bginevt = find(strcmp('BGIN',{evt.type}) | strcmp('BEND',{evt.type}));
    fprintf('Found the following BGIN and BEND events.\n');
    for e = bginevt
        fprintf('%s@%d with %d codes\n',evt(e).type, evt(e).sample, size(evt(e).codes,1));
    end
    
    datachunks = [];
    sesscount = 1;
    for e = 1:length(evt)
        if strcmp(evt(e).type,'BGIN') && isempty(evt(e).codes)
            if sesscount == sessnum
                datachunks = [datachunks evt(e).sample];
            else
                sesscount = sesscount+1;
            end
            continue;
        end
        
        if ~isempty(datachunks)
            if strcmp(evt(e).type,'break cnt')
                datachunks = [datachunks evt(e).sample];
            elseif strcmp(evt(e).type,'sync')
            elseif strcmp(evt(e).type,'BEND') && isempty(evt(e).codes)
                datachunks = [datachunks evt(e).sample];
                break;
            else
                fprintf('Found unexpected event %s@%d in chunk %d.\n',...
                    evt(e).type,evt(e).sample,length(datachunks));
                datachunks = [datachunks evt(e).sample];
                break;
            end
        end
    end
    
    for c = 1:length(datachunks)-1
        fprintf('\nReading chunk %d (%d:%d)...\n',c,datachunks(c),datachunks(c+1)-1);
        
        EEGchunk = pop_readegimff(sprintf('%s%s', rawpath, filename),...
            'firstsample',datachunks(c),'lastsample',datachunks(c+1));
        
        EEGchunk = eeg_checkset(EEGchunk);
        
        %%% preprocessing
        
        fprintf('Keep selected channels.\n');
        load([chanlocpath 'GSN-HydroCel-129.mat']);
        keepchan = [];
        for chan = 1:length(idx1020)
            if idx1020(chan) <= EEGchunk.nbchan
                EEGchunk.chanlocs(idx1020(chan)).labels = name1020{chan};
                keepchan = [keepchan idx1020(chan)];
            end
        end
        EEGchunk = pop_select(EEGchunk,'channel',[keepchan auxchan]);
        
        if EEGchunk.srate > 250
            EEGchunk = pop_resample(EEGchunk,250);
        end
        
        if EEGchunk.pnts <= 600
            fprintf('Chunk too small. Skipping...\n');
            continue;
        end
        
        lpfreq = 45;
        fprintf('Low-pass filtering below %dHz...\n',lpfreq);
        EEGchunk = pop_eegfilt(EEGchunk, 0, lpfreq, [], [0], 0, 0, 'fir1', 0);
        hpfreq = 0.5;
        fprintf('High-pass filtering above %dHz...\n',hpfreq);
        EEGchunk = pop_eegfilt(EEGchunk, hpfreq, 0, [], [0], 0, 0, 'fir1', 0);
        
        if exist('EEG','var') && isstruct(EEG)
            EEG = pop_mergeset(EEG,EEGchunk);
        else
            EEG = EEGchunk;
        end
        
        EEG.setname = sprintf('%s_%d_orig',basename,sessnum);
        EEG.filename = sprintf('%s_%d_orig.set',basename,sessnum);
        EEG.filepath = filepath;
        
        fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
        pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);
    end
end

