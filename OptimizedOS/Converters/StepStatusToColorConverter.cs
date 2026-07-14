using System.Globalization;
using System.Windows.Data;
using System.Windows.Media;

namespace OptimizedOS.Converters;

/// <summary>
/// Converts a StepStatus enum to a foreground color brush.
/// </summary>
public class StepStatusToColorConverter : IValueConverter
{
    private static readonly SolidColorBrush SuccessBrush = new(Color.FromRgb(107, 171, 110));
    private static readonly SolidColorBrush ErrorBrush = new(Color.FromRgb(199, 80, 80));
    private static readonly SolidColorBrush RunningBrush = new(Color.FromRgb(128, 128, 128));
    private static readonly SolidColorBrush PendingBrush = new(Color.FromRgb(85, 85, 85));

    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is StepStatus status)
        {
            return status switch
            {
                StepStatus.Completed => SuccessBrush,
                StepStatus.Failed => ErrorBrush,
                StepStatus.Running => RunningBrush,
                StepStatus.Pending => PendingBrush,
                _ => RunningBrush
            };
        }
        return RunningBrush;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}

/// <summary>
/// Converts an integer count to Visibility. 0 = Visible, anything else = Collapsed.
/// Used for the "empty state" message when no steps are shown.
/// </summary>
public class ZeroToVisibilityConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is int count)
            return count == 0 ? System.Windows.Visibility.Visible : System.Windows.Visibility.Collapsed;
        return System.Windows.Visibility.Collapsed;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}
