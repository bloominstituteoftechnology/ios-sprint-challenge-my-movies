//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Christopher Aronson on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    var movieModelController = MovieModelController()

    @IBOutlet weak var titleLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addMoviewButtonTapped(_ sender: UIButton) {

        UIButton.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
            }, completion: { finish in
                UIButton.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
            })
        })

        guard let title = titleLable.text else { return }

        movieModelController.create(title: title)

        movieModelController.save(contetex: CoreDataStack.shared.mainContext)
    }
}
