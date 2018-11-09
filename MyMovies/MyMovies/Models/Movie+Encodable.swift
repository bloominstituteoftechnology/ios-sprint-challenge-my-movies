import Foundation
import CoreData

extension Movie: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title, identifier, hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: CodingKeys.title)
        try container.encode(identifier, forKey: CodingKeys.identifier)
        try container.encode(hasWatched, forKey: CodingKeys.hasWatched)
        
    }
}

