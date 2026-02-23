// The MIT License (MIT)
//
// Copyright (c) 2014 Suyeol Jeon (http:xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

/// A SwiftUI `TextEditor` with placeholder support.
///
/// `PlaceholderTextEditor` wraps SwiftUI's `TextEditor` and displays
/// placeholder text when the bound text is empty, similar to `TextField`.
///
/// Usage:
/// ```swift
/// @State private var text = ""
///
/// PlaceholderTextEditor(text: $text, placeholder: "Enter your message...")
/// ```
@available(iOS 14.0, macOS 11.0, *)
public struct PlaceholderTextEditor: View {
    @Binding private var text: String
    private let placeholder: String
    private var placeholderColor: Color
    private var font: Font?

    private static var defaultPlaceholderColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.placeholderText)
        #elseif canImport(AppKit)
        return Color(NSColor.placeholderTextColor)
        #else
        return Color.gray
        #endif
    }

    /// Creates a `PlaceholderTextEditor`.
    ///
    /// - Parameters:
    ///   - text: A binding to the text to display and edit.
    ///   - placeholder: The placeholder string to display when `text` is empty.
    ///   - placeholderColor: The color of the placeholder text. Defaults to the system placeholder color.
    ///   - font: An optional font to apply to both the editor and placeholder.
    public init(
        text: Binding<String>,
        placeholder: String,
        placeholderColor: Color? = nil,
        font: Font? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor ?? Self.defaultPlaceholderColor
        self.font = font
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .font(font)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            TextEditor(text: $text)
                .font(font)
        }
        .accessibilityValue(text.isEmpty ? placeholder : text)
    }
}

@available(iOS 14.0, macOS 11.0, *)
extension PlaceholderTextEditor {
    /// Sets the placeholder color.
    public func placeholderColor(_ color: Color) -> PlaceholderTextEditor {
        var view = self
        view.placeholderColor = color
        return view
    }

    /// Sets the font for both the editor and placeholder.
    public func font(_ font: Font?) -> PlaceholderTextEditor {
        var view = self
        view.font = font
        return view
    }
}
