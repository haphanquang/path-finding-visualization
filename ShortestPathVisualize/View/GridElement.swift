//
//  GridElement.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//


import Foundation
import SwiftUI

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
    
    static let visited1 = Color(red: 0.8, green: 0.8, blue: 0.1)
    static let visited2 = Color(red: 0.8, green: 0.8, blue: 0.1)

    static let willVisit = Color(red: 0.7, green: 0.7, blue: 0.7)
    
    static let border = Color(red: 0.9, green: 0.9, blue: 0.9)
    
    static let checking = Color(red: 0.2, green: 0.7, blue: 0.2)
    static let collision = Color(red: 0.7, green: 0.4, blue: 0.4)
    
    static let finalPath = Color.blue
    static let blocked = Color.black
}
