//
//  GameViewController.swift
//  dengta100
//
//  Created by 喻西剑 on 2025/5/30.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建游戏场景
        if let view = self.view as! SKView? {
            // 创建场景
            let scene = GameScene()
            
            // 设置场景大小为视图大小
            scene.size = view.bounds.size
            
            // 设置缩放模式
            scene.scaleMode = .aspectFill
            
            // 呈现场景
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // 显示调试信息
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
