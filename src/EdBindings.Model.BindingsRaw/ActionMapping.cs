using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

namespace EdBindings.Model
{
    /// <summary>
    /// Record ActionMapping.
    /// </summary>
    public record ActionMapping
    {
        /// <summary>
        /// Gets or sets the code.
        /// </summary>
        /// <value>The code.</value>
        public string Code { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the area.
        /// </summary>
        /// <value>The area.</value>
        public string Area { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the category.
        /// </summary>
        /// <value>The category.</value>
        public string Category { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the action.
        /// </summary>
        /// <value>The action.</value>
        public string Action { get; set; } = string.Empty;


        /// <summary>
        /// Opens the specified path.
        /// </summary>
        /// <param name="path">The path.</param>
        public static List<ActionMapping> Open(string path)
        {
            var json = File.ReadAllText(path);
            return JsonConvert.DeserializeObject<List<ActionMapping>>(json) ?? new List<ActionMapping>();
        }
    }
}
