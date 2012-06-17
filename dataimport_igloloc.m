function dataimport_igloloc(basename,sessnum)

loadpaths

chanexcl = [1,8,14,17,21,25,32,38,43,44,48,49,56,63,64,68,69,73,74,81,82,88,89,94,95,99,107,113,114,119,120,121,125,126,127,128];

filenames = dir(sprintf('%s%s*', filepath, basename));

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
    evt = read_mff_event(sprintf('%s%s', filepath, filename));
    javarmpath(mffjarpath);
    
    firstsample = 0;
    lastsample = 0;
    sesscount = 1;
    for e = 1:length(evt)
        if strcmp(evt(e).type,'BGIN') && ~isempty(evt(e).codes) && sum(strcmp('BNUM',evt(e).codes(:,1))) == 1 && ...
                evt(e).codes{strcmp('BNUM',evt(e).codes(:,1)),2} == 1
            if sesscount == sessnum
                firstsample = evt(e).sample-1;
            else
                sesscount = sesscount+1;
            end
        end
        if firstsample > 0 && strcmp(evt(e).type,'BEND') && evt(e).codes{strcmp('BNUM',evt(e).codes(:,1)),2} == 10
            lastsample = evt(e).sample+1;
            break;
        end
    end
    
    EEG = pop_readegimff(sprintf('%s%s', filepath, filename),'firstsample',firstsample,'lastsample',lastsample);
end

EEG = eeg_checkset(EEG);

%%% preprocessing

fprintf('Removing excluded channels.\n');
EEG = pop_select(EEG,'nochannel',chanexcl);

%Downsample to 250Hz
if EEG.srate > 250
    EEG = pop_resample(EEG,250);
end

fprintf('Renaming markers.\n');
for e = 1:length(EEG.event)
    evtype = EEG.event(e).type;
    
    switch evtype
        case 'BGIN'
            stdcount = 0;
            prevdev = 0;
            firstdev = false;
            
        otherwise
            stimtype = str2double(evtype(4));
            if ~isempty(stimtype)
                switch stimtype
                    case 1
                        EEG.event(e).codes = cat(1,EEG.event(e).codes,{'SNUM',stdcount});
                        EEG.event(e).codes = cat(1,EEG.event(e).codes,{'PRED',prevdev});
                        if firstdev
                            stdcount = stdcount + 1;
                        end
                        
                    case {2,3}
                        if firstdev == false
                            firstdev = true;
                        end
                        prevdev = stimtype;
                        stdcount = 1;
                end
            end
    end
end

lpfreq = 20;
fprintf('Low-pass filtering below %dHz...\n',lpfreq);
EEG = pop_eegfilt(EEG, 0, lpfreq, [], [0], 0, 0, 'fir1', 0);
hpfreq = 0.5;
fprintf('High-pass filtering above %dHz...\n',hpfreq);
EEG = pop_eegfilt(EEG, hpfreq, 0, [], [0], 0, 0, 'fir1', 0);


EEG.setname = sprintf('%s_%d_orig',basename,sessnum);
EEG.filename = sprintf('%s_%d_orig.set',basename,sessnum);
EEG.filepath = filepath;

fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

