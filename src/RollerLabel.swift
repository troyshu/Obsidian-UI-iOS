//
//  CounterLabel.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
 Setting the text of this label animates the characters in
 only changing those that are different.
 
 The use of a monospaced font is recommended which can be any font
 by getting the monospacedDigitFont property of any UIFont.
 
 */
open class RollerLabel: CharacterLabel {
    
    /// The time delay between the cascading digit animations.
    open var characterAnimationDelay = 0.025
    
    /// The duration of each character's animation.
    open var animationDuration = 0.1
    
    fileprivate var lowestNotMatchingIndex: Int?
    fileprivate var animate = true
    
    open func setText(_ text: String, animated: Bool) {
        animate = animated
        self.text = text
    }
    
    override open var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        
        set {
            
            if textStorage.string == newValue!.string {
                return
            }
            
            super.attributedText = newValue
            
            lowestNotMatchingIndex = lowestNotMatchingCharacterIndex(newValue!.string)
            
            if animate {
                self.animateOut(nil)
                self.animateIn(nil)
            } else {
                changeWithoutAnimation()
            }
        }
        
    }
    
    override func initialTextLayerAttributes(_ textLayer: CATextLayer) {
        textLayer.opacity = 1
    }
    
    // MARK: Animate
    
    fileprivate func animateIn(_ completion: ((_ finished: Bool) -> Void)? = nil) {
        if let lowestIndex = lowestNotMatchingIndex {
            var count = 1
            for index in stride(from: (characterTextLayers.count - 1), through: lowestIndex, by: -1) {
                let textLayer = characterTextLayers[index]
                textLayer.opacity = 0
                let translation = CATransform3DMakeTranslation(0, textLayer.bounds.height, 0)
                textLayer.transform = translation
                count += 1
                LayerAnimation.animation(textLayer, duration:self.animationDuration, delay: TimeInterval(count) * self.characterAnimationDelay, animations: {
                    textLayer.transform = CATransform3DIdentity
                    textLayer.opacity = 1
                }, completion: { finished in
                    if let completionFunction = completion {
                        completionFunction(finished)
                    }
                })
            }
        }
    }
    
    fileprivate func animateOut(_ completion: ((_ finished: Bool) -> Void)? = nil) {
        var count = 1
        for index in stride(from: (oldCharacterTextLayers.count - 1), through: lowestNotMatchingIndex!, by: -1) {
            let textLayer = oldCharacterTextLayers[index]
            textLayer.transform = CATransform3DIdentity
            let translation = CATransform3DMakeTranslation(0, -textLayer.bounds.height, 0)
            count += 1
            LayerAnimation.animation(textLayer, duration:self.animationDuration, delay: TimeInterval(count) * self.characterAnimationDelay, animations: {
                textLayer.transform = translation
                textLayer.opacity = 0
            }, completion: { finished in
                textLayer.removeFromSuperlayer()
                if index <= self.lowestNotMatchingIndex! {
                    
                    for layer in self.characterTextLayers {
                        layer.opacity = 1
                    }
                    for layer in self.oldCharacterTextLayers {
                        layer.opacity = 0
                    }
                    
                    if let completionFunction = completion {
                        completionFunction(finished)
                    }
                }
            })
        }
        
        for index in 0 ..< lowestNotMatchingIndex! {
            oldCharacterTextLayers[index].removeFromSuperlayer()
        }
    }
    
    fileprivate func changeWithoutAnimation() {
        for layer in oldCharacterTextLayers {
            layer.removeFromSuperlayer()
        }
        
        for layer in characterTextLayers {
            layer.opacity = 1
        }
    }
    
    // MARK: Find Characters To Change
    
    fileprivate func lowestNotMatchingCharacterIndex(_ newString: String) -> Int? {
        
        var lowestIndex = characterTextLayers.count - 1
        
        if newString.characters.count != oldCharacterTextLayers.count {
            return 0
        }
        
        for (index, _) in characterTextLayers.enumerated().reversed() {
            guard let oldCharacter = oldCharacterTextLayers[index].string as? NSAttributedString, let newCharacter = characterTextLayers[index].string as? NSAttributedString else {
                return nil
            }
            
            if !newCharacter.isEqual(to: oldCharacter) {
                if index < lowestIndex { lowestIndex = index }
            }
            
        }
        
        return lowestIndex
    }
    
}
