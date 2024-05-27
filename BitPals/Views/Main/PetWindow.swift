import SwiftUI

class PetWindow: NSWindow {
    private var petView: PetView?
    
    init(screenFrame: NSRect, pet: Pet, scale: Double, reminder: Reminder, isCompanionAppOn: Bool) {
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        isOpaque = false
        hasShadow = false
        backgroundColor = .clear
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces]
        
        setupPetView(pet: pet, scale: scale, reminder: reminder, isCompanionAppOn: isCompanionAppOn)
        makeKeyAndOrderFront(nil)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    private func setupPetView(pet: Pet, scale: Double, reminder: Reminder, isCompanionAppOn: Bool) {
        let petViewModel = PetViewModel(pet: pet, scale: CGFloat(scale), reminder: reminder, isCompanionAppOn: isCompanionAppOn)
        let petView = PetView(frame: .zero, viewModel: petViewModel)
        
        contentView?.addSubview(petView)
        self.petView = petView
    }
    
    func closePetWindow() {
        petView?.viewModel.stopFetchTimer()
        petView?.viewModel.stopReminderTimer()
        petView?.viewModel.stopDelayReminderTimer()
        orderOut(nil)
    }
}
