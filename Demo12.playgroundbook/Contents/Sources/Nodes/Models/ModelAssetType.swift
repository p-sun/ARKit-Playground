//
//  ModelAssetType.swift
//  ARPlanets
//
//  Created by Paige Sun on 2018-03-18.
//  Copyright © 2018 Paige Sun. All rights reserved.
//

import UIKit
import SceneKit

protocol NodeMaker {
    static var allTypes: [NodeMaker] { get }
    var menuImage: UIImage? { get }
    func createNode() -> SCNNode?
}

enum Shapes: NodeMaker {

    case sphere, plane, box, pyramid, cylinder, cone, torus, tube, capsule
    
    static var allTypes: [NodeMaker] {
        return [Shapes.sphere, Shapes.plane, Shapes.box, Shapes.pyramid, Shapes.cylinder, Shapes.cone, Shapes.torus, Shapes.tube, Shapes.capsule]
    }
    
    var menuImage: UIImage? {
        switch self {
        case .sphere:
            return #imageLiteral(resourceName: "sphere")
        case .plane:
            return #imageLiteral(resourceName: "plane")
        case .box:
            return #imageLiteral(resourceName: "shapeBox")
        case .pyramid:
            return #imageLiteral(resourceName: "pyramid")
        case .cylinder:
            return #imageLiteral(resourceName: "cylinder")
        case .cone:
            return #imageLiteral(resourceName: "cone")
        case .torus:
            return #imageLiteral(resourceName: "torus")
        case .tube:
            return #imageLiteral(resourceName: "tube")
        case .capsule:
            return #imageLiteral(resourceName: "capsule")
        }
    }
    
    func createNode() -> SCNNode? {
        
        let basicGeometry = geometry(for: self)
        basicGeometry.firstMaterial?.diffuse.contents = UIColor.randomColor()
        
        let childNode = SCNNode()
        childNode.geometry = basicGeometry
        childNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        
        let parentNode = SCNNode()
        parentNode.name = "\(self)"
        parentNode.addChildNode(childNode)
        return parentNode
    }
    
    private func geometry(for type: Shapes) -> SCNGeometry {
        switch self {
        case .sphere:
            return SCNSphere(radius: 1.0)
        case .plane:
            return SCNPlane(width: 1.0, height: 1.5)
        case .box:
            return SCNBox(width: 1.0, height: 1.5, length: 2.0, chamferRadius: 0.0)
        case .pyramid:
            return SCNPyramid(width: 2.0, height: 1.5, length: 1.0)
        case .cylinder:
            return SCNCylinder(radius: 1.0, height: 1.5)
        case .cone:
            return SCNCone(topRadius: 0.5, bottomRadius: 1.0, height: 1.5)
        case .torus:
            return SCNTorus(ringRadius: 1.0, pipeRadius: 0.2)
        case .tube:
            return SCNTube(innerRadius: 0.5, outerRadius: 1.0, height: 1.5)
        case .capsule:
            return SCNCapsule(capRadius: 0.5, height: 2.0)
        }
    }
}

public enum Model: NodeMaker {
    case axis, wolf, fox, lowPolyTree, camera, custom
    
    static var allTypes: [NodeMaker] {
        return [Model.axis, Model.wolf, Model.fox, Model.lowPolyTree]
    }
    
    func createNode() -> SCNNode? {
        switch self {
        case .axis:
            return NodeCreator.createAxesNode(quiverLength: 0.15, quiverThickness: 1.0)
        case .fox:
            let parentNode = SCNNode()
            parentNode.name = "Fox 🦊"
            
            let bundle = Bundle(for: ModelCollectionView.self)
            if let url = bundle.url(forResource: "art.scnassets/fox/max", withExtension: "scn"),
                let scene = try? SCNScene(url: url),
                let foxNode = scene.rootNode.childNode(withName: "Max_rootNode", recursively: true)?.clone() {
                foxNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
                parentNode.addChildNode(foxNode)
                return parentNode
            }
            NSLog("PAIGE LOG: COULD NOT LOAD FOX MODEL")
            return nil
        case .wolf:
            return nodeFromResource(assetName: "wolf/wolf", extensionName: "dae")?.clone()
        case .lowPolyTree:
            return nodeFromResource(assetName: "lowPolyTree", extensionName: "dae")?.clone()
        case .camera:
            let rootCamera = nodeFromResource(assetName: "camera", extensionName: "scn")
            return rootCamera?.childNode(withName: "Camera Shape", recursively: true)
        case .custom:
            return SCNNode()
        }
    }
    
    func nodeFromResource(assetName: String, extensionName: String) -> SCNNode? {
        let bundle = Bundle(for: ModelCollectionView.self)

        if let url = bundle.url(forResource: "art.scnassets/\(assetName)", withExtension: extensionName) {
            NSLog("PAIGE LOG url \(url)")
            
            if let node = SCNReferenceNode(url: url) {
                node.name = assetName
                node.load()
                return node
                
            }
        } else {
            NSLog("PAIGE LOG: COULD NOT LOAD FROM RESOURCE \(assetName) \(extensionName) | BUNDLE PATH \(bundle.bundlePath) | \(bundle.resourcePath) ")
        }
        return nil
    }
    
    var menuImage: UIImage? {
        switch self {
        case .axis:
            return #imageLiteral(resourceName: "menuAxis")
        case .wolf:
            return #imageLiteral(resourceName: "menuWolf")
        case .lowPolyTree:
            return #imageLiteral(resourceName: "menuLowPolyTree")
        case .fox:
            return #imageLiteral(resourceName: "fox_squareLQ")
        case .camera:
            return #imageLiteral(resourceName: "menuLowPolyTree")
        case .custom:
            return #imageLiteral(resourceName: "menuLowPolyTree")
        }
        
        
//        func assetName() -> String {
//            switch self {
//            case .axis:
//                return "menuAxis"
//            case .wolf:
//                return "menuWolf"
//            case .lowPolyTree:
//                return "menuLowPolyTree"
//            case .fox:
//                return "fox_squareLQ"
//            case .camera:
//                return "menuLowPolyTree"
//            case .custom:
//                return "menuLowPolyTree"
//            }
//        }
//
//        let bundle = Bundle(for: ModelCollectionView.self)
//        let image = UIImage(named: assetName(), in: bundle, compatibleWith: nil)
//        NSLog("PAIGE LOG LOADING \(assetName()) \(String(describing: image))")
//        return image
    }
}