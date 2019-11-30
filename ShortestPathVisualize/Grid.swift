//
//  NodeView.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI



struct Grid: View {
    @ObservedObject var viewModel: SelectedGridViewModel
    
    init(_ vm: SelectedGridViewModel) {
        viewModel = vm
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(self.viewModel.gridData.points)) { hex in
                    HexEmptyView(hex, c: .gray)
                }
                
            }.onAppear {
                self.viewModel.gridData = Map(size: geometry.frame(in: .global).size, origin: .zero)
            }
        }
    }
}

struct SelectedGrid: View {
    @ObservedObject var viewModel: SelectedGridViewModel
    
    init(_ vm: SelectedGridViewModel) {
        viewModel = vm
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                TapListenerView(tappedCallback: { point in
                    self.viewModel.tapped(point)
                }, blockedCallback: { point in
                    if self.viewModel.algo == 1 {
                        self.viewModel.blockPoint(point)
                    }
                }).background(Color.clear)
                
                ForEach(self.viewModel.visitedDisplay) { hexDisplay in
                    HexView(hexDisplay.data, c: hexDisplay.color, showWeight: self.viewModel.algo)
                }
                
                ForEach(self.viewModel.willVisitedDisplay) { hex in
                    HexView(hex, c: Color.willVisit, showWeight: self.viewModel.algo)
                }
                
                ForEach(self.viewModel.selectedLocation) { hex in
                    HexView(hex, c: Color.selected, showWeight: self.viewModel.algo)
                }
                
                ForEach(self.viewModel.checkingItems) { hex in
                    HexView(hex, c: Color.checking, showWeight: self.viewModel.algo)
                }
                
                ForEach(self.viewModel.collisonItems) { hex in
                    HexView(hex, c: Color.collision, showWeight: self.viewModel.algo)
                }
                
                ForEach(self.viewModel.blockedItems) { hex in
                    HexView(hex, c: Color.blocked, showWeight: 0)
                }
                
                ForEach(self.viewModel.fixedPaths.reduce([], +)) { hex in
                    HexView(hex, c: Color.finalPath, showWeight: self.viewModel.algo)
                }
                
                HStack {
                    if self.viewModel.selectedLocation.count == 0 {
                        if self.viewModel.algo == 1 {
                            Text("Tap any point on the screen / longpress and drag to draw wall")
                        } else{
                            Text("Tap any point on the screen")
                        }
                        
                    } else if self.viewModel.selectedLocation.count == 1 {
                        Text("Tap second point to start visualization")
                    } else {
                        Text("Tap to clean")
                    }
                    
                }.padding()
            }.onAppear {
                self.viewModel.gridData = Map(size: geometry.frame(in: .global).size, origin: .zero)
            }
        }
    }
}

struct HexView : View {
    var hex: Hex
    var color: Color
    var weightAppear: Bool
    
    init(_ h: Hex, c: Color = .selected, showWeight: Int = 0) {
        hex = h
        color = c
        weightAppear = (showWeight == 1)
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
                
            }.stroke(self.color)
            
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
            if gesture.state == .began {
                
            } else if gesture.state == .changed {
                guard let view = gesture.view else {
                    return
                }
                let location = gesture.location(in: view)
                self.blockedCallback(location)
            }
            else if gesture.state == .ended{
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
    
    static let visited1 = Color(red: 0.5, green: 0.4, blue: 0.5)
    static let visited2 = Color(red: 0.3, green: 0.9, blue: 0.3)
    static let willVisit = Color(red: 0.7, green: 0.7, blue: 0.7)
    
    static let selected = Color(red: 0.3, green: 0.6, blue: 0.3)
    
    static let checking = Color(red: 0.4, green: 0.4, blue: 1.0)
    static let collision = Color(red: 0.7, green: 0.4, blue: 0.4)
    
    static let finalPath = Color.blue
    static let blocked = Color.black
}
