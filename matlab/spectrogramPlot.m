function spectrogramPlot(t, w, s, plotTitle, filename)
    surf(t, w, 20*log10(abs(s)), 'EdgeColor', 'none');
    axis xy;
    axis tight;
    colormap jet;
    view(0, 90);
    xlabel('Time (s)');
    colorbar;
    ylabel('Frequency (Hz)');
    title(plotTitle);
    print(filename, '-dpng');
end
