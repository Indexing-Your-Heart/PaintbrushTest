//
//  PaintbrushSolver.swift
//  Created by Marquis Kurt on 9/23/22.
//  This file is part of PaintbrushTest.
//
//  PaintbrushTest is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  PaintbrushTest comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.
//

import Foundation
import SpriteKit

protocol PaintbrushSolver {
    var panelCanvas: SKShapeNode? { set get }
    var drawArea: SKNode? { set get }
    func makePathFromChildren() -> SKShapeNode?
    func getCanvasImage() -> CGImage?
    func makePrediction(from cgImage: CGImage) throws -> Int64
}

extension GameScene: PaintbrushSolver {
    func makePathFromChildren() -> SKShapeNode? {
        guard let points = getDrawAreaPoints() else { return nil }
        let drawnLine = SKShapeNode()
        let mutablePath = CGMutablePath()
        drawnLine.name = "drawnLine"

        for nodes in points.windows(ofCount: 2) {
            guard let current = nodes.first, let next = nodes.last else { continue }
            mutablePath.move(to: current.position)
            mutablePath.addQuadCurve(to: next.position, control: current.position)
        }

        points.forEach { $0.removeFromParent() }

        drawnLine.path = mutablePath
        drawnLine.strokeColor = .black
        drawnLine.lineJoin = .round
        drawnLine.lineCap = .round
        drawnLine.lineWidth = 16
        return drawnLine
    }

    func getCanvasImage() -> CGImage? {
        guard let panelCanvas, let drawArea else { return nil }
        panelCanvas.fillColor = .black
        guard let drawnLine = drawArea.childNode(withName: "drawnLine") as? SKShapeNode else {
            return nil
        }
        drawnLine.strokeColor = .white
        guard let texture = view?.texture(from: drawArea, crop: panelCanvas.frame) else {
            panelCanvas.fillColor = .white
            drawnLine.strokeColor = .black
            return nil
        }
        panelCanvas.fillColor = .white
        drawnLine.strokeColor = .black
        return texture.cgImage()
    }

    func makePrediction(from cgImage: CGImage) throws -> Int64 {
        let classifier = try MNISTClassifier(configuration: .init())
        let prediction = try classifier.prediction(input: .init(imageWith: cgImage))
        print(prediction.labelProbabilities)
        var highestProbability = -Double.infinity
        var currentNumber = Int64(-1)
        for (number, probability) in prediction.labelProbabilities {
            if probability <= highestProbability { continue }
            highestProbability = probability
            currentNumber = number
        }
        return currentNumber
    }

    func getDrawAreaPoints() -> [SKNode]? {
        drawArea?.children.filter { $0 != panelCanvas }
    }
}
