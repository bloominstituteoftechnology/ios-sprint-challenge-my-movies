//
//  MovieModel.swift
//  MyMovies
//
//  Created by William Bundy on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie
{
	convenience init(_ title:String, _ hasWatched:Bool=false, _ identifier:UUID?=nil, moc:NSManagedObjectContext)
	{
		self.init(context:moc)
		self.title = title
		self.hasWatched = hasWatched
		self.identifier = identifier ?? UUID()
	}

	func getStub() -> MovieStub
	{
		return MovieStub(title:title!, identifier:identifier!, hasWatched:hasWatched)
	}

	func applyStub(_ stub:MovieStub)
	{
		self.title = stub.title
		if let id = stub.identifier {
			self.identifier = id
		}

		if let hasWatched = stub.hasWatched {
			self.hasWatched = hasWatched
		}

	}


}
