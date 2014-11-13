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

% bpower = squeeze(mean(mean(EEG.spectra(:,EEG.freqs >= freqwin(1) & EEG.freqs <= freqwin(2),:),1),2));

smoothwin = 10;
smoothed_bpower = zeros(size(bpower));
for e = 1:length(bpower)-smoothwin+1
    smoothed_bpower(e:e+smoothwin-1) = mean(bpower(e:e+smoothwin-1));
end
bpower = smoothed_bpower;

bpower = (bpower/mean(bpower))*100;