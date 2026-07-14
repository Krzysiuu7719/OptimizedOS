using System.Globalization;
using System.Windows.Data;

namespace OptimizedOS.Converters;

/// <summary>
/// Converts a StepStatus enum to a display string with an icon.
/// </summary>
public class StepStatusToIconConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is StepStatus status)
        {
            return status switch
            {
                StepStatus.Completed => "\u2714",   // ✔
                StepStatus.Failed => "\u2718",       // ✘
                StepStatus.Running => "\u23F3",      // ⏳
                StepStatus.Pending => "\u2014",      // —
                _ => string.Empty
            };
        }
        return string.Empty;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}

public enum StepStatus
{
    Pending,
    Running,
    Completed,
    Failed
}
