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
    
    var body: some View {
        ZStack(alignment: .top) {
            GridView(self.viewModel)
            
            VStack (alignment: .center) {
                HStack {
                    Picker(
                        "Algo",
                        selection: self.$viewModel.algo
                    ) {
                        Text("BiBFS").tag(0)
                        Text("Dijkstra").tag(1)
                        Text("A *").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200, height: 35, alignment: .trailing)
                    
                    
                    Spacer()
                    
                    if self.viewModel.algo > 0 {
                        Text(self.viewModel.pathSum)
                            .font(.headline)
                            .bold()
                    }
                }.padding()
                
                
                Spacer()
                HStack {
                    Text("Speed")
                    Slider(value: self.$viewModel.speed)
                        .frame(width: 180, height: 35, alignment: .trailing)
                    
                    Spacer()
                    if self.viewModel.destinations.count == 0 {
                        if self.viewModel.algo != 0 {
                            Text("Tap any point on the screen / longpress and drag to draw wall")
                        } else{
                            Text("Tap any point on the screen")
                        }
                    } else if self.viewModel.destinations.count == 1 {
                        Text("Tap second point to start visualization")
                    } else {
                        Text("Tap to stop/clean")
                    }
                }.padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
