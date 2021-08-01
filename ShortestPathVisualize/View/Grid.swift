//
//  Grid.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

struct BackgroundGrid: View {
    @ObservedObject var viewModel: GridViewModel
    
    init(_ vm: GridViewModel) {
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
                self.viewModel.transform()
            }
        }
    }
}

struct Grid: View {
    @ObservedObject var viewModel: GridViewModel
    
    init(_ vm: GridViewModel) {
        viewModel = vm
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                TapListenerView(tappedCallback: { point in
                    self.viewModel.didTap(point)
                }, blockedCallback: { point in
                    if self.viewModel.algo == 1 {
                        self.viewModel.block(point)
                    }
                }).background(Color.clear)
                
                ForEach(self.viewModel.hexes) { hexDisplay in
                    HexView(hexDisplay.data, c: hexDisplay.color, showWeight: self.viewModel.algo)
                }
                
                HStack {
                    if self.viewModel.destinations.count == 0 {
                        if self.viewModel.algo == 1 {
                            Text("Tap any point on the screen / longpress and drag to draw wall")
                        } else{
                            Text("Tap any point on the screen")
                        }
                        
                    } else if self.viewModel.destinations.count == 1 {
                        Text("Tap second point to start visualization")
                    } else {
                        Text("Tap to clean")
                    }
                    
                }.padding()
            }.onAppear {
                self.viewModel.gridData = Map(size: geometry.frame(in: .global).size, origin: .zero)
                self.viewModel.transform()
            }
        }
    }
}


