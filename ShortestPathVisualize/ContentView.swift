//
//  ContentView.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/12/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let viewModel = SelectedGridViewModel()
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                SelectedGrid(self.viewModel)
//                Grid(self.viewModel).disabled(true)
            }
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.addRect(.init(origin: .zero, size: geometry.size))
            }.fill(Color.init(white: 1.0))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
