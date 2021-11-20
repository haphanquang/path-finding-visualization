import Foundation
import UIKit
import SwiftUI

extension Color {
    func uiColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}


extension Color {
    static let normal = Color.white

    static let selected = Color(red: 0.9, green: 0.2, blue: 0.2)
    
    static let visited1 = Color(red: 0.8, green: 0.8, blue: 0.1)
    static let visited2 = Color(red: 0.8, green: 0.8, blue: 0.1)

    static let willVisit = Color(red: 0.7, green: 0.7, blue: 0.7)
    
    static let border = Color(red: 0.93, green: 0.93, blue: 0.93)
    
    static let checking = Color(red: 0.2, green: 0.7, blue: 0.2)
    static let collision = Color(red: 0.7, green: 0.4, blue: 0.4)
    
    static let finalPath = Color.blue
    static let blocked = Color.black
}
