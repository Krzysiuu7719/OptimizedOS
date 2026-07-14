using System.Diagnostics;
using System.IO;

namespace OptimizedOS.Services;

/// <summary>
/// Handles logging to file and broadcasting log lines to the UI.
/// </summary>
public class LogService
{
    private readonly string _logDirectory;
    private readonly string _logFilePath;
    private readonly object _lock = new();

    /// <summary>
    /// Fires on every log line so the ViewModel can feed the UI.
    /// </summary>
    public event Action<string>? OnLogLine;

    public LogService()
    {
        _logDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "OptimizedOS", "logs");
        _logFilePath = Path.Combine(_logDirectory, "latest.log");
    }

    public void Initialize()
    {
        Directory.CreateDirectory(_logDirectory);
        File.WriteAllText(_logFilePath, $"=== OptimizedOS Log - {DateTime.Now:yyyy-MM-dd HH:mm:ss} ==={Environment.NewLine}");
        Info("Log initialized");
    }

    public void Info(string message) => WriteLog("INFO", message);

    public void Warning(string message) => WriteLog("WARN", message);

    public void Error(string message, Exception? ex = null)
    {
        var fullMessage = ex != null ? $"{message}: {ex.Message}" : message;
        WriteLog("ERROR", fullMessage);
    }

    public void Step(string stepName, bool success, TimeSpan duration, string? error = null)
    {
        var status = success ? "OK" : "FAIL";
        var msg = $"{status} {stepName} ({duration.TotalSeconds:F1}s)";
        if (error != null)
            msg += $" - {error}";

        WriteLog("STEP", msg);
    }

    private void WriteLog(string level, string message)
    {
        var timestamp = DateTime.Now.ToString("HH:mm:ss");
        var logLine = $"[{timestamp}] {message}";

        lock (_lock)
        {
            try
            {
                File.AppendAllText(_logFilePath, logLine + Environment.NewLine);
            }
            catch
            {
                Debug.WriteLine($"[LOG FAILED] {logLine}");
            }
        }

        OnLogLine?.Invoke(logLine);
    }
}
