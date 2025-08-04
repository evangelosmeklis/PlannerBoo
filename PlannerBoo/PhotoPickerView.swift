import SwiftUI
import PhotosUI
import CoreLocation

struct PhotoPickerView: View {
    let date: Date
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Select Photos")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Choose photos to add to your planner page")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
                
                if !selectedImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Add Photos")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    savePhotosToPlanner()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedImages.isEmpty)
            )
        }
        .onChange(of: selectedPhotos) {
            loadImages(from: selectedPhotos)
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        selectedImages.removeAll()
        
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            selectedImages.append(image)
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    private func savePhotosToPlanner() {
        // Send notification for each selected image to add to the overlay
        for image in selectedImages {
            NotificationCenter.default.post(
                name: .photoAdded,
                object: nil,
                userInfo: ["image": image, "date": date]
            )
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    PhotoPickerView(date: Date())
}