//
//  MapView.swift
//  ShortestPathVisualize
//
//  Created by QH on 07/08/2021.
//  Copyright © 2019 soyo. All rights reserved.
//

import SwiftUI

struct MapView: View {
    @Binding var displayingData: [HexDisplay]
    @Binding var showWeight: Bool
    @Binding var backgroundGrid: Bool
    
    let mapData: Map

    var body: some View {
        ZStack {
            if backgroundGrid {
                EmptyHexagonMapView(gridData: Array(mapData.points.map { HexDisplay($0, color: .clear) }))
            }
            HexagonMapView(displayData: $displayingData, showWeight: $showWeight, showBorder: $backgroundGrid)
        }
    }
}

struct HexagonMapView: UIViewRepresentable {
    @Binding var displayData: [HexDisplay]
    @Binding var showWeight: Bool
    @Binding var showBorder: Bool
    var filled: Bool = true
    

    func makeUIView(context: Context) -> UIHexagonMapView {
        let view = UIHexagonMapView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIHexagonMapView, context: Context) {
        uiView.displayData = displayData
        uiView.showWeight = showWeight
        uiView.filled = filled
        uiView.showBorder = showBorder
        uiView.setNeedsDisplay()
    }
}

struct EmptyHexagonMapView: UIViewRepresentable {
    var gridData: [HexDisplay]

    func makeUIView(context: Context) -> UIHexagonMapView {
        let view = UIHexagonMapView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIHexagonMapView, context: Context) {
        uiView.displayData = gridData
        uiView.showWeight = false
        uiView.filled = false
        uiView.showBorder = true
        uiView.setNeedsDisplay()
    }
}

class UIHexagonMapView: UIView {
    var displayData: [HexDisplay] = []
    var showWeight: Bool = false
    var filled: Bool = true
    var showBorder: Bool = true
    
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
            
            if filled {
                hex.color.uiColor().setFill()
                path.fill()
            }
            
            if showBorder {
                Color.border.uiColor().setStroke()
                path.lineWidth = 0.5
                path.stroke()
            }
            
            if showWeight, hex.data.weight > 0 {
                let position = CGPoint(
                    x: hex.data.corners.first!.x - itemSize.width,
                    y: hex.data.corners.first!.y - itemSize.height
                )
                
                NSString(string: "\(hex.data.weight)").draw(
                    at: position,
                    withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 9),
                        .foregroundColor: UIColor.white
                    ])
            }
        }
    }
}
