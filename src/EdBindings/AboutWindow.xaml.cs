namespace EdBindings
{
    using System.Diagnostics;
    using System.Reflection;
    using System.Windows;

    /// <summary>
    /// Interaction logic for AboutWindow.xaml
    /// </summary>
    public partial class AboutWindow : Window
    {
        /// <summary>
        /// Gets or sets the version string.
        /// </summary>
        /// <value>The version string.</value>
        public string VersionString { get; set; } = string.Empty;

        /// <summary>
        /// Initializes a new instance of the <see cref="AboutWindow"/> class.
        /// </summary>
        public AboutWindow()
        {
            InitializeComponent();
            SetVersion();
            DataContext = this;
        }

        /// <summary>
        /// Sets the version.
        /// </summary>
        private void SetVersion()
        {
            try
            {
                var assembly = Assembly.GetExecutingAssembly();
                var versionInfo = assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>();
                VersionString = versionInfo?.InformationalVersion != null
                    ? $"v{versionInfo.InformationalVersion}"
                    : "Unknown Version";
            }
            catch
            {
                VersionString = "Unknown Version";
            }
        }
        /// <summary>
        /// Closes the button click.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="RoutedEventArgs"/> instance containing the event data.</param>
        private void CloseButtonClick(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// Hyperlinks the request navigate.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="System.Windows.Navigation.RequestNavigateEventArgs"/> instance containing the event data.</param>
        private void HyperlinkRequestNavigate(object sender, System.Windows.Navigation.RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri) { UseShellExecute = true });
            e.Handled = true;
        }
    }
}
