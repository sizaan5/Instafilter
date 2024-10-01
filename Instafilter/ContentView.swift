//
//  ContentView.swift
//  Instafilter
//
//  Created by Izaan Saleem on 25/09/2024.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import StoreKit

struct ContentView: View {
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var processImage: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    @State private var currentFilter: CIFilter = CIFilter.unsharpMask()
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    PhotosPicker(selection: $selectedItem) {
                        if let processImage {
                            processImage
                                .resizable()
                                .scaledToFit()
                                .clipShape(.rect(cornerRadius: 20))
                                .shadow(radius: 10)
                        } else {
                            ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                        }
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedItem, loadImage)
                    
                    Spacer()
                    
                    HStack {
                        Text("Intensity")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                            .disabled(processImage != nil ? false : true)
                            .tint(.black)
                    }
                    HStack {
                        Text("Radius")
                        Slider(value: $filterRadius)
                            .onChange(of: filterRadius, applyProcessing)
                            .disabled(processImage != nil ? false : true)
                            .tint(.black)
                    }
                    HStack {
                        Text("Scale")
                        Slider(value: $filterScale)
                            .onChange(of: filterScale, applyProcessing)
                            .disabled(processImage != nil ? false : true)
                            .tint(.black)
                    }
                    
                    Divider()
                    
                    HStack {
                        Button("Change Filter", action: changeFilter)
                            .disabled(processImage != nil ? false : true)
                            .tint(.black)
                        
                        Spacer()
                        
                        if let processImage {
                            ShareLink(item: processImage, preview: SharePreview("Instafilter image", image: processImage))
                                .tint(.black)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
                .navigationTitle("Instafilter")
                .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputIamge = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputIamge)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 200 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
