//
//  Grid.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/13/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import Foundation
import SwiftUI

struct GridView: View {
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
            
                HexMapView(
                    itemSize: Global.layout.size,
                    displayData: self.$viewModel.hexes,
                    showWeight: self.$viewModel.showWeight
                )
                
                
                HStack {
                    
                    VStack (alignment: .center) {
                        if self.viewModel.algo == 1 {
                            Text("\(self.viewModel.pathSum)").font(.headline).bold().frame(width: 100, height: 20, alignment: .center)
                        }
                        
                        Picker("Algo", selection: self.$viewModel.algo) {
                            Text("BiBFS").tag(0)
                            Text("Dijkstra").tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200, height: 35, alignment: .trailing)
                        .padding()
                    }
                    
                    Spacer()
                    
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
                self.viewModel.transform()
                self.viewModel.gridData = Map(size: geometry.frame(in: .global).size, origin: .zero)
            }
        }
    }
}


