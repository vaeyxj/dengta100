//
//  GameUI.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import UIKit

class GameUI: SKNode {
    
    // MARK: - UI元素
    private var statusBar: SKNode!
    private var healthBar: HealthBar!
    private var ammoDisplay: AmmoDisplay!
    private var levelLabel: SKLabelNode!
    private var expBar: ExperienceBar!
    
    // MARK: - 屏幕尺寸
    private var screenSize: CGSize
    
    // MARK: - 初始化
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        zPosition = 10000  // 设置极高的z值确保UI在最前面
        
        // 打印调试信息
        print("GameUI screenSize: \(screenSize)")
        
        createSimpleUI()
    }
    
    private func createSimpleUI() {
        // 创建一个全屏背景测试
        let testBackground = SKShapeNode(rect: CGRect(
            x: -screenSize.width/2,
            y: -screenSize.height/2,
            width: screenSize.width,
            height: screenSize.height
        ))
        testBackground.fillColor = UIColor.red.withAlphaComponent(0.1)
        testBackground.strokeColor = UIColor.red
        testBackground.lineWidth = 2
        testBackground.zPosition = 1
        testBackground.name = "testBackground"
        addChild(testBackground)
        
        // 顶部状态栏
        let topBar = SKShapeNode(rect: CGRect(
            x: -screenSize.width/2,
            y: screenSize.height/2 - 60,
            width: screenSize.width,
            height: 60
        ))
        topBar.fillColor = UIColor.black.withAlphaComponent(0.7)
        topBar.strokeColor = .clear
        topBar.zPosition = 5
        addChild(topBar)
        
        // 血条
        healthBar = HealthBar(size: CGSize(width: 200, height: 20))
        healthBar.position = CGPoint(x: -screenSize.width/2 + 120, y: screenSize.height/2 - 30)
        healthBar.zPosition = 10
        addChild(healthBar)
        
        // 弹药显示
        ammoDisplay = AmmoDisplay()
        ammoDisplay.position = CGPoint(x: screenSize.width/2 - 80, y: screenSize.height/2 - 30)
        ammoDisplay.zPosition = 10
        addChild(ammoDisplay)
        
        // 等级标签
        levelLabel = SKLabelNode(text: "LV.1")
        levelLabel.fontName = "Arial-Bold"
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -screenSize.width/2 + 50, y: screenSize.height/2 - 50)
        levelLabel.zPosition = 10
        addChild(levelLabel)
        
        // 经验条
        expBar = ExperienceBar(size: CGSize(width: 150, height: 8))
        expBar.position = CGPoint(x: -screenSize.width/2 + 150, y: screenSize.height/2 - 50)
        expBar.zPosition = 10
        addChild(expBar)
        
        // 底部控制说明
        let controlHint = SKLabelNode(text: "左侧移动 | 右侧射击")
        controlHint.fontName = "Arial"
        controlHint.fontSize = 16
        controlHint.fontColor = UIColor.white.withAlphaComponent(0.8)
        controlHint.position = CGPoint(x: 0, y: -screenSize.height/2 + 30)
        controlHint.zPosition = 10
        addChild(controlHint)
        
        // 左下角摇杆指示
        let joystickHint = SKShapeNode(circleOfRadius: 50)
        joystickHint.fillColor = UIColor.white.withAlphaComponent(0.1)
        joystickHint.strokeColor = UIColor.white.withAlphaComponent(0.3)
        joystickHint.lineWidth = 2
        joystickHint.position = CGPoint(x: -screenSize.width/2 + 80, y: -screenSize.height/2 + 80)
        joystickHint.zPosition = 5
        addChild(joystickHint)
        
        // 右侧射击区域指示
        let shootHint = SKShapeNode(rect: CGRect(
            x: screenSize.width/4,
            y: -screenSize.height/2,
            width: screenSize.width/4,
            height: screenSize.height
        ))
        shootHint.fillColor = UIColor.red.withAlphaComponent(0.05)
        shootHint.strokeColor = UIColor.red.withAlphaComponent(0.2)
        shootHint.lineWidth = 1
        shootHint.position = CGPoint(x: 0, y: 0)
        shootHint.zPosition = 5
        addChild(shootHint)
        
        print("UI elements created with positions:")
        print("- Health bar: \(healthBar.position)")
        print("- Ammo display: \(ammoDisplay.position)")
        print("- Level label: \(levelLabel.position)")
    }
    
    func updatePlayerStatus(hp: Int, maxHP: Int, level: Int, exp: Int, maxExp: Int) {
        healthBar.updateHealth(current: hp, max: maxHP)
        levelLabel.text = "LV.\(level)"
        expBar.updateExperience(current: exp, max: maxExp)
    }
    
    func updateAmmo(current: Int, max: Int, weaponType: WeaponType) {
        ammoDisplay.updateAmmo(current: current, max: max, weaponType: weaponType)
    }
    
    func showMessage(_ text: String, duration: TimeInterval = 2.0) {
        let messageLabel = SKLabelNode(text: text)
        messageLabel.fontName = "Arial-Bold"
        messageLabel.fontSize = 18
        messageLabel.fontColor = .yellow
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageLabel.zPosition = 10
        addChild(messageLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        messageLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
}

class HealthBar: SKNode {
    
    private var background: SKShapeNode!
    private var foreground: SKShapeNode!
    private var border: SKShapeNode!
    private var hpLabel: SKLabelNode!
    private var barSize: CGSize
    
    init(size: CGSize) {
        self.barSize = size
        super.init()
        setupHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHealthBar() {
        background = SKShapeNode(rect: CGRect(origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2), size: barSize))
        background.fillColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        background.strokeColor = .clear
        background.zPosition = 1
        addChild(background)
        
        foreground = SKShapeNode(rect: CGRect(origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2), size: barSize))
        foreground.fillColor = .red
        foreground.strokeColor = .clear
        foreground.zPosition = 2
        addChild(foreground)
        
        border = SKShapeNode(rect: CGRect(origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2), size: barSize))
        border.fillColor = .clear
        border.strokeColor = .white
        border.lineWidth = 2
        border.zPosition = 3
        addChild(border)
        
        hpLabel = SKLabelNode(text: "100/100")
        hpLabel.fontName = "Arial-Bold"
        hpLabel.fontSize = 12
        hpLabel.fontColor = .white
        hpLabel.position = CGPoint(x: 0, y: -4)
        hpLabel.zPosition = 4
        addChild(hpLabel)
    }
    
    func updateHealth(current: Int, max: Int) {
        let healthPercentage = CGFloat(current) / CGFloat(max)
        let newWidth = barSize.width * healthPercentage
        
        foreground.path = CGPath(rect: CGRect(
            x: -barSize.width/2,
            y: -barSize.height/2,
            width: newWidth,
            height: barSize.height
        ), transform: nil)
        
        if healthPercentage > 0.6 {
            foreground.fillColor = .green
        } else if healthPercentage > 0.3 {
            foreground.fillColor = .yellow
        } else {
            foreground.fillColor = .red
        }
        
        hpLabel.text = "\(current)/\(max)"
    }
}

class AmmoDisplay: SKNode {
    
    private var ammoLabel: SKLabelNode!
    private var weaponIcon: SKSpriteNode!
    private var background: SKShapeNode!
    
    override init() {
        super.init()
        setupAmmoDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAmmoDisplay() {
        background = SKShapeNode(rect: CGRect(x: -40, y: -15, width: 80, height: 30))
        background.fillColor = UIColor.black.withAlphaComponent(0.6)
        background.strokeColor = .white
        background.lineWidth = 1
        background.zPosition = 1
        addChild(background)
        
        weaponIcon = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 20))
        weaponIcon.position = CGPoint(x: -20, y: 0)
        weaponIcon.zPosition = 2
        addChild(weaponIcon)
        
        ammoLabel = SKLabelNode(text: "∞")
        ammoLabel.fontName = "Arial-Bold"
        ammoLabel.fontSize = 14
        ammoLabel.fontColor = .white
        ammoLabel.position = CGPoint(x: 10, y: -5)
        ammoLabel.zPosition = 2
        addChild(ammoLabel)
    }
    
    func updateAmmo(current: Int, max: Int, weaponType: WeaponType) {
        if max == -1 {
            ammoLabel.text = "∞"
        } else {
            ammoLabel.text = "\(current)/\(max)"
        }
        
        switch weaponType {
        case .pistol:
            weaponIcon.color = .white
        case .rifle:
            weaponIcon.color = .blue
        case .shotgun:
            weaponIcon.color = .orange
        case .sniper:
            weaponIcon.color = .purple
        }
    }
}

class ExperienceBar: SKNode {
    
    private var background: SKShapeNode!
    private var foreground: SKShapeNode!
    private var barSize: CGSize
    
    init(size: CGSize) {
        self.barSize = size
        super.init()
        setupExpBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupExpBar() {
        background = SKShapeNode(rect: CGRect(origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2), size: barSize))
        background.fillColor = .darkGray
        background.strokeColor = .white
        background.lineWidth = 1
        background.zPosition = 1
        addChild(background)
        
        foreground = SKShapeNode(rect: CGRect(origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2), size: CGSize(width: 0, height: barSize.height)))
        foreground.fillColor = .cyan
        foreground.strokeColor = .clear
        foreground.zPosition = 2
        addChild(foreground)
    }
    
    func updateExperience(current: Int, max: Int) {
        let expPercentage = CGFloat(current) / CGFloat(max)
        let newWidth = barSize.width * expPercentage
        
        foreground.path = CGPath(rect: CGRect(
            x: -barSize.width/2,
            y: -barSize.height/2,
            width: newWidth,
            height: barSize.height
        ), transform: nil)
    }
} 