function bpower = bandpower(EEG,channame,freqwin)

bpower = squeeze(mean(EEG.spectra(strcmp(channame,{EEG.chanlocs.labels}),...
    EEG.freqs >= freqwin(1) & EEG.freqs <= freqwin(2),:),2));