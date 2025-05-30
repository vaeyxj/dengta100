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
        zPosition = 100
        createStatusBar()
        createHealthBar()
        createAmmoDisplay()
        createLevelAndExpBar()
    }
    
    private func createStatusBar() {
        statusBar = SKNode()
        statusBar.position = CGPoint(x: 0, y: screenSize.height/2 - 40)
        addChild(statusBar)
        
        let background = SKShapeNode(rect: CGRect(
            x: -screenSize.width/2,
            y: -20,
            width: screenSize.width,
            height: 40
        ))
        background.fillColor = UIColor.black.withAlphaComponent(0.5)
        background.strokeColor = .clear
        background.zPosition = 0
        statusBar.addChild(background)
    }
    
    private func createHealthBar() {
        healthBar = HealthBar(size: CGSize(width: 200, height: 20))
        healthBar.position = CGPoint(x: -screenSize.width/2 + 120, y: screenSize.height/2 - 30)
        addChild(healthBar)
    }
    
    private func createAmmoDisplay() {
        ammoDisplay = AmmoDisplay()
        ammoDisplay.position = CGPoint(x: screenSize.width/2 - 80, y: screenSize.height/2 - 30)
        addChild(ammoDisplay)
    }
    
    private func createLevelAndExpBar() {
        levelLabel = SKLabelNode(text: "LV.1")
        levelLabel.fontName = "Arial-Bold"
        levelLabel.fontSize = 16
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -screenSize.width/2 + 50, y: screenSize.height/2 - 60)
        addChild(levelLabel)
        
        expBar = ExperienceBar(size: CGSize(width: 150, height: 8))
        expBar.position = CGPoint(x: -screenSize.width/2 + 150, y: screenSize.height/2 - 55)
        addChild(expBar)
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