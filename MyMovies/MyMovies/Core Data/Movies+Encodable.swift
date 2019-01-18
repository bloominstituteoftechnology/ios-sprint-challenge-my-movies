import Foundation
import CoreData

extension Movie: Encodable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.hasWatched, forKey: .hasWatched)
    }
}
