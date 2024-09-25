//
//  ContentView.swift
//  Instafilter
//
//  Created by Izaan Saleem on 25/09/2024.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    
    var body: some View {
        VStack {
            VStack {
                ShareLink(item: URL(string: "https://www.instagram.com/progasm_")!, subject: Text("iOS developer"), message: Text("Check instagram account"))
                ShareLink(item: URL(string: "https://www.medium.sizaan5.com")!) {
                    Label("iOS tutorials", systemImage: "swift")
                }
                .padding()
                let example = Image(.example1)
                ShareLink(item: example, preview: SharePreview("I am Groot!!", image: example)) {
                    Label("Share Groot!!", systemImage: "swift")
                }
                .padding()
            }
            .padding()
            
            PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
                Label("Select a picture", systemImage: "photo")
            }
            
            ScrollView {
                ForEach(0..<selectedImages.count, id: \.self) { i in
                    selectedImages[i]
                        .resizable()
                        .scaledToFit()
                }
            }
            
        }
        .onChange(of: pickerItems) {
            Task {
                self.selectedImages.removeAll()
                for item in pickerItems {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImages.append(loadedImage)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
