using System.Text.Json;
using System.Text.Json.Serialization;

namespace OptimizedOS.Models;

/// <summary>
/// Represents the root manifest downloaded from GitHub.
/// Contains the version and all optimization steps to execute.
/// </summary>
public class Manifest
{
    [JsonPropertyName("version")]
    public string Version { get; set; } = string.Empty;

    [JsonPropertyName("steps")]
    public List<OptimizationStep> Steps { get; set; } = new();

    /// <summary>
    /// Deserializes a JSON string into a Manifest object.
    /// </summary>
    public static Manifest? FromJson(string json)
    {
        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
        return JsonSerializer.Deserialize<Manifest>(json, options);
    }
}

/// <summary>
/// Represents a single optimization step from the manifest.
/// Each step has a name, type, and either a file reference or inline commands.
/// </summary>
public class OptimizationStep
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty;

    [JsonPropertyName("file")]
    public string? File { get; set; }

    [JsonPropertyName("commands")]
    public List<string>? Commands { get; set; }

    [JsonPropertyName("arguments")]
    public string? Arguments { get; set; }
}

/// <summary>
/// Represents the result of executing an optimization step.
/// </summary>
public class StepResult
{
    public string StepName { get; set; } = string.Empty;
    public bool Success { get; set; }
    public string? ErrorMessage { get; set; }
    public TimeSpan Duration { get; set; }
}
