function dataimport_chunks(basename)

loadpaths

filenames = dir(sprintf('%s%s*', rawpath, basename));

if isempty(filenames)
    error('No files found to import!\n');
end

mfffiles = filenames(logical(cell2mat({filenames.isdir})));
if length(mfffiles) > 1
    error('Expected 1 MFF recording file. Found %d.\n',length(mfffiles));
end

filename = mfffiles.name;
fprintf('\nProcessing %s.\n\n', filename);

mffjarpath = which('MFF-1.0.d0004.jar');
javaaddpath(mffjarpath);
hdr = read_mff_header(sprintf('%s%s', rawpath, filename),0);
javarmpath(mffjarpath);

chunkends = 1200:3600:round(hdr.nSamples/hdr.Fs);

for chunk = 1:length(chunkends)
    EEG = pop_readegimff(sprintf('%s%s', rawpath, filename),...
        'firstsample',(chunkends(chunk)-600)*hdr.Fs,'lastsample',chunkends(chunk)*hdr.Fs-1);
    chunkname = sprintf('chunk%d',chunk);
    
    %%PREPROCESSING
    
    % REMOVE EXCLUDED CHANNELS
    chanexcl = [1,8,14,17,21,25,32,38,43,44,48,49,56,63,64,68,69,73,74,81,82,88,89,94,95,99,107,113,114,119,120,121,125,126,127,128];
    %chanexcl = [];
    fprintf('Removing excluded channels.\n');
    EEG = pop_select(EEG,'nochannel',chanexcl);
    
    %resample
    if EEG.srate > 250
        EEG = pop_resample(EEG,250);
    end
    
    %Filter
    hpfreq = 0.5;
    lpfreq = 45;
    fprintf('Low-pass filtering below %.1fHz...\n',lpfreq);
    EEG = pop_eegfilt(EEG, 0, lpfreq, [], [0], 0, 0, 'fir1', 0);
    fprintf('High-pass filtering above %.1fHz...\n',hpfreq);
    EEG = pop_eegfilt(EEG, hpfreq, 0, [], [0], 0, 0, 'fir1', 0);
    
    %Remove line noise
    fprintf('Removing line noise at 50Hz.\n');
    EEG = rmlinenoisemt(EEG);
    
    EEG.setname = sprintf('%s_%s_orig',basename,chunkname);
    EEG.filename = sprintf('%s_%s_orig.set',basename,chunkname);
    EEG.filepath = filepath;
    
    EEG = eeg_checkset(EEG);
    
    fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
    pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);
end