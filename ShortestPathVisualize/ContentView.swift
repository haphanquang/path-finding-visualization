//
//  ContentView.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/12/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = SelectedGridViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                SelectedGrid(self.viewModel)
            
                VStack (alignment: .center) {
                    Picker("Algo", selection: self.$viewModel.algo) {
                        Text("BiBFS").tag(0)
                        Text("Dijkstra").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200, height: 35, alignment: .trailing)
                    .padding()
                    
                    if self.viewModel.algo == 1 {
                        Text("\(self.viewModel.pathSum)").font(.headline).bold().frame(width: 100, height: 20, alignment: .center)
                    }
                }
                
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
