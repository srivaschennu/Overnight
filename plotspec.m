function plotspec(EEG,freqwin)

fontsize = 16;
chanlist = {'Fp2','Fz','Fp1','F3','F7','C3','T3','P3','T5','Pz','O1','Oz','O2','P4','T6','C4','T4','F8','F4'};

for c = 1:length(chanlist)
    chanidx(c) = find(strcmp(chanlist{c},{EEG.chanlocs.labels}));
end

figure('Name',EEG.setname);
figpos = get(gcf,'Position');
set(gcf,'Position',[figpos(1) figpos(2) figpos(3)*2 figpos(4)*2]);

plot(EEG.freqs,mean(EEG.spectra(chanidx,:,:),3),'LineWidth',1.5);
set(gca,'XLim',[0 40],'FontSize',fontsize);
xlabel('Frequency (Hz)','FontSize',fontsize);
ylabel('Power (dB)','FontSize',fontsize);

ylimits = ylim;
legend(chanlist);

if exist('freqwin','var')
    for f = 1:length(freqwin)
        line([freqwin(f) freqwin(f)],[ylimits(1) ylimits(2)],'LineStyle',':','Color','blue','LineWidth',1);
    end
end
