//
//  Map.swift
//  ShortestPathVisualize
//
//  Created by QH on 07/08/21.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import CoreGraphics

struct Orientation {
    let f0,f1,f2,f3: Double
    let b0,b1,b2,b3: Double
    let startAngle: Double
    
    static let pointy = Orientation(f0: sqrt(3.0), f1: sqrt(3.0) / 2.0, f2: 0.0, f3: 3.0 / 2.0,
                                    b0: sqrt(3.0) / 3.0, b1: -1.0 / 3.0, b2: 0.0, b3: 2.0 / 3.0,
                                    startAngle: 0.5)
    static let flat = Orientation(f0: 3.0 / 2.0, f1: 0.0, f2: sqrt(3.0) / 2.0, f3: sqrt(3.0),
                                  b0: 2.0 / 3.0, b1: 0.0, b2: -1.0 / 3.0, b3: sqrt(3.0) / 3.0,
                                  startAngle: 0.0)
}

struct Layout {
    let orientation: Orientation
    let size: CGSize
    var origin: CGPoint
    
    func getCornerOffset(corner: Int) -> CGPoint {
        let angle = 2 * Double.pi * (orientation.startAngle + Double(corner)) / 6
        return CGPoint(x: size.width * CGFloat(cos(angle)), y: size.height * CGFloat(sin(angle)))
    }
    
    func getPolygonCorners(hex: Hex) -> [CGPoint] {
        var result: [CGPoint] = []
        let center = CGPoint.hexToPixel(self, hex)
        for i in 0..<6 {
            let offset = getCornerOffset(corner: i)
            result.append(CGPoint(x: center.x + offset.x, y: center.y + offset.y))
        }
        return result
    }
    
    mutating func changeOrigin(_ point: CGPoint) {
        origin = point
    }
}

struct Map {
    var layout: Layout = Global.layout
    let heights: [Hex: Double] = [:]
    var points: Set<Hex> = Set()
    
    private let weightRange = 1...20
    
    init(size: CGSize, origin: CGPoint) {
        self.init(
            height: Int(size.height / Global.layout.size.height),
            width: Int(size.width / Global.layout.size.width),
            origin: origin)
    }
    
    init(height: Int, width: Int, origin: CGPoint) {
        for i in 0...height {
            let offset = Int(i / 2)
            for j in -offset...(width - offset) {
                var hex = Hex(q: j, r: i)
                hex.weight = Int.random(in: weightRange)
                points.insert(hex)
            }
        }
    }
    
    func isHexExist(_ hex: Hex) -> Hex? {
        return points.first(where: { $0 == hex })
    }
    
    func random() -> Hex? {
        return points.randomElement()
    }
}


struct Global {
    static let layout = Layout(
        orientation: .pointy,
        size: CGSize.init(width: 22, height: 22),
        origin: .zero)
}
