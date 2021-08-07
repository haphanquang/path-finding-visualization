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
            ForEach(self.displayData, id: \.self) { hex in
                HexView(hex: hex)
                HexView(hex: hex, isEmpty: true)
            }
            
            if (showWeight) {
                MapWeight(displayData: $displayData, itemSize: itemSize)
            }
        }
    }
}

struct HexView: View {
    let hex: HexDisplay
    var isEmpty: Bool = false
    
    var body: some View {
        let path = Path { path in
            let corners = hex.data.corners.map { CGPoint(x: $0.x, y: $0.y) }
            path.move(to: corners.first!)
            for point in corners {
                path.addLine(to: point)
            }
        }
        
        if isEmpty {
            path.stroke(Color.border)
        } else {
            path.fill(hex.color)
        }
    }
}

struct MapWeight: View {
    @Binding var displayData: [HexDisplay]
    let itemSize: CGSize
    
    var body: some View {
        ZStack {
            ForEach(self.displayData, id: \.self) { hex in
                let hexData = hex.data
                Text("\(hexData.weight)")
                    .font(.system(size: 10))
                    .bold()
                    .foregroundColor(.white)
                    .position(
                        x: hexData.corners.first!.x - itemSize.width / 2,
                        y: hexData.corners.first!.y - itemSize.height / 2
                    )
            }
        }
    }
}
