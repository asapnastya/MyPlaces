//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 2/11/23.
//

import UIKit

// MARK: - RatingControl
@IBDesignable class RatingControl: UIStackView {
    
// MARK: - Params
    var ratingOfPlace = 0 {
        didSet {
            updateStarsButtons()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
// MARK: - IBInspectable
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
// MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
// MARK: - Private Methods
    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(
            named: "filledStar",
            in: bundle,
            compatibleWith: self.traitCollection
        )
        
        let emptyStar = UIImage(
            named: "emptyStar",
            in: bundle,
            compatibleWith: self.traitCollection
        )
        
        let highlightedStar = UIImage(
            named: "highlightedStar",
            in: bundle,
            compatibleWith: self.traitCollection
        )
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)

            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateStarsButtons()
    }
    
    private func updateStarsButtons() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < ratingOfPlace
        }
    }
    
// MARK: - Selectors
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        let selectedRating = index + 1
        
        if selectedRating == ratingOfPlace {
            ratingOfPlace = .zero
        } else {
            ratingOfPlace = selectedRating
        }
    }
}
