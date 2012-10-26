function EEG = calcspec(EEG)

for e = 1:EEG.trials
    if e == 1
        [spectra, freqs] = spectopo(EEG.data(:,:,e),EEG.pnts,EEG.srate,'plot','off');
        EEG.spectra = zeros(EEG.nbchan,size(spectra,2),EEG.trials);
        EEG.freqs = freqs;
        fprintf('Calculating spectrum of epoch      \n');
    end
    fprintf('\b\b\b\b\b%5d',e);
    [~,EEG.spectra(:,:,e)] = evalc('spectopo(EEG.data(:,:,e),EEG.pnts,EEG.srate,''plot'',''off'')');
end