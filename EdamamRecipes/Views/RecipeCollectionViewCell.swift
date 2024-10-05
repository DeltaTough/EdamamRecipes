//
//  RecipeCollectionViewCell.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 02/10/2024.
//

import UIKit

final class RecipeCollectionViewCell: UICollectionViewCell {
    
    private var viewModel: ImageCellViewModel?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return imageView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray  // Choose your separator color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configure(with viewModel: ImageCellViewModel, url: URL, recipeName: String) {
        self.viewModel = viewModel
        Task {
            await loadImage(from: url)
        }
        title.text = recipeName
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        contentView.addSubview(separatorView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadImage(from url: URL) async {
        do {
            if let image = try await viewModel?.loadImage(for: url) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    UIView.animate(withDuration: 0.5) {
                        self.imageView.alpha = 1.5  // Fade-in effect
                    }
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.35)// Image takes 70% of the cell height
        ])
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)  // 1pt height for a thin line
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        title.text = nil
    }
    
}
