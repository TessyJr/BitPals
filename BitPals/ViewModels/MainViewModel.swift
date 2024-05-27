import SwiftUI

class MainViewModel: ObservableObject {
    @Published var petWindow: PetWindow?
    @Published var petScale: Double = 1.0
    @Published var isCompanionAppOn: Bool = false
    
    @Published var selectedPet: Pet = petDatas[0]
    @Published var selectedReminder: Reminder = reminderDatas[0]
    
    func openPetWindow() {
        guard let screenFrame = NSScreen.main?.frame else {
            print("Error: No main screen available.")
            return
        }
        
        let petWindow = PetWindow(
            screenFrame: screenFrame,
            pet: selectedPet,
            scale: petScale,
            reminder: selectedReminder,
            isCompanionAppOn: isCompanionAppOn
        )
        
        self.petWindow = petWindow
    }
    
    func closePetWindow() {
        petWindow?.closePetWindow()
        petWindow = nil
    }
}
