//
//  ContentView.swift
//  Instafilter
//
//  Created by Izaan Saleem on 25/09/2024.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
            
            //ContentUnavailableView("Oops!", systemImage: "swift", description: Text("No data found"))
            ContentUnavailableView {
                Label("No data", systemImage: "swift")
            } description: {
                Text("No data found")
            } actions: {
                Button("Refresh") {
                    //refresh
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        //image = Image(.example1) // SwiftUI image
        let inputImage = UIImage(resource: .example1)
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
        let currentFilter = CIFilter.pixellate()
        currentFilter.inputImage = beginImage
        
        let amount = 1.0
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(amount, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        image = Image(uiImage: uiImage)
    }
}

#Preview {
    ContentView()
}
