// <copyright file="KeyBindingView.cs" company="Elite Dangerous Community">
// Copyright (c) Elite Dangerous Community. All rights reserved.
// </copyright>

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using EdBindings.Model.BindingsRaw.Bindings;

namespace EdBindings.Model;

/// <summary>
/// Class KeyBindingView.
/// </summary>
[DebuggerDisplay("{Name} {PrimaryDevice}/{PrimaryKey}; {SecondaryDevice}/{SecondaryKey}")]
public class KeyBindingView
{
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
    /// Gets or sets the primary device.
    /// </summary>
    /// <value>The primary device.</value>
    public string PrimaryDevice { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the primary key.
    /// </summary>
    /// <value>The primary key.</value>
    public string PrimaryKey { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the secondary device.
    /// </summary>
    /// <value>The secondary device.</value>
    public string? SecondaryDevice { get; set; }

    /// <summary>
    /// Gets or sets the secondary key.
    /// </summary>
    /// <value>The secondary key.</value>
    public string? SecondaryKey { get; set; }

    /// <summary>
    /// Gets or sets the bind ed variable.
    /// </summary>
    /// <value>The bind ed variable.</value>
    public string BindEdVariable { get; set; } = string.Empty;


    /// <summary>
    /// Makes the key binding view.
    /// </summary>
    /// <param name="group">The group.</param>
    /// <param name="deviceMap">The device map.</param>
    /// <returns>KeyBindingView.</returns>
    public static KeyBindingView MakeKeyBindingView(BindingGroup group, DeviceMap deviceMap, List<ActionMapping> actionMappings)
    {
        var view = new KeyBindingView();

        var actionMapping = actionMappings.FirstOrDefault(am =>
            am.Code?.Equals(group.Name, StringComparison.OrdinalIgnoreCase) == true);
        view.Area = actionMapping?.Area ?? string.Empty;
        view.Category = actionMapping?.Category ?? string.Empty;
        view.Action = actionMapping?.Action ?? group.Name ?? string.Empty;

        var primary = group.Bindings.OfType<BindingDevice>()
            .FirstOrDefault(b => new[] { "Binding", "Primary" }.Contains(b.Name));

        if (primary != null)
        {
            var primaryDeviceMap = deviceMap.FindControlMap(primary);
            view.PrimaryDevice = primaryDeviceMap?.DeviceName ?? primary.Device ?? string.Empty;
            view.PrimaryKey = primaryDeviceMap?.ControlLabel ?? primary.Key ?? string.Empty;
        }

        var secondary = group.Bindings.OfType<BindingDevice>()
            .FirstOrDefault(b => b.Name == "Secondary");

        if (secondary != null)
        {
            var secondaryDeviceMap = deviceMap.FindControlMap(secondary);
            view.SecondaryDevice = secondaryDeviceMap?.DeviceName ?? secondary.Device;
            view.SecondaryKey = secondaryDeviceMap?.ControlLabel ?? secondary.Key;
        }

        view.BindEdVariable = $"ed{group.Name ?? "Unknown"}";

        return view;
    }
}
