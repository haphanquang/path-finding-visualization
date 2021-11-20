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
    @Binding var showGrid: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                MapView(
                    displayingData: self.$viewModel.hexes,
                    showWeight: self.$viewModel.showWeight,
                    backgroundGrid: self.$showGrid,
                    mapData: self.viewModel.gridData
                )
                
                TapListenerView(tappedCallback: { point in
                    self.viewModel.didTap(point)
                }, blockedCallback: { point in
                    if self.viewModel.algo != .biDirectional {
                        self.viewModel.block(point)
                    }
                }).background(Color.clear)    
                
            }.onAppear {
                self.viewModel.transform()
                self.viewModel.gridData = Map(size: geometry.frame(in: .global).size, origin: .zero)
            }
        }
    }
}


