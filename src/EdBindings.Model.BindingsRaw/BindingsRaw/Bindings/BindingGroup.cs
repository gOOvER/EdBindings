// <copyright file="BindingGroup.cs" company="Elite Dangerous Community">
// Copyright (c) Elite Dangerous Community. All rights reserved.
// </copyright>

using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace EdBindings.Model.BindingsRaw.Bindings;

    /// <summary>
    /// Record BindingGroup.
    /// </summary>
    public record BindingGroup(string Name, List<Binding> Bindings) : Binding(Name)
    {
        /// <summary>
        /// Makes the binding group.
        /// </summary>
        /// <param name="element">The element.</param>
        /// <returns>EdBindings.Model.BindingsRaw.Bindings.Binding.</returns>
        public static Binding? MakeBindingGroup(XElement element)
        {
            if (!element.HasElements)
            {
                return null;
            }

            return new BindingGroup(
                Name: element.Name.LocalName,
                Bindings: element.Descendants().Select(element => MakeBinding(element)).Where(b => b != null).ToList()!);
        }
    }
