//
//  GameScene.swift
//  Created by Marquis Kurt on 9/23/22.
//  This file is part of PaintbrushTest.
//
//  PaintbrushTest is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  PaintbrushTest comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.
//

import SpriteKit
import Algorithms

class GameScene: SKScene {
    private var spinnyNode : SKShapeNode?
    private var predictLabel: SKLabelNode?
    private var predictCanvas: SKSpriteNode?
    internal var panelCanvas: SKShapeNode?
    internal var drawArea: SKNode?
    
    override func didMove(to view: SKView) {
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
        }

        if let draw = childNode(withName: "//drawArea") {
            self.drawArea = draw
        }
        if let canvas = drawArea?.childNode(withName: "panelCanvas") as? SKShapeNode {
            self.panelCanvas = canvas
        }
        if let predCanvas = childNode(withName: "//predictedCanvas") as? SKSpriteNode {
            self.predictCanvas = predCanvas
        }
        if let label = childNode(withName: "//predictLabel") as? SKLabelNode {
            self.predictLabel = label
            label.text = "Draw a line in the canvas, then press SPACE to predict."
        }
    }

    func touchDown(atPoint pos : CGPoint) {
        if let children = drawArea?.children {
            for child in children where child != panelCanvas {
                child.removeFromParent()
            }
        }
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.drawArea?.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.drawArea?.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.drawArea?.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let drawnLine = makePathFromChildren() {
                self.drawArea?.addChild(drawnLine)
                predictLabel?.text = "Generated line from nodes."
            }
            if let image = getCanvasImage() {
                predictLabel?.text = "Captured image from canvas area."
                predictCanvas?.texture = SKTexture(cgImage: image)
                if let prediction = try? makePrediction(from: image) {
                    predictLabel?.text = "Predicted number: \(prediction == -1 ? "Unknown": "\(prediction)")"
                }
            }
        case 0x24:
            for node in children where node is SKShapeNode {
                node.removeFromParent()
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
