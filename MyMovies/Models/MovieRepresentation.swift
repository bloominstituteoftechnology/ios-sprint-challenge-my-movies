import Foundation

struct MovieRepresentation: Equatable, Codable {
    let title: String
    let identifier: String?
    let hasWatched: Bool?
}

/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */
struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}
