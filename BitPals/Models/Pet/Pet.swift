import Foundation

struct Pet: Hashable {
    let name: String
    let images: Images

    struct Images: Hashable {
        let idleLeft: String
        let idleRight: String
        let moveLeft: String
        let moveRight: String
        let remindLeft: String
        let remindRight: String
    }
}
