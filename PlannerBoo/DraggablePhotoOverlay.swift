import SwiftUI
import Photos

struct DraggablePhotoOverlay: View {
    @State private var photoItems: [PhotoItem] = []
    let date: Date
    
    var body: some View {
        ZStack {
            ForEach(photoItems) { item in
                DraggablePhoto(
                    photoItem: item,
                    onMove: { newPosition in
                        updatePhotoPosition(id: item.id, position: newPosition)
                    },
                    onResize: { newSize in
                        updatePhotoSize(id: item.id, size: newSize)
                    },
                    onDelete: {
                        deletePhoto(id: item.id)
                    }
                )
            }
        }
        .onAppear {
            loadPhotos()
        }
        .onReceive(NotificationCenter.default.publisher(for: .photoAdded)) { notification in
            if let userInfo = notification.userInfo,
               let image = userInfo["image"] as? UIImage,
               let notificationDate = userInfo["date"] as? Date,
               Calendar.current.isDate(notificationDate, inSameDayAs: date) {
                addPhoto(image: image)
            }
        }
    }
    
    private func addPhoto(image: UIImage) {
        let newItem = PhotoItem(
            image: image,
            position: CGPoint(x: 200, y: 300),
            size: CGSize(width: 150, height: 150)
        )
        photoItems.append(newItem)
        savePhotos()
    }
    
    private func updatePhotoPosition(id: UUID, position: CGPoint) {
        if let index = photoItems.firstIndex(where: { $0.id == id }) {
            photoItems[index].position = position
            savePhotos()
        }
    }
    
    private func updatePhotoSize(id: UUID, size: CGSize) {
        if let index = photoItems.firstIndex(where: { $0.id == id }) {
            photoItems[index].size = size
            savePhotos()
        }
    }
    
    private func deletePhoto(id: UUID) {
        photoItems.removeAll { $0.id == id }
        savePhotos()
    }
    
    private func savePhotos() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosURL = documentsPath.appendingPathComponent("photos_\(dateKey)")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: photosURL, withIntermediateDirectories: true)
        
        // Save photo data
        for item in photoItems {
            let imageURL = photosURL.appendingPathComponent("\(item.id.uuidString).jpg")
            if let imageData = item.image.jpegData(compressionQuality: 0.8) {
                try? imageData.write(to: imageURL)
            }
        }
        
        // Save metadata
        let metadata = photoItems.map { PhotoMetadata(from: $0) }
        let metadataURL = photosURL.appendingPathComponent("metadata.json")
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: metadataURL)
        }
    }
    
    private func loadPhotos() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosURL = documentsPath.appendingPathComponent("photos_\(dateKey)")
        let metadataURL = photosURL.appendingPathComponent("metadata.json")
        
        guard let data = try? Data(contentsOf: metadataURL),
              let metadata = try? JSONDecoder().decode([PhotoMetadata].self, from: data) else {
            return
        }
        
        var loadedItems: [PhotoItem] = []
        for meta in metadata {
            let imageURL = photosURL.appendingPathComponent("\(meta.id).jpg")
            if let imageData = try? Data(contentsOf: imageURL),
               let image = UIImage(data: imageData) {
                let item = PhotoItem(
                    id: meta.uuid,
                    image: image,
                    position: meta.position,
                    size: meta.size
                )
                loadedItems.append(item)
            }
        }
        photoItems = loadedItems
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct PhotoItem: Identifiable {
    var id = UUID()
    let image: UIImage
    var position: CGPoint
    var size: CGSize
    
    init(id: UUID = UUID(), image: UIImage, position: CGPoint, size: CGSize) {
        self.id = id
        self.image = image
        self.position = position
        self.size = size
    }
}

struct PhotoMetadata: Codable {
    let id: String // Use String instead of UUID for simpler encoding
    let positionX: CGFloat
    let positionY: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    init(from item: PhotoItem) {
        self.id = item.id.uuidString
        self.positionX = item.position.x
        self.positionY = item.position.y
        self.width = item.size.width
        self.height = item.size.height
    }
    
    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    var uuid: UUID {
        UUID(uuidString: id) ?? UUID()
    }
}

struct DraggablePhoto: View {
    let photoItem: PhotoItem
    let onMove: (CGPoint) -> Void
    let onResize: (CGSize) -> Void
    let onDelete: () -> Void
    
    @State private var isSelected = false
    
    var body: some View {
        let baseImage = Image(uiImage: photoItem.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: photoItem.size.width, height: photoItem.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        
        let borderedImage = baseImage
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        
        let resizeHandle = Group {
            if isSelected {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .offset(x: 10, y: 10)
                            .gesture(resizeGesture)
                    }
                }
            }
        }
        
        return borderedImage
            .overlay(resizeHandle)
            .position(photoItem.position)
            .onTapGesture { isSelected.toggle() }
            .gesture(moveGesture)
            .contextMenu {
                Button("Delete", role: .destructive) { onDelete() }
            }
    }
    
    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation
                let newWidth = max(50, photoItem.size.width + translation.width)
                let newHeight = max(50, photoItem.size.height + translation.height)
                onResize(CGSize(width: newWidth, height: newHeight))
            }
    }
    
    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                onMove(value.location)
            }
    }
}

extension Notification.Name {
    static let photoAdded = Notification.Name("photoAdded")
}

#Preview {
    DraggablePhotoOverlay(date: Date())
        .frame(width: 400, height: 600)
        .background(Color.gray.opacity(0.1))
}