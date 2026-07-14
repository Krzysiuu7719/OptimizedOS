using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using OptimizedOS.Converters;

namespace OptimizedOS.ViewModels;

/// <summary>
/// A single log line displayed in the UI.
/// </summary>
public class LogEntry
{
    public string Text { get; set; } = string.Empty;
}

/// <summary>
/// Main ViewModel. Orchestrates download, execution and live log display.
/// </summary>
public class MainViewModel : BaseViewModel
{
    private const string GitHubBaseUrl = "https://raw.githubusercontent.com/Krzysiuu7719/OptimizedOS/main";

    private readonly Services.LogService _logService;
    private readonly Services.GitHubService _gitHubService;
    private readonly Services.ExecutionService _executionService;

    private bool _isRunning;
    private bool _isFinished;
    private bool _isVersionVisible;
    private double _progress;
    private string _statusText = "Ready";
    private string _manifestVersion = string.Empty;

    public ObservableCollection<LogEntry> LogLines { get; } = new();

    public RelayCommand StartCommand { get; }
    public RelayCommand RestartCommand { get; }

    public MainViewModel()
    {
        _logService = new Services.LogService();
        _gitHubService = new Services.GitHubService(_logService, GitHubBaseUrl);
        _executionService = new Services.ExecutionService(_logService);

        // Wire log lines to the observable collection
        _logService.OnLogLine += line =>
        {
            App.Current?.Dispatcher.Invoke(() =>
            {
                LogLines.Add(new LogEntry { Text = line });
            });
        };

        StartCommand = new RelayCommand(ExecuteOptimizationAsync, _ => !IsRunning && !IsFinished);
        RestartCommand = new RelayCommand(_ => RestartPc());

        _logService.Initialize();
    }

    public bool IsRunning
    {
        get => _isRunning;
        set { SetProperty(ref _isRunning, value); StartCommand.RaiseCanExecuteChanged(); }
    }

    public bool IsFinished
    {
        get => _isFinished;
        set { SetProperty(ref _isFinished, value); StartCommand.RaiseCanExecuteChanged(); }
    }

    public bool IsVersionVisible
    {
        get => _isVersionVisible;
        set => SetProperty(ref _isVersionVisible, value);
    }

    public double Progress
    {
        get => _progress;
        set => SetProperty(ref _progress, value);
    }

    public string StatusText
    {
        get => _statusText;
        set => SetProperty(ref _statusText, value);
    }

    public string ManifestVersion
    {
        get => _manifestVersion;
        set { SetProperty(ref _manifestVersion, value); IsVersionVisible = !string.IsNullOrEmpty(value); }
    }

    private async Task ExecuteOptimizationAsync()
    {
        IsRunning = true;
        LogLines.Clear();
        Progress = 0;

        try
        {
            StatusText = "Preparing...";
            _gitHubService.EnsureDirectories();

            StatusText = "Downloading manifest...";
            var manifest = await _gitHubService.DownloadManifestAsync();

            if (manifest == null)
            {
                StatusText = "Failed to download manifest.";
                _logService.Error("Manifest download failed. Aborting.");
                return;
            }

            ManifestVersion = $"v{manifest.Version}";
            _logService.Info($"Manifest loaded: {ManifestVersion}");

            StatusText = "Downloading files...";
            var fileProgress = new Progress<(string stepName, int current, int total, bool isFile)>(report =>
            {
                Progress = (double)report.current / report.total * 50;
                StatusText = $"Downloading: {report.stepName} ({report.current}/{report.total})";
            });

            var preparedSteps = await _gitHubService.PrepareStepsAsync(manifest, fileProgress);

            StatusText = "Executing optimizations...";
            Progress = 50;

            var totalSteps = preparedSteps.Count;
            var completedCount = 0;

            foreach (var prepared in preparedSteps)
            {
                StatusText = $"Executing: {prepared.OriginalStep.Name}";
                var result = await _executionService.ExecuteStepAsync(prepared);
                completedCount++;
                Progress = 50.0 + ((double)completedCount / totalSteps * 50.0);
            }

            StatusText = "Optimization completed!";
            IsFinished = true;
            _logService.Info("All steps completed.");
        }
        catch (Exception ex)
        {
            StatusText = $"Error: {ex.Message}";
            _logService.Error("Optimization flow failed", ex);
        }
        finally
        {
            IsRunning = false;
        }
    }

    private void RestartPc()
    {
        _logService.Info("User initiated restart.");
        System.Diagnostics.Process.Start("shutdown", "/r /t 0");
    }
}
