using System.Diagnostics;
using OptimizedOS.Models;
using OptimizedOS.Converters;

namespace OptimizedOS.Services;

public class ExecutionService
{
    private readonly LogService _log;
    private const int DefaultTimeoutMinutes = 5;

    public ExecutionService(LogService log)
    {
        _log = log;
    }

    public async Task<StepResult> ExecuteStepAsync(PreparedStep preparedStep)
    {
        var step = preparedStep.OriginalStep;
        var result = new StepResult { StepName = step.Name };
        var stopwatch = Stopwatch.StartNew();

        try
        {
            if (preparedStep.ErrorMessage != null)
            {
                result.Success = false;
                result.ErrorMessage = preparedStep.ErrorMessage;
                return result;
            }

            _log.Info($"Executing step: {step.Name} (type={step.Type})");

            result.Success = step.Type.ToLowerInvariant() switch
            {
                "reg" => await ExecuteRegistryAsync(preparedStep),
                "powershell" => await ExecutePowerShellAsync(preparedStep),
                "cmd" => await ExecuteCmdAsync(step, preparedStep),
                "exe" => await ExecuteExeAsync(preparedStep),
                _ => throw new InvalidOperationException($"Unknown step type: {step.Type}")
            };
        }
        catch (Exception ex)
        {
            result.Success = false;
            result.ErrorMessage = ex.Message;
            _log.Error($"Step '{step.Name}' threw an exception", ex);
        }
        finally
        {
            stopwatch.Stop();
            result.Duration = stopwatch.Elapsed;
            _log.Step(step.Name, result.Success, result.Duration, result.ErrorMessage);
        }

        return result;
    }

    private async Task<bool> ExecuteRegistryAsync(PreparedStep prepared)
    {
        var filePath = prepared.LocalFilePath ?? throw new InvalidOperationException("No local file path for reg step");

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "regedit.exe",
                Arguments = $"/s \"{filePath}\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            }
        };

        return await RunProcessAsync(process);
    }

    private async Task<bool> ExecutePowerShellAsync(PreparedStep prepared)
    {
        var filePath = prepared.LocalFilePath ?? throw new InvalidOperationException("No local file path for powershell step");

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = $"-ExecutionPolicy Bypass -NoProfile -NonInteractive -File \"{filePath}\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            }
        };

        return await RunProcessAsync(process);
    }

    private async Task<bool> ExecuteCmdAsync(OptimizationStep step, PreparedStep? prepared = null)
    {
        if (prepared?.LocalFilePath != null)
        {
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c \"{prepared.LocalFilePath}\"",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WindowStyle = ProcessWindowStyle.Hidden,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                }
            };
            return await RunProcessAsync(process);
        }

        if (step.Commands == null || step.Commands.Count == 0)
        {
            _log.Warning($"Step '{step.Name}' has no commands to execute");
            return true;
        }

        bool allSucceeded = true;

        foreach (var command in step.Commands)
        {
            _log.Info($"  CMD: {command}");

            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c {command}",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WindowStyle = ProcessWindowStyle.Hidden,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                }
            };

            var success = await RunProcessAsync(process);
            if (!success)
            {
                _log.Warning($"  CMD command failed: {command}");
                allSucceeded = false;
            }
        }

        return allSucceeded;
    }

    private async Task<bool> ExecuteExeAsync(PreparedStep prepared)
    {
        var filePath = prepared.LocalFilePath ?? throw new InvalidOperationException("No local file path for exe step");

        var arguments = prepared.OriginalStep.Arguments ?? string.Empty;

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = filePath,
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            }
        };

        return await RunProcessAsync(process);
    }

    private async Task<bool> RunProcessAsync(Process process)
    {
        var timeout = TimeSpan.FromMinutes(DefaultTimeoutMinutes);
        var stdout = string.Empty;
        var stderr = string.Empty;

        try
        {
            process.Start();

            var stdoutTask = process.StandardOutput.ReadToEndAsync();
            var stderrTask = process.StandardError.ReadToEndAsync();

            using var cts = new CancellationTokenSource(timeout);
            try
            {
                await process.WaitForExitAsync(cts.Token);
            }
            catch (OperationCanceledException)
            {
                _log.Warning($"Process timed out after {timeout.TotalMinutes} minutes: {process.StartInfo.FileName} {process.StartInfo.Arguments}");
                try { process.Kill(entireProcessTree: true); } catch { }
                return false;
            }

            stdout = await stdoutTask;
            stderr = await stderrTask;

            if (!string.IsNullOrWhiteSpace(stdout))
            {
                foreach (var line in stdout.Split('\n', StringSplitOptions.RemoveEmptyEntries))
                    _log.Info($"  [output] {line.TrimEnd('\r')}");
            }

            if (!string.IsNullOrWhiteSpace(stderr))
            {
                foreach (var line in stderr.Split('\n', StringSplitOptions.RemoveEmptyEntries))
                    _log.Warning($"  [stderr] {line.TrimEnd('\r')}");
            }

            var success = process.ExitCode == 0;
            if (!success)
                _log.Warning($"Process exited with code: {process.ExitCode}");

            return success;
        }
        catch (Exception ex)
        {
            _log.Error($"Failed to start process: {process.StartInfo.FileName}", ex);
            return false;
        }
        finally
        {
            process.Dispose();
        }
    }
}
