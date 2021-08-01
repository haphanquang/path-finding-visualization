//
//  GridElement.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//


import Foundation
import SwiftUI

struct HexView : View {
    var hex: Hex
    var color: Color
    var weightAppear: Bool
    
    init(_ h: Hex, c: Color = .selected, showWeight: Int = 0) {
        hex = h
        color = c
        weightAppear = (showWeight == 1)
    }
    
    init(_ model: HexDisplay) {
        self.hex = model.data
        self.color = model.color
        self.weightAppear = model.showWeight
    }
    
    var body: some View {
        ZStack {
            Path { path in
                let allPoints = hex.corners.map { CGPoint(x: $0.x, y: $0.y) }
                path.move(to: allPoints.first!)
                for point in allPoints {
                    path.addLine(to: point)
                }
            }.fill(self.color)
            
            
            if (weightAppear) {
                Text("\(hex.weight)")
                .font(.system(size: 10))
                .bold()
                .foregroundColor(.white)
                .position(x: hex.corners.first!.x - Global.layout.size.width / 2, y: hex.corners.first!.y - Global.layout.size.height / 2)
            }
        }
        
    }
}

struct HexEmptyView : View {
    var hex: Hex
    var color: Color
    
    init(_ h: Hex, c: Color = .selected) {
        hex = h
        color = c
    }
    
    var body: some View {
        ZStack {
            Path { path in
                let allPoints = hex.corners.map { CGPoint(x: $0.x, y: $0.y) }
                path.move(to: allPoints.first!)
                for point in allPoints {
                    path.addLine(to: point)
                }
            }
            .stroke(self.color)
            
            Text("\(hex.weight)")
                .font(.system(size: 10))
                .bold()
                .foregroundColor(.white)
                .position(x: hex.corners.first!.x - Global.layout.size.width / 2, y: hex.corners.first!.y - Global.layout.size.height / 2)
        }
        
    }
}

struct TapListenerView: UIViewRepresentable {
    
    var tappedCallback: ((CGPoint) -> Void)
    var blockedCallback: ((CGPoint) -> Void)

    func makeUIView(context: UIViewRepresentableContext<TapListenerView>) -> UIView {
        let v = UIView(frame: .zero)
        
        let gesture = UITapGestureRecognizer(target: context.coordinator
                                            , action: #selector(Coordinator.tapped))
        
        let longPress = UILongPressGestureRecognizer(target: context.coordinator
                                            , action: #selector(Coordinator.blocked))
        longPress.minimumPressDuration = 0.3
            
        v.addGestureRecognizer(gesture)
        v.addGestureRecognizer(longPress)
        
        return v
    }

    class Coordinator: NSObject {
        var tappedCallback: ((CGPoint) -> Void)
        var blockedCallback: ((CGPoint) -> Void)
        
        init(tappedCallback: @escaping ((CGPoint) -> Void), blockedCallback: @escaping ((CGPoint) -> Void)) {
            self.tappedCallback = tappedCallback
            self.blockedCallback = blockedCallback
        }
        
        @objc func tapped(gesture :UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            self.tappedCallback(point)
        }
        
        @objc func blocked(gesture: UILongPressGestureRecognizer) {
//            let point = gesture.location(in: gesture.view)
//            self.blockedCallback(point)
            switch gesture.state {
            case .began, .changed:
                guard let view = gesture.view else {
                    return
                }
                let location = gesture.location(in: view)
                self.blockedCallback(location)
            default:
                break
            }
        }
    }

    func makeCoordinator() -> TapListenerView.Coordinator {
        return Coordinator(tappedCallback:self.tappedCallback, blockedCallback: self.blockedCallback)
    }

    func updateUIView(_ uiView: UIView,
                       context: UIViewRepresentableContext<TapListenerView>) {
    }

}

extension Color {
    static let normal = Color.white
    
    static let selected = Color(red: 0.2, green: 0.6, blue: 0.2)
    
    static let visited1 = Color(red: 0.2, green: 0.8, blue: 0.2)
    static let visited2 = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    static let willVisit = Color(red: 0.6, green: 0.6, blue: 0.6)
    
    static let border = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    static let checking = Color(red: 0.2, green: 0.7, blue: 0.2)
    static let collision = Color(red: 0.7, green: 0.4, blue: 0.4)
    
    static let finalPath = Color.blue
    static let blocked = Color.black
}
