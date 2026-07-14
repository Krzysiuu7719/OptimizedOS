using System.IO;
using System.Net.Http;
using OptimizedOS.Models;

namespace OptimizedOS.Services;

/// <summary>
/// Downloads manifest and files from a remote URL (GitHub) or local directory.
/// Supports both HTTP URLs and local file paths for testing.
/// </summary>
public class GitHubService
{
    private readonly HttpClient _http;
    private readonly LogService _log;
    private readonly string _baseDirectory;
    private readonly string _sourceUrl;
    private readonly bool _isLocalSource;

    public GitHubService(LogService log, string sourceUrl)
    {
        _log = log;
        _sourceUrl = sourceUrl.TrimEnd('/');
        _isLocalSource = !sourceUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase);
        _baseDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "OptimizedOS");

        _http = new HttpClient();
        _http.DefaultRequestHeaders.Add("User-Agent", "OptimizedOS/1.0");
        _http.Timeout = TimeSpan.FromMinutes(5);
    }

    /// <summary>
    /// Downloads and parses the manifest.json.
    /// </summary>
    public async Task<Manifest?> DownloadManifestAsync()
    {
        _log.Info($"Loading manifest from: {_sourceUrl}");

        try
        {
            string json;

            if (_isLocalSource)
            {
                var manifestPath = Path.Combine(_sourceUrl, "manifest.json");
                json = await File.ReadAllTextAsync(manifestPath);
                _log.Info($"Read local manifest: {manifestPath}");
            }
            else
            {
                var url = $"{_sourceUrl}/manifest.json";
                json = await _http.GetStringAsync(url);
                _log.Info($"Downloaded manifest: {url}");
            }

            var manifest = Manifest.FromJson(json);

            if (manifest == null)
            {
                _log.Error("Failed to parse manifest: returned null");
                return null;
            }

            _log.Info($"Manifest parsed: version={manifest.Version}, {manifest.Steps.Count} steps");
            return manifest;
        }
        catch (Exception ex)
        {
            _log.Error("Failed to load manifest", ex);
            return null;
        }
    }

    /// <summary>
    /// Downloads/copies all files referenced by manifest steps.
    /// Returns prepared steps with resolved local file paths.
    /// </summary>
    public async Task<List<PreparedStep>> PrepareStepsAsync(Manifest manifest, IProgress<(string stepName, int current, int total, bool isFile)>? progress = null)
    {
        var preparedSteps = new List<PreparedStep>();
        var totalSteps = manifest.Steps.Count;

        for (int i = 0; i < totalSteps; i++)
        {
            var step = manifest.Steps[i];
            progress?.Report((step.Name, i + 1, totalSteps, false));

            var prepared = new PreparedStep
            {
                OriginalStep = step,
                LocalFilePath = null
            };

            if (!string.IsNullOrEmpty(step.File))
            {
                var localPath = Path.Combine(_baseDirectory, step.File.Replace('/', '\\'));
                var directory = Path.GetDirectoryName(localPath);

                if (directory != null)
                    Directory.CreateDirectory(directory);

                try
                {
                    if (_isLocalSource)
                    {
                        var sourcePath = Path.Combine(_sourceUrl, step.File.Replace('/', '\\'));
                        File.Copy(sourcePath, localPath, overwrite: true);
                        var fi = new FileInfo(localPath);
                        _log.Info($"Copied: {step.File} ({fi.Length} bytes)");
                    }
                    else
                    {
                        var fileUrl = !string.IsNullOrEmpty(step.Url)
                            ? step.Url
                            : $"{_sourceUrl}/{step.File}";
                        _log.Info($"Downloading: {fileUrl}");

                        var response = await _http.GetAsync(fileUrl);
                        response.EnsureSuccessStatusCode();

                        var bytes = await response.Content.ReadAsByteArrayAsync();
                        await File.WriteAllBytesAsync(localPath, bytes);
                        _log.Info($"Downloaded: {step.File} ({bytes.Length} bytes)");
                    }

                    prepared.LocalFilePath = localPath;
                }
                catch (Exception ex)
                {
                    _log.Error($"Failed to get file: {step.File}", ex);
                    prepared.ErrorMessage = $"File acquisition failed: {ex.Message}";
                }
            }

            preparedSteps.Add(prepared);
        }

        progress?.Report(("Files ready", totalSteps, totalSteps, true));
        return preparedSteps;
    }

    /// <summary>
    /// Ensures the base working directory exists.
    /// </summary>
    public void EnsureDirectories()
    {
        Directory.CreateDirectory(_baseDirectory);
        Directory.CreateDirectory(Path.Combine(_baseDirectory, "scripts"));
        Directory.CreateDirectory(Path.Combine(_baseDirectory, "files"));
        Directory.CreateDirectory(Path.Combine(_baseDirectory, "logs"));
    }
}

/// <summary>
/// A step prepared with a resolved local file path, ready for execution.
/// </summary>
public class PreparedStep
{
    public OptimizationStep OriginalStep { get; set; } = new();
    public string? LocalFilePath { get; set; }
    public string? ErrorMessage { get; set; }
}
