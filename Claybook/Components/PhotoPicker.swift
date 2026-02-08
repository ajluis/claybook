import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Binding var selectedImages: [UIImage]
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Camera button
                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.theme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Photo library
                PhotosPicker(
                    selection: $photoItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Label("Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.theme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .foregroundStyle(Color.theme.textPrimary)

            // Selected photos preview
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Button {
                                    selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 2)
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: photoItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
                photoItems = []
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: Binding(
                get: { nil },
                set: { if let img = $0 { selectedImages.append(img) } }
            ))
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
