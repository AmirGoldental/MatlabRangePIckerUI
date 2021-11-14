f = figure;
RangePicker([datetime()-4, datetime()],...
    'FigHndl', f, 'OnChange',  @(Range) disp(Range))
RangePicker([0, 1], 'Position', [0.1 0.3 0.8 0.05],...
    'FigHndl', f, 'Color', [0.5 0.5 0.5], 'OnDrag', @(Range) disp(Range))