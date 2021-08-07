//
//  MapView.swift
//  ShortestPathVisualize
//
//  Created by QH on 07/08/2021.
//  Copyright © 2019 soyo. All rights reserved.
//

import SwiftUI

struct HexMapView: View {
    let itemSize: CGSize
    @Binding var displayData: [HexDisplay]
    @Binding var showWeight: Bool

    var body: some View {
        ZStack {
            HexagonMapView(displayData: $displayData, showWeight: $showWeight)
        }
    }
}

struct HexagonMapView: UIViewRepresentable {
    @Binding var displayData: [HexDisplay]
    @Binding var showWeight: Bool

    func makeUIView(context: Context) -> UIHexagonMapView {
        let view = UIHexagonMapView()
        view.backgroundColor = UIColor.white
        return view
    }

    func updateUIView(_ uiView: UIHexagonMapView, context: Context) {
        uiView.displayData = displayData
        uiView.showWeight = showWeight
        uiView.setNeedsDisplay()
    }
}

class UIHexagonMapView: UIView {
    var displayData: [HexDisplay] = []
    var showWeight: Bool = false
    let itemSize: CGSize = Global.layout.size
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        for hex in displayData {
            let path = UIBezierPath()
            let corners = hex.data.corners.map { CGPoint(x: $0.x, y: $0.y) }
            path.move(to: corners.first!)
            for point in corners {
                path.addLine(to: point)
            }
            path.close()
            
            hex.color.uiColor().setFill()
            path.fill()
            
            UIColor.white.setStroke()
            path.lineWidth = 0.5
            path.stroke()
            
            
            if showWeight, hex.data.weight > 0 {
                let position = CGPoint(
                    x: hex.data.corners.first!.x - itemSize.width,
                    y: hex.data.corners.first!.y - itemSize.height
                )
                
                NSString(string: "\(hex.data.weight)").draw(
                    at: position,
                    withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 11),
                        .foregroundColor: UIColor.white
                    ])
            }
        }
    }
}

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
