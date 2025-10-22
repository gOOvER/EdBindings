// <copyright file="DeviceMap.cs" company="Elite Dangerous Community">
// Copyright (c) Elite Dangerous Community. All rights reserved.
// </copyright>

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using EdBindings.Model.BindingsRaw.Bindings;
using Newtonsoft.Json;

namespace EdBindings.Model;

/// <summary>
/// Class DeviceMap.
/// </summary>
public class DeviceMap
{
    /// <summary>
    /// Gets or sets the name.
    /// </summary>
    /// <value>The name.</value>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the controls.
    /// </summary>
    /// <value>The controls.</value>
    public List<DeviceControlMap> Controls { get; set; } = new();

    /// <summary>
    /// Finds the control map.
    /// </summary>
    /// <param name="binding">The binding.</param>
    /// <returns>DeviceControlMap.</returns>
    public DeviceControlMap? FindControlMap(BindingDevice? binding)
    {
        if (binding?.Device == null || binding.Key == null)
        {
            return null;
        }

        return Controls.FirstOrDefault(c =>
            string.Equals(c.DeviceId, binding.Device, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(c.ControlValue, binding.Key, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Opens the specified path.
    /// </summary>
    /// <param name="path">The path.</param>
    /// <returns>DeviceMap.</returns>
    public static DeviceMap Open(string path)
    {
        var json = File.ReadAllText(path);
        return JsonConvert.DeserializeObject<DeviceMap>(json) ?? new DeviceMap();
    }
}
