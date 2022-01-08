//
//  Color.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

extension Color {
    
    /// Give the hex tring for a given Color
    var hexString: String {
#if os(macOS)
        return NSColor(self).hexString
#endif
#if os(iOS)
        return UIColor(self).hexString
#endif
    }

    /// Creates a color from an hex string (e.g. "#3498db")
    /// The RGBA string are also supported (e.g. "#3498dbff").
    /// - Parameter hexString: A hexa-decimal color string representation
    init(hexString: String) {
      let hexString                 = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
      let scanner                   = Scanner(string: hexString)
      scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")

      var color: UInt64 = 0

      if scanner.scanHexInt64(&color) {
        self.init(hex: color, useOpacity: hexString.count > 7)
      } else {
        self.init(hex: 0x000000)
      }
    }
    
    /// Create a color from an hex integer (e.g. 0x3498db).
    /// - Parameters:
    ///   - hex: A hexa-decimal UInt64 that represents a color
    ///   - opacityChannel: If true the given hex-decimal UInt64 includes the opacity channel (e.g. 0xFF0000FF)
    init(hex: UInt64, useOpacity opacityChannel: Bool = false) {
      let mask      = UInt64(0xFF)
      let cappedHex = !opacityChannel && hex > 0xffffff ? 0xffffff : hex

      let rPart = cappedHex >> (opacityChannel ? 24 : 16) & mask
      let gPart = cappedHex >> (opacityChannel ? 16 : 8) & mask
      let bPart = cappedHex >> (opacityChannel ? 8 : 0) & mask
      let oPart = opacityChannel ? cappedHex & mask : 255

      let red     = Double(rPart) / 255.0
      let green   = Double(gPart) / 255.0
      let blue    = Double(bPart) / 255.0
      let opacity = Double(oPart) / 255.0

      self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

#if os(macOS)
extension NSColor {
    
    /// Return the hex string for a given NSColor
    var hexString: String {
        let rgbColor = usingColorSpace(.extendedSRGB) ?? NSColor(red: 1, green: 1, blue: 1, alpha: 1)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
#endif

#if os(iOS)
extension UIColor {
    
    /// Return the hex string for a given UIColor
    var hexString: String {
        let rgbColor = self
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
#endif
