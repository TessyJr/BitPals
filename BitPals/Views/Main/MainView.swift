import SwiftUI
import CloudKit

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                GIFImageView(imageName: viewModel.selectedPet.images.idleRight)
                    .scaleEffect(viewModel.petScale, anchor: .bottom)
            }
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Select a pet:", selection: $viewModel.selectedPet) {
                        ForEach(petDatas, id: \.self) { pet in
                            Text(pet.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    HStack {
                        Text("Pet size:")
                        Slider(value: $viewModel.petScale, in: 0.5...1)
                    }
                }
                
                VStack(alignment: .leading) {
                    Picker("Select Reminder", selection: $viewModel.selectedReminder) {
                        ForEach(reminderDatas, id: \.self) { reminder in
                            Text(reminder.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .disabled(viewModel.isCompanionAppOn)
                    
                }
                
                VStack(alignment: .leading) {
                    Toggle(isOn: $viewModel.isCompanionAppOn) {
                        Text("Companion App")
                    }
                    .controlSize(.small)
                    .toggleStyle(.switch)
                    .onChange(of: viewModel.isCompanionAppOn) {
                        if viewModel.isCompanionAppOn{
                            viewModel.selectedReminder = Reminder(name: "Every 30 minutes", seconds: 1800)
                            
//                            viewModel.selectedReminder = Reminder(name: "Every 1 minute", seconds: 60)
                        }
                    }
                    
                    Text("* Enabling the Companion App allows BitPals to read your stand time and step count every 30 minutes. It will set a reminder if these values fall below a certain threshold.")
                    
                    Text("* Ensure that BitPals Companion App is running on iOS before using BitPals on macOS.")
                }
            }
            
            HStack {
                if viewModel.petWindow == nil {
                    Button("Open Pet Window") {
                        viewModel.openPetWindow()
                    }
                } else {
                    Button("Remove Pet Window") {
                        viewModel.closePetWindow()
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding()
    }
}

struct GIFImageView: NSViewRepresentable {
    var imageName: String
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = NSImageView()
        imageView.canDrawSubviewsIntoLayer = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let imagePath = Bundle.main.path(forResource: imageName, ofType: "gif"),
           let image = NSImage(contentsOfFile: imagePath) {
            imageView.image = image
        } else {
            print("Error: Could not load image for \(imageName).gif")
        }
        
        containerView.addSubview(imageView)
        
        // Add constraints to center the imageView at the bottom of the containerView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let imageView = nsView.subviews.first as? NSImageView {
            if let imagePath = Bundle.main.path(forResource: imageName, ofType: "gif"),
               let image = NSImage(contentsOfFile: imagePath) {
                imageView.image = image
            } else {
                print("Error: Could not load image for \(imageName).gif")
            }
        }
    }
}
