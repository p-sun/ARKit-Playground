//
//  ViewController.swift
//  ARPowerPanelsDemo
//
//  Created by TSD040 on 2018-04-01.
//  Copyright © 2018 Paige Sun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PowerPanels

public class ARKitViewController: UIViewController {
    
    private var powerPanels: ARPowerPanels!
    private var arSceneView = ARSCNView()
    
    var scene: SCNScene
    let panelTypes: [ARPowerPanelsType] //= ARPowerPanelsType.allTypes
    
    public init(scene: SCNScene, panelTypes: [ARPowerPanelsType]) {
        self.scene = scene
        self.panelTypes = panelTypes
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(arSceneView)
        arSceneView.constrainEdges(to: view)
        
        arSceneView.delegate = self
        //        arSceneView.showsStatistics = true
        arSceneView.debugOptions  = [.showConstraints, ARSCNDebugOptions.showFeaturePoints]//, ARSCNDebugOptions.showWorldOrigin]
        
        arSceneView.scene = scene
        scene.rootNode.name = "AR World Origin   🌎"
        
        powerPanels = ARPowerPanels(arSceneView: arSceneView, panelTypes: panelTypes)
        powerPanels.selectNode(scene.rootNode)
        view.addSubview(powerPanels)
        powerPanels.constrainEdges(to: view)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginarSceneView()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    private func beginarSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        arSceneView.session.run(configuration)
    }
}

extension ARKitViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("didAdd \(node.position)")
        
        let planeNode = NodeCreator.bluePlane(anchor: planeAnchor)
        planeNode.name = "Blue Plane"
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Update size of the geometry associated with Plane nodes
        if let plane = node.childNodes.first?.geometry as? SCNPlane {
            plane.updateSize(toMatch: planeAnchor)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {//
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
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}