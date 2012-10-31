function EEG = calcspec(EEG)

for e = 1:EEG.trials
    if e == 1
        [spectra, freqs] = spectopo(EEG.data(:,:,e),EEG.pnts,EEG.srate,'plot','off');
        EEG.spectra = zeros(EEG.nbchan,size(spectra,2),EEG.trials);
        EEG.freqs = freqs;
        wb_h = waitbar(e/EEG.trials,sprintf('Calculating spectrum of epoch %d',e),'Name',mfilename);
    else
        waitbar(e/EEG.trials,wb_h,sprintf('Calculating spectrum of epoch %d',e));
    end
    [~,EEG.spectra(:,:,e)] = evalc('spectopo(EEG.data(:,:,e),EEG.pnts,EEG.srate,''plot'',''off'')');
end
close(wb_h);