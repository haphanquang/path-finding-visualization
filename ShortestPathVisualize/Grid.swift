//
//  Grid.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

struct Grid: View {
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
            }
        }
    }
}

struct SelectedGrid: View {
    @ObservedObject var viewModel: GridViewModel
    
    init(_ vm: GridViewModel) {
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


