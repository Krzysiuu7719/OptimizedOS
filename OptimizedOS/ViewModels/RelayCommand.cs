using System.Windows.Input;

namespace OptimizedOS.ViewModels;

/// <summary>
/// A reusable ICommand implementation that supports async operations.
/// Fire-and-forget async execution to avoid deadlocking the UI thread.
/// </summary>
public class RelayCommand : ICommand
{
    private readonly Func<object?, Task>? _executeAsync;
    private readonly Action<object?>? _execute;
    private readonly Func<object?, bool>? _canExecute;
    private bool _isExecuting;

    public RelayCommand(Action<object?> execute, Func<object?, bool>? canExecute = null)
    {
        _execute = execute ?? throw new ArgumentNullException(nameof(execute));
        _canExecute = canExecute;
    }

    public RelayCommand(Func<Task> executeAsync, Func<object?, bool>? canExecute = null)
    {
        if (executeAsync == null) throw new ArgumentNullException(nameof(executeAsync));
        _executeAsync = _ => executeAsync();
        _canExecute = canExecute;
    }

    public event EventHandler? CanExecuteChanged
    {
        add => CommandManager.RequerySuggested += value;
        remove => CommandManager.RequerySuggested -= value;
    }

    public bool CanExecute(object? parameter)
    {
        if (_isExecuting) return false;
        return _canExecute?.Invoke(parameter) ?? true;
    }

    public async void Execute(object? parameter)
    {
        if (_isExecuting) return;

        _isExecuting = true;
        CommandManager.InvalidateRequerySuggested();

        try
        {
            if (_executeAsync != null)
                await _executeAsync(parameter);
            else
                _execute?.Invoke(parameter);
        }
        finally
        {
            _isExecuting = false;
            CommandManager.InvalidateRequerySuggested();
        }
    }

    public void RaiseCanExecuteChanged()
    {
        CommandManager.InvalidateRequerySuggested();
    }
}
