using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using EdBindings.Model;
using EdBindings.Model.BindingsRaw;

namespace EdBindings;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    /// <summary>
    /// The place holder text
    /// </summary>
    private const string PlaceHolderText = "Search bindings...";

    /// <summary>
    /// Gets or sets the binding file.
    /// </summary>
    /// <value>The binding file.</value>
    private BindingFile? BindingFile { get; set; }

    /// <summary>
    /// Gets or sets the device map.
    /// </summary>
    /// <value>The device map.</value>
    private DeviceMap? DeviceMap { get; set; }

    /// <summary>
    /// Gets or sets the key bindings.
    /// </summary>
    /// <value>The key bindings.</value>
    private ICollectionView? KeyBindings { get; set; }

    /// <summary>
    /// Gets or sets the action mapping.
    /// </summary>
    /// <value>The action mapping.</value>
    private List<ActionMapping>? ActionMappings { get; set; }

    /// <summary>
    /// Initializes a new instance of the <see cref="MainWindow"/> class.
    /// </summary>
    public MainWindow()
    {
        InitializeComponent();

        try
        {
            var actionMappingsPath = Path.GetFullPath(@".\ActionMappings.json");
            if (File.Exists(actionMappingsPath))
            {
                ActionMappings = ActionMapping.Open(actionMappingsPath);
            }
            else
            {
                MessageBox.Show($"ActionMappings.json file not found at: {actionMappingsPath}",
                    "Warning", MessageBoxButton.OK, MessageBoxImage.Warning);
                ActionMappings = new List<ActionMapping>();
            }

            var deviceMappingsPath = @".\DeviceMappings";
            if (Directory.Exists(deviceMappingsPath))
            {
                var deviceMappingFiles = Directory.GetFiles(deviceMappingsPath, "*.json");

                foreach (var deviceMappingFile in deviceMappingFiles)
                {
                    try
                    {
                        var deviceMapping = DeviceMap.Open(deviceMappingFile);
                        var menuItem = new MenuItem
                        {
                            Header = deviceMapping.Name,
                            DataContext = deviceMapping,
                            IsCheckable = true
                        };
                        menuItem.Click += DeviceMapSelected;

                        DeviceMappingMenu.Items.Add(menuItem);
                    }
                    catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or JsonException or InvalidOperationException)
                    {
                        MessageBox.Show($"Error loading device mapping file {deviceMappingFile}: {ex.Message}",
                            "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show($"DeviceMappings directory not found: {Path.GetFullPath(deviceMappingsPath)}",
                    "Warning", MessageBoxButton.OK, MessageBoxImage.Warning);
            }

            if (DeviceMappingMenu.Items.Count > 0)
            {
                var selectedIndex = Math.Max(0, Math.Min(ApplicationSettings.Default.DeviceMapSelection, DeviceMappingMenu.Items.Count - 1));
                SelectActiveDeviceMapping(selectedIndex);
            }
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or InvalidOperationException or DirectoryNotFoundException)
        {
            MessageBox.Show($"Error during initialization: {ex.Message}",
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    /// <summary>
    /// Devices the map selected.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void DeviceMapSelected(object sender, RoutedEventArgs e)
    {
        var selectedIndex = DeviceMappingMenu.Items.IndexOf(sender);
        if (selectedIndex >= 0)
        {
            SelectActiveDeviceMapping(selectedIndex);
        }
    }

    /// <summary>
    /// Selects the active device mapping.
    /// </summary>
    /// <param name="index">The index.</param>
    private void SelectActiveDeviceMapping(int index)
    {
        if (index < 0 || index >= DeviceMappingMenu.Items.Count)
        {
            return;
        }

        try
        {
            var menuItem = (MenuItem)DeviceMappingMenu.Items[index];
            DeviceMap = (DeviceMap?)menuItem.DataContext;

            foreach (MenuItem item in DeviceMappingMenu.Items.OfType<MenuItem>())
            {
                item.IsChecked = false;
            }

            menuItem.IsChecked = true;

            if (index != ApplicationSettings.Default.DeviceMapSelection)
            {
                ApplicationSettings.Default.DeviceMapSelection = index;
                ApplicationSettings.Default.Save();
            }

            DeviceFileStatusBar.Text = $"Device Mapping: {menuItem.Header}";
            ProcessBindingFile();
        }
        catch (Exception ex) when (ex is InvalidOperationException or ArgumentException or IOException)
        {
            MessageBox.Show($"Error selecting device mapping: {ex.Message}",
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    /// <summary>
    /// Files the exit menu item click.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void FileExitMenuItemClick(object sender, RoutedEventArgs e) => Close();

    /// <summary>
    /// Files the open bindings menu item click.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void FileOpenBindingsMenuItemClick(object sender, RoutedEventArgs e)
    {
        try
        {
            var dialog = new Microsoft.Win32.OpenFileDialog
            {
                DefaultExt = ".binds",
                InitialDirectory = Environment.ExpandEnvironmentVariables(@"%localappdata%\Frontier Developments\Elite Dangerous\Options\Bindings"),
                Filter = "Bindings (*.binds)|*.binds|All files (*.*)|*.*"
            };

            if (dialog.ShowDialog() == true && !string.IsNullOrEmpty(dialog.FileName))
            {
                BindingFile = BindingFile.Open(dialog.FileName);
                ProcessBindingFile();
            }
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or InvalidOperationException or FileNotFoundException)
        {
            MessageBox.Show($"Error opening bindings file: {ex.Message}",
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    /// <summary>
    /// Processes the binding file.
    /// </summary>
    private void ProcessBindingFile()
    {
        if (BindingFile == null || DeviceMap == null || ActionMappings == null)
        {
            return;
        }

        try
        {
            var justBindingGroups = BindingFile.Bindings
                .OfType<EdBindings.Model.BindingsRaw.Bindings.BindingGroup>()
                .ToList();

            var dataSource = justBindingGroups
                .Select(group => KeyBindingView.MakeKeyBindingView(group, DeviceMap, ActionMappings))
                .ToList();

            var filterable = new CollectionViewSource { Source = new ObservableCollection<KeyBindingView>(dataSource) };
            KeyBindings = filterable.View;

            KeyBindingDataGrid.ItemsSource = KeyBindings;
            BindingFileStatusBar.Text = Path.GetFileName(BindingFile.FileName);
            KeyboardLayoutStatusBar.Text = BindingFile.KeyboardLayout;
            txtFilter.Text = PlaceHolderText;
        }
        catch (Exception ex) when (ex is InvalidOperationException or ArgumentException or NullReferenceException)
        {
            MessageBox.Show($"Error processing binding file: {ex.Message}",
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    /// <summary>
    /// Texts the filter key up.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="System.Windows.Input.KeyEventArgs"/> instance containing the event data.</param>
    private void TxtFilterKeyUp(object sender, System.Windows.Input.KeyEventArgs e)
    {
        if (KeyBindings == null)
        {
            return;
        }

        var filterText = txtFilter.Text ?? string.Empty;

        if (string.IsNullOrWhiteSpace(filterText) || filterText == PlaceHolderText)
        {
            KeyBindings.Filter = null;
        }
        else
        {
            KeyBindings.Filter = item =>
            {
                if (item is not KeyBindingView binding)
                {
                    return false;
                }

                return binding.Action?.Contains(filterText, StringComparison.InvariantCultureIgnoreCase) == true
                    || binding.PrimaryKey?.Contains(filterText, StringComparison.InvariantCultureIgnoreCase) == true
                    || binding.SecondaryKey?.Contains(filterText, StringComparison.InvariantCultureIgnoreCase) == true
                    || binding.Area?.Contains(filterText, StringComparison.InvariantCultureIgnoreCase) == true
                    || binding.Category?.Contains(filterText, StringComparison.InvariantCultureIgnoreCase) == true;
            };
        }
    }

    /// <summary>
    /// Texts the filter got focus.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void TxtFilterGotFocus(object sender, RoutedEventArgs e)
    {
        if (txtFilter.Text == PlaceHolderText)
        {
            txtFilter.Text = string.Empty;
        }
    }

    /// <summary>
    /// Texts the filter lost focus.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void TxtFilterLostFocus(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtFilter.Text))
        {
            txtFilter.Text = PlaceHolderText;
        }
    }

    /// <summary>
    /// Menus the item click.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void MenuItemClick(object sender, RoutedEventArgs e)
    {
        try
        {
            var dialog = new AboutWindow
            {
                Owner = this
            };
            dialog.ShowDialog();
        }
        catch (Exception ex) when (ex is InvalidOperationException or OutOfMemoryException)
        {
            MessageBox.Show($"Error opening About dialog: {ex.Message}",
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    /// <summary>
    /// Clears the filter text.
    /// </summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
    private void ClearFilterClick(object sender, RoutedEventArgs e)
    {
        txtFilter.Text = PlaceHolderText;
        txtFilter.Focus();
        if (KeyBindings != null)
        {
            KeyBindings.Filter = null;
        }
    }
}
