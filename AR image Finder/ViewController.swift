//
//  ViewController.swift
//  AR image Finder
//
//  Created by Vladimir on 26.02.2023.
//



import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "video",
                                  withExtension: "mp4",
                                  subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // detect images
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed:"AR Resources", bundle: nil)!
        
        // detect plane
      //  configuration.planeDetection = [.horizontal]
        
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        default:
            print(#line, #function, "Unknown anchor has been discovered ")
        }
    }
    func nodeAdded (_ node: SCNNode, for imageAnchor: ARImageAnchor){
        //get image size
        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        
        // create plane of the same size
        let height = image.name == "washington" ? 0.003 + size.height : 0.005 + size.height
        let width = image.name == "washington" ? 15.5956/5.1 * size.width :
        15.5956 / 5.4 * size.width
        let plane = SCNPlane(width:width, height:height)
        plane.firstMaterial?.diffuse.contents = image.name == "washington" ?
        UIImage(named: "Franklin") :
        videoPlayer
       // UIImage(named: "Independence")
        
        if image.name == "washington"{
            videoPlayer.play()
        }
        
        // create plane node
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi/2
        planeNode.opacity = 1
        
        //move plane
        planeNode.position.x += image.name == "washington" ? -0.001 : 0.001
        planeNode.position.z += image.name == "washington" ? -0.001 : 0
        
      //run animation
        planeNode.runAction(
            .sequence([
                .wait(duration: 10),
                .fadeOut(duration: 3),
                .removeFromParentNode(),
            ])
        )
        
        //add plane node to the given node
        node.addChildNode(planeNode)
    }
    
    
    
    func nodeAdded (_ node:SCNNode, for planeAnchor: ARPlaneAnchor){
        print(#line, #function, "plane\(planeAnchor) added")
    }
}
