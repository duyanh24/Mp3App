//
//  CustomSlider.swift
//  Mp3App
//
//  Created by AnhLD on 10/21/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 20
    
    private let label = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 20))
    private let thumbView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbView.backgroundColor = Colors.sliderColor
        thumbView.layer.borderWidth = 0.4
        thumbView.layer.borderColor = UIColor.darkGray.cgColor
        label.text = "00:00 / 00:00"
        label.font = label.font.withSize(11)
        label.textColor = UIColor.white
        label.textAlignment = .center
        thumbView.addSubview(label)
        updateThumbImage()
    }

    private func thumbImage(radius: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: 90, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
    private func updateThumbImage() {
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
        setThumbImage(thumb, for: .highlighted)
    }
    
    func setProgressTime(time: String) {
        label.text = time
        updateThumbImage()
    }
}
