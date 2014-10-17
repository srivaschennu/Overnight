function bpower = bandpower(basename,channame,freqwin)

loadpaths

if ischar(basename)
    EEG = pop_loadset('filepath',filepath,'filename',[basename '.set']);
else
    EEG = basename;
    clear basename
end

bpower = squeeze(mean(EEG.spectra(strcmp(channame,{EEG.chanlocs.labels}),...
    EEG.freqs >= freqwin(1) & EEG.freqs <= freqwin(2),:),2));