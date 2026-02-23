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

import UIKit

// MARK: - Private Associated Object Keys

private var placeholderTextViewKey: UInt8 = 0
private var needsUpdateFontKey: UInt8 = 0
private var placeholderObserverKey: UInt8 = 0

// MARK: - Fallback Placeholder Color (pre-iOS 13)

private let fallbackPlaceholderColor: UIColor = {
    let textField = UITextField()
    textField.placeholder = " "
    if let attributes = textField.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil),
       let color = attributes[.foregroundColor] as? UIColor {
        return color
    }
    return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
}()

// MARK: - Placeholder Observer

/// Manages KVO and notification observations for the placeholder text view.
/// Stored as an associated object on UITextView so that observations are
/// automatically cleaned up when the text view is deallocated.
private class PlaceholderObserver {
    var kvoTokens: [NSKeyValueObservation] = []
    var notificationToken: NSObjectProtocol?

    deinit {
        kvoTokens.removeAll()
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

// MARK: - UITextView + Placeholder

extension UITextView {

    // MARK: Class Properties

    /// The default placeholder color, matching the system placeholder text color.
    @objc public class var defaultPlaceholderColor: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }
        return fallbackPlaceholderColor
    }

    // MARK: Placeholder Text View

    /// A non-interactive text view used to display the placeholder.
    @objc public var placeholderTextView: UITextView {
        if let existing = objc_getAssociatedObject(self, &placeholderTextViewKey) as? UITextView {
            return existing
        }

        // Lazily set the font of UITextView
        let originalText = attributedText
        text = " "
        attributedText = originalText

        let placeholderTV = UITextView()
        placeholderTV.backgroundColor = .clear
        placeholderTV.textColor = Self.defaultPlaceholderColor
        placeholderTV.isUserInteractionEnabled = false
        placeholderTV.isAccessibilityElement = false
        objc_setAssociatedObject(self, &placeholderTextViewKey, placeholderTV, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        needsUpdateFont = true
        updatePlaceholderTextView()
        needsUpdateFont = false

        // Set up KVO and notification observations
        let obs = PlaceholderObserver()
        obs.kvoTokens = [
            observe(\.attributedText, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.bounds, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.font, options: [.new]) { host, _ in
                host.needsUpdateFont = true
                host.updatePlaceholderTextView()
            },
            observe(\.frame, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.text, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.textAlignment, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.textContainerInset, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.textContainer.lineFragmentPadding, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
            observe(\.textContainer.exclusionPaths, options: [.new]) { host, _ in host.updatePlaceholderTextView() },
        ]
        obs.notificationToken = NotificationCenter.default.addObserver(
            forName: UITextView.textDidChangeNotification,
            object: self,
            queue: nil
        ) { [weak self] _ in
            self?.updatePlaceholderTextView()
        }
        objc_setAssociatedObject(self, &placeholderObserverKey, obs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return placeholderTV
    }

    // MARK: Placeholder

    /// The placeholder text displayed when the text view is empty.
    @objc @IBInspectable public var placeholder: String? {
        get { placeholderTextView.text }
        set {
            placeholderTextView.text = newValue
            updatePlaceholderTextView()
        }
    }

    /// The styled placeholder text displayed when the text view is empty.
    @objc public var attributedPlaceholder: NSAttributedString? {
        get { placeholderTextView.attributedText }
        set {
            placeholderTextView.attributedText = newValue
            updatePlaceholderTextView()
        }
    }

    /// The color of the placeholder text.
    @objc @IBInspectable public var placeholderColor: UIColor? {
        get { placeholderTextView.textColor }
        set { placeholderTextView.textColor = newValue }
    }

    // MARK: Private

    private var needsUpdateFont: Bool {
        get { (objc_getAssociatedObject(self, &needsUpdateFontKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &needsUpdateFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private func updatePlaceholderTextView() {
        if let text = text, !text.isEmpty {
            placeholderTextView.removeFromSuperview()
            accessibilityValue = text
        } else {
            insertSubview(placeholderTextView, at: 0)
            accessibilityValue = placeholder
        }

        if needsUpdateFont {
            placeholderTextView.font = font
            needsUpdateFont = false
        }

        if (placeholderTextView.attributedText?.length ?? 0) == 0 {
            placeholderTextView.textAlignment = textAlignment
        }

        placeholderTextView.textContainer.exclusionPaths = textContainer.exclusionPaths
        placeholderTextView.textContainerInset = textContainerInset
        placeholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        placeholderTextView.frame = bounds
    }
}
