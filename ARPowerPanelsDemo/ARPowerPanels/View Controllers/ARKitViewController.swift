//
//  ViewController.swift
//  ARPlanets
//
//  Created by Paige Sun on 2018-03-18.
//  Copyright © 2018 Paige Sun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARKitViewController: UIViewController {
    
    private var powerPanels: ARPowerPanels!
    private var sceneCreator = SceneCreator()
    private var arSceneView = ARSCNView()
    var scene: SCNScene!

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(arSceneView)
        arSceneView.constrainEdges(to: view)
        
        arSceneView.delegate = self
//        arSceneView.showsStatistics = true
        arSceneView.debugOptions  = [.showConstraints, ARSCNDebugOptions.showFeaturePoints]
        
        scene = sceneCreator.createFoxPlaneScene()
        arSceneView.scene.rootNode.name = "AR Scene Root Node"
        arSceneView.scene = scene
        
        powerPanels = ARPowerPanels(arSceneView: arSceneView, scene: scene)
        powerPanels.dataSource = self
        powerPanels.selectNode(scene.rootNode)
        view.addSubview(powerPanels)
        powerPanels.constrainEdges(to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginarSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    private func beginarSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSceneView.session.run(configuration)
    }
}

extension ARKitViewController: ARPowerPanelsDataSource {
    func hierachyPanel(shouldDisplayChildrenFor node: SCNNode) -> Bool {
        return !sceneCreator.isNodeParentModel(node: node)
    }
}



//class ARKitViewController: UIViewController {
//
//    // MARK: Variables
//    private var arSceneView = ARSCNView()
//
//    var foxNode = Model.fox.createNode()
//
//    // MARK: View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(arSceneView)
//        arSceneView.constrainEdges(to: view)
//
//        arSceneView.delegate = self
//        arSceneView.showsStatistics = true
//        arSceneView.debugOptions  = [.showConstraints, ARSCNDebugOptions.showFeaturePoints]
//
//        arSceneView.scene.rootNode.addChildNode(foxNode)
//
////        SliderInputsView(axisLabels: <#T##[String]#>, minValue: <#T##Float#>, maxValue: <#T##Float#>)
////
////        let rotationInput = SliderInputsView() { [weak self] value in
////            print("value did change \(value)")
////            self?.foxNode.rotation.y = Float(value)
////        }
////        view.addSubview(rotationInput)
////
////        rotationInput.constrainCenterX(to: view)
////        rotationInput.constrainCenterY(to: view)
////        rotationInput.constrainWidth(200)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        beginarSceneView()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        arSceneView.session.pause()
//    }
//
//    private func beginarSceneView() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        arSceneView.session.run(configuration)
//    }
//}


extension ARKitViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("didAdd \(node.position)")
        
        let planeNode = NodeCreator.bluePlane(anchor: planeAnchor)
        planeNode.name = "Blue Plane"
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Update size of the geometry associated with Plane nodes
        if let plane = node.childNodes.first?.geometry as? SCNPlane {
            plane.updateSize(toMatch: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {//
        print("didRemove \(node.position)")
    }
}

extension ARKitViewController {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}