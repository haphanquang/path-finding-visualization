//
//  ContentView.swift
//  ShortestPathVisualize
//
//  Created by QH on 11/12/19.
//  Copyright © 2019 soyo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = GridViewModel()
    @State var showGrid: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            GridView(viewModel: self.viewModel, showGrid: $showGrid)
                .padding(.vertical, 50)
                .padding(.horizontal, 20)
            makeControls()
        }
    }
    
    @ViewBuilder
    func makeControls() -> some View {
        VStack (alignment: .center) {
            HStack {
                Picker(
                    "Algo",
                    selection: self.$viewModel.algo
                ) {
                    Text("BiBFS").tag(Algo.biDirectional)
                    Text("Dijkstra").tag(Algo.dijkstra)
                    Text("A *").tag(Algo.aStar)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200, height: 35, alignment: .trailing)
                
                Spacer()
                
                if self.viewModel.algo != .biDirectional {
                    Text(self.viewModel.pathSum)
                        .font(.headline)
                        .bold()
                }
            }
            
            
            Spacer()
            
            HStack {
                Text("Speed")
                Slider(value: self.$viewModel.speed).frame(width: 180, height: 35, alignment: .trailing)
                Toggle("Show Grid", isOn: $showGrid).frame(width: 140)
                
                if viewModel.algo != .biDirectional, viewModel.destinations.count != 2 {
                    Button {
                        self.viewModel.randomWalls()
                    } label: {
                        if self.viewModel.walls.isEmpty {
                            Text("Make Wall")
                        } else {
                            Text("Clear Wall")
                        }
                    }
                }
                
                Spacer()
                
                if self.viewModel.destinations.count == 0 {
                    if self.viewModel.algo != .biDirectional {
                        Text("Tap any point on the screen / longpress and drag to draw wall")
                    } else{
                        Text("Tap any point on the screen")
                    }
                } else if self.viewModel.destinations.count == 1 {
                    Text("Tap second point to start visualization")
                } else {
                    Text("Tap to stop/clean")
                }
            }
        }.padding(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
