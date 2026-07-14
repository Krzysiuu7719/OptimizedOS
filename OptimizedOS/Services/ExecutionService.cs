using System.Diagnostics;
using OptimizedOS.Models;
using OptimizedOS.Converters;

namespace OptimizedOS.Services;

/// <summary>
/// Executes optimization steps based on their type (reg, powershell, cmd, exe).
/// </summary>
public class ExecutionService
{
    private readonly LogService _log;

    public ExecutionService(LogService log)
    {
        _log = log;
    }

    /// <summary>
    /// Executes a prepared step and returns the result.
    /// </summary>
    public async Task<StepResult> ExecuteStepAsync(PreparedStep preparedStep)
    {
        var step = preparedStep.OriginalStep;
        var result = new StepResult { StepName = step.Name };
        var stopwatch = Stopwatch.StartNew();

        try
        {
            // If download failed earlier, skip execution
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

    /// <summary>
    /// Executes a .reg file silently using regedit.
    /// </summary>
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
                WindowStyle = ProcessWindowStyle.Hidden
            }
        };

        return await RunProcessAsync(process);
    }

    /// <summary>
    /// Executes a PowerShell script with -ExecutionPolicy Bypass.
    /// </summary>
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
                WindowStyle = ProcessWindowStyle.Hidden
            }
        };

        return await RunProcessAsync(process);
    }

    /// <summary>
    /// Executes a .cmd file or inline CMD commands.
    /// </summary>
    private async Task<bool> ExecuteCmdAsync(OptimizationStep step, PreparedStep? prepared = null)
    {
        // If a file is provided, run the .cmd file directly
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
                    WindowStyle = ProcessWindowStyle.Hidden
                }
            };
            return await RunProcessAsync(process);
        }

        // Otherwise run inline commands
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
                    WindowStyle = ProcessWindowStyle.Hidden
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

    /// <summary>
    /// Runs an external executable with optional arguments.
    /// </summary>
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
                WindowStyle = ProcessWindowStyle.Hidden
            }
        };

        return await RunProcessAsync(process);
    }

    /// <summary>
    /// Starts a process, waits for it to exit, and returns whether it succeeded.
    /// </summary>
    private async Task<bool> RunProcessAsync(Process process)
    {
        try
        {
            process.Start();
            await process.WaitForExitAsync();

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
