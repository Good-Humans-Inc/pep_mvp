import Foundation

// Define Joint enum for exercise targeting
enum Joint: String, Codable, CaseIterable {
    case leftKnee = "left_knee"
    case rightKnee = "right_knee"
    case leftAnkle = "left_ankle"
    case rightAnkle = "right_ankle"
    case leftHip = "left_hip"
    case rightHip = "right_hip"
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let imageURL: URL?
    let imageURL1: URL?
    let duration: TimeInterval
    let targetJoints: [Joint]
    let instructions: [String]
    let videoId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, targetJoints, instructions, videoId
        case imageURL = "imageUrl"
        case imageURL1 = "imageUrl1"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        targetJoints = try container.decode([Joint].self, forKey: .targetJoints)
        instructions = try container.decode([String].self, forKey: .instructions)
        videoId = try container.decodeIfPresent(String.self, forKey: .videoId)
        
        // Handle URL decoding with string conversion
        if let imageUrlString = try container.decodeIfPresent(String.self, forKey: .imageURL) {
            imageURL = URL(string: imageUrlString)
        } else {
            imageURL = nil
        }
        
        if let imageUrl1String = try container.decodeIfPresent(String.self, forKey: .imageURL1) {
            imageURL1 = URL(string: imageUrl1String)
        } else {
            imageURL1 = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(duration, forKey: .duration)
        try container.encode(targetJoints, forKey: .targetJoints)
        try container.encode(instructions, forKey: .instructions)
        try container.encodeIfPresent(videoId, forKey: .videoId)
        try container.encodeIfPresent(imageURL?.absoluteString, forKey: .imageURL)
        try container.encodeIfPresent(imageURL1?.absoluteString, forKey: .imageURL1)
    }
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         imageURLString: String? = nil,
         imageURLString1: String? = nil,
         duration: TimeInterval = 180,
         targetJoints: [Joint] = [],
         instructions: [String] = [],
         videoId: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURLString != nil ? URL(string: imageURLString!) : nil
        self.imageURL1 = imageURLString1 != nil ? URL(string: imageURLString1!) : nil
        self.duration = duration
        self.targetJoints = targetJoints
        self.instructions = instructions
        self.videoId = videoId
    }
}

// Example exercises for testing and development
extension Exercise {
    static var examples: [Exercise] = [
        Exercise(
            name: "Knee Flexion",
            description: "Gently bend and extend your knee to improve range of motion",
            imageURLString: "https://cdn1.newyorkhipknee.com/wp-content/uploads/2022/10/image2-6.jpg",
            imageURLString1: "https://cdn1.newyorkhipknee.com/wp-content/uploads/2022/10/image2-6.jpg",
            targetJoints: [Joint.rightKnee, Joint.rightAnkle, Joint.rightHip],
            instructions: [
                "Sit on a chair with your feet flat on the floor",
                "Slowly lift your right foot and bend your knee",
                "Hold for 5 seconds",
                "Slowly lower your foot back to the floor",
                "Repeat 10 times"
            ]
        ),
        Exercise(
            name: "Straight Leg Raises",
            description: "Strengthen the quadriceps without bending the knee",
            imageURLString: "https://rehab2perform.com/wp-content/uploads/2022/02/single-leg.jpg",
            imageURLString1: "https://rehab2perform.com/wp-content/uploads/2022/02/single-leg.jpg",
            targetJoints: [Joint.leftHip, Joint.leftKnee, Joint.leftAnkle],
            instructions: [
                "Lie on your back with one leg bent and one leg straight",
                "Tighten the thigh muscles of your straight leg",
                "Slowly lift your straight leg up about 12 inches",
                "Hold for 5 seconds",
                "Slowly lower your leg back down",
                "Repeat 10 times"
            ]
        )
    ]
}

