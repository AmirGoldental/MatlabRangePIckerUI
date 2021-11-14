function RangePickerHndl = RangePicker(Range, varargin)
Min = Range(1);
Max = Range(2);

p = inputParser;
p.addParameter('FigHndl', [])
p.addParameter('Position', [0.1 0.1 0.8 0.1])
p.addParameter('Color', [0.8 1 0.8])
p.addParameter('OnDrag', [])
p.addParameter('OnChange', [])
p.parse(varargin{:})
Position = p.Results.Position;
FigHndl = p.Results.FigHndl;
Color = p.Results.Color;
OnDrag = p.Results.OnDrag;
OnChange = p.Results.OnChange;

% OnChange is a function that recives: OnChange(Range)

RangePickerHndl = axes(FigHndl, 'Position', Position);


if isdatetime(Min)
    Min = datenum(Min);
    Max = datenum(Max);
    RangePickerHndl.UserData.Type = 'DateTime';
else
    RangePickerHndl.UserData.Type = 'double';
end

RangePickerHndl.UserData.Color = Color;
RangePickerHndl.XLim = [Min Max];
RangePickerHndl.YLim = [0 1];
RangePickerHndl.YTick = [];
RangePickerHndl.YTickLabel = [];
RangePickerHndl.LineWidth = eps;
RangePickerHndl.XAxis.TickLength = [0 0];
RangePickerHndl.Box = 'on';
RangePickerHndl.Toolbar = [];
RangePickerHndl.UserData.Range = [Min Max];
RangePickerHndl.UserData.OnChange = OnChange;
RangePickerHndl.UserData.OnDrag = OnDrag;
RenderDraggableArea(RangePickerHndl)
DragStop(RangePickerHndl)
end

function RenderDraggableArea(RangePickerHndl)
Min = RangePickerHndl.UserData.Range(1);
Max = RangePickerHndl.UserData.Range(2);
DraggableHndls.PatchHndl = patch(RangePickerHndl, [Min Min Max Max], ...
    RangePickerHndl.YLim([1 2 2 1]) , RangePickerHndl.UserData.Color, 'LineStyle', 'none', ...
    'zData', ones(1,4), 'FaceAlpha', 0.6);
CreateDragPatch = @(RangePickerHndl, Direction) patch(RangePickerHndl, ...
    'XData', [1 1 1], ... % this will change in update
    'YData', [0.0 1 0.5] * diff(double(RangePickerHndl.YLim)), ...
    'ZData', ones(1,3), ...
    'FaceColor', 4*[0.1 0.1 0.1], ...
    'LineWidth', eps);
DraggableHndls.MinPatch = CreateDragPatch(RangePickerHndl, -1);
DraggableHndls.MaxPatch = CreateDragPatch(RangePickerHndl, 1);

DraggableHndls.PatchHndl.ButtonDownFcn = @(~,~) DragStart(RangePickerHndl, 'Middle');
DraggableHndls.MinPatch.ButtonDownFcn = @(~,~) DragStart(RangePickerHndl, 'Min');
DraggableHndls.MaxPatch.ButtonDownFcn = @(~,~) DragStart(RangePickerHndl, 'Max');

RangePickerHndl.UserData.OringinalWindowButtonMotionFcn = ...
    RangePickerHndl.Parent.WindowButtonMotionFcn;
RangePickerHndl.UserData.OringinalWindowButtonUpFcn = ...
    RangePickerHndl.Parent.WindowButtonUpFcn;
% ToDo: RangePickerHndl.Parent.WindowScrollWheelFcn
RangePickerHndl.UserData.DraggableHndls = DraggableHndls;
UpdateRangePicker(RangePickerHndl)
end

function DragStart(RangePickerHndl, Side)
RangePickerHndl.UserData.OringinalWindowButtonMotionFcn = ...
    RangePickerHndl.Parent.WindowButtonMotionFcn;
RangePickerHndl.Parent.WindowButtonMotionFcn = @(~,~) Drag(RangePickerHndl, Side);

RangePickerHndl.UserData.OringinalWindowButtonUpFcn = ...
    RangePickerHndl.Parent.WindowButtonUpFcn;
RangePickerHndl.Parent.WindowButtonUpFcn = @(~,~) DragStop(RangePickerHndl);
end

function Drag(RangePickerHndl, Side)
CurrentPoint = get(RangePickerHndl, 'CurrentPoint');
X = CurrentPoint(1,1);
switch Side
    case 'Middle'
        if ~isfield(RangePickerHndl.UserData, 'DragInit')
            RangePickerHndl.UserData.DragInit.Point = X;
            RangePickerHndl.UserData.DragInit.Range = RangePickerHndl.UserData.Range;
        end
        RangePickerHndl.UserData.Range = RangePickerHndl.UserData.DragInit.Range + X - RangePickerHndl.UserData.DragInit.Point;
    case 'Min'
        %X = max(RangePickerHndl.XLim(1), X);
        X = min(X, RangePickerHndl.UserData.Range(2));
        RangePickerHndl.UserData.Range(1) = X;
    case 'Max'
        %X = min(RangePickerHndl.XLim(2), X);
        X = max(X, RangePickerHndl.UserData.Range(1));
        RangePickerHndl.UserData.Range(2) = X;
    otherwise
        error('Unknown Side')
end
UpdateRangePicker(RangePickerHndl);
if ~isempty(RangePickerHndl.UserData.OnDrag)
    RangePickerHndl.UserData.OnDrag(RangePickerHndl.UserData.Range);
end
end

function UpdateRangePicker(RangePickerHndl)
DraggableHndls = RangePickerHndl.UserData.DraggableHndls;
Min = RangePickerHndl.UserData.Range(1);
Max = RangePickerHndl.UserData.Range(2);
if strcmpi(RangePickerHndl.UserData.Type, 'DateTime')
    title(RangePickerHndl, ...
        [datestr(Min, '[dd/mm/yy] HH:MM') '  -  ' datestr(Max, '[dd/mm/yy] HH:MM')], ...
        'FontWeight', 'normal', 'FontSize', 13)
else
    title(RangePickerHndl, [num2str(Min) '  \Rightarrow  ' num2str(Max)], ...
        'FontWeight', 'normal', 'FontSize', 13)
end
DraggableHndls.PatchHndl.XData =  [Min Min Max Max];
DraggableHndls.MinPatch.XData = Min - ([0.00 0.00 0.02] * diff(double(RangePickerHndl.XLim)));
DraggableHndls.MaxPatch.XData = Max + ([0.00 0.00 0.02] * diff(double(RangePickerHndl.XLim)));
end

function DragStop(RangePickerHndl)
if isfield(RangePickerHndl.UserData, 'DragInit')
    RangePickerHndl.UserData = rmfield(RangePickerHndl.UserData, 'DragInit');
end
RangePickerHndl.Parent.WindowButtonMotionFcn = ...
    RangePickerHndl.UserData.OringinalWindowButtonMotionFcn;
RangePickerHndl.Parent.WindowButtonUpFcn = ...
    RangePickerHndl.UserData.OringinalWindowButtonUpFcn;

Min = RangePickerHndl.UserData.Range(1);
Max = RangePickerHndl.UserData.Range(2);
if Max > RangePickerHndl.XLim(2) - 0.1*diff(double(RangePickerHndl.XLim))
    RangePickerHndl.XLim(2) = Max + 0.4*diff(double(RangePickerHndl.XLim));
    SetupXAxes(RangePickerHndl)
    UpdateRangePicker(RangePickerHndl)
end
if Min < RangePickerHndl.XLim(1) + 0.1*diff(double(RangePickerHndl.XLim))
    RangePickerHndl.XLim(1) = Min - 0.4*diff(double(RangePickerHndl.XLim));
    SetupXAxes(RangePickerHndl)
    UpdateRangePicker(RangePickerHndl)
end
if (Max-Min)/diff(RangePickerHndl.XLim) < 0.1
    RangePickerHndl.XLim = mean([Min Max]) + 1.61*[-0.5, 0.5]*diff([Min Max]);
    SetupXAxes(RangePickerHndl)
    UpdateRangePicker(RangePickerHndl)
end

if ~isempty(RangePickerHndl.UserData.OnChange)
    RangePickerHndl.UserData.OnChange(RangePickerHndl.UserData.Range);
end

    function SetupXAxes(RangePickerHndl)
        if strcmpi(RangePickerHndl.UserData.Type, 'DateTime')
            xticks('auto')
            xticklabels('auto')
            datetick('x', 'keeplimits')
        end
    end
end