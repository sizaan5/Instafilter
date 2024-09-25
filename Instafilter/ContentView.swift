//
//  ContentView.swift
//  Instafilter
//
//  Created by Izaan Saleem on 25/09/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount = 0.0
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .blur(radius: blurAmount)
            Text("Hello, world!")
                .blur(radius: blurAmount)
            
            Slider(value: $blurAmount, in: 0...20)
                .onChange(of: blurAmount) { oldValue, newValue in
                    print("New value in \(newValue)")
                }
            
            Button("Hello, World!") {
                showingConfirmation = true
            }
            .frame(width: 300, height: 300)
            .background(backgroundColor)
            .confirmationDialog("Change background", isPresented: $showingConfirmation) {
                Button("Red") { backgroundColor = .red }
                Button("Green") { backgroundColor = .green }
                Button("Gray") { backgroundColor = .gray }
                Button("Yellow") { backgroundColor = .yellow }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select a new color")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
