//
//  Player.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    
    // MARK: - 玩家属性
    var maxHP: Int = 100
    var currentHP: Int = 100
    var attackPower: Int = 20
    var defense: Int = 5
    var moveSpeed: CGFloat = 150.0
    var fireRate: TimeInterval = 0.3
    var range: CGFloat = 200.0
    
    // MARK: - 状态变量
    var isMoving: Bool = false
    var lastFireTime: TimeInterval = 0
    var currentWeapon: WeaponType = .pistol
    
    // MARK: - 移动相关
    var moveDirection: CGVector = CGVector.zero
    var targetPosition: CGPoint?
    
    // MARK: - 初始化
    convenience init() {
        // 使用占位符纹理，后续可替换为美术资源
        let texture = SKTexture(imageNamed: "player_placeholder")
        self.init(texture: texture, color: .blue, size: CGSize(width: 32, height: 32))
        
        setupPlayer()
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlayer()
    }
    
    private func setupPlayer() {
        // 设置物理体
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyBullet | PhysicsCategory.item
        physicsBody?.collisionBitMask = PhysicsCategory.wall
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0.8
        
        // 设置名称
        name = "player"
        
        // 设置Z位置
        zPosition = 10
    }
    
    // MARK: - 移动控制
    func setMoveDirection(_ direction: CGVector) {
        moveDirection = direction
        isMoving = direction.dx != 0 || direction.dy != 0
    }
    
    func updateMovement(deltaTime: TimeInterval) {
        if isMoving {
            let velocity = CGVector(
                dx: moveDirection.dx * moveSpeed,
                dy: moveDirection.dy * moveSpeed
            )
            physicsBody?.velocity = velocity
        } else {
            physicsBody?.velocity = CGVector.zero
        }
    }
    
    // MARK: - 射击系统
    func canFire(currentTime: TimeInterval) -> Bool {
        return currentTime - lastFireTime >= fireRate
    }
    
    func fire(towards target: CGPoint, currentTime: TimeInterval) -> Bullet? {
        guard canFire(currentTime: currentTime) else { return nil }
        
        lastFireTime = currentTime
        
        // 计算射击方向
        let direction = CGVector(
            dx: target.x - position.x,
            dy: target.y - position.y
        )
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let normalizedDirection = CGVector(
            dx: direction.dx / length,
            dy: direction.dy / length
        )
        
        // 创建子弹
        let bullet = Bullet(
            startPosition: position,
            direction: normalizedDirection,
            damage: attackPower,
            range: range,
            weaponType: currentWeapon
        )
        
        return bullet
    }
    
    // MARK: - 战斗系统
    func takeDamage(_ damage: Int) {
        let actualDamage = max(damage - defense, 1)
        currentHP = max(currentHP - actualDamage, 0)
        
        // 受伤效果
        showDamageEffect(actualDamage)
        
        if currentHP <= 0 {
            die()
        }
    }
    
    func heal(_ amount: Int) {
        currentHP = min(currentHP + amount, maxHP)
    }
    
    private func showDamageEffect(_ damage: Int) {
        // 创建伤害数字显示
        let damageLabel = SKLabelNode(text: "-\(damage)")
        damageLabel.fontName = "Arial-Bold"
        damageLabel.fontSize = 16
        damageLabel.fontColor = .red
        damageLabel.position = CGPoint(x: 0, y: size.height/2 + 10)
        addChild(damageLabel)
        
        // 动画效果
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove])
        damageLabel.run(sequence)
        
        // 角色闪烁效果
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(blink, count: 3))
    }
    
    private func die() {
        // 死亡处理
        print("玩家死亡")
        // 这里可以添加死亡动画和游戏结束逻辑
    }
    
    // MARK: - 升级系统
    func levelUp() {
        // 升级时提升属性
        maxHP += 10
        currentHP = maxHP
        attackPower += 2
        defense += 1
        
        // 升级特效
        showLevelUpEffect()
    }
    
    private func showLevelUpEffect() {
        let levelUpLabel = SKLabelNode(text: "LEVEL UP!")
        levelUpLabel.fontName = "Arial-Bold"
        levelUpLabel.fontSize = 20
        levelUpLabel.fontColor = .yellow
        levelUpLabel.position = CGPoint(x: 0, y: size.height/2 + 20)
        addChild(levelUpLabel)
        
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scale, SKAction.wait(forDuration: 1.0), fadeOut, remove])
        levelUpLabel.run(sequence)
    }
}

// MARK: - 武器类型枚举
enum WeaponType {
    case pistol     // 手枪
    case rifle      // 步枪
    case shotgun    // 霰弹枪
    case sniper     // 狙击枪
    
    var fireRate: TimeInterval {
        switch self {
        case .pistol: return 0.3
        case .rifle: return 0.15
        case .shotgun: return 0.8
        case .sniper: return 1.2
        }
    }
    
    var damage: Int {
        switch self {
        case .pistol: return 15
        case .rifle: return 12
        case .shotgun: return 25
        case .sniper: return 40
        }
    }
    
    var range: CGFloat {
        switch self {
        case .pistol: return 200
        case .rifle: return 250
        case .shotgun: return 120
        case .sniper: return 400
        }
    }
}

// MARK: - 物理碰撞类别
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let playerBullet: UInt32 = 0b100
    static let enemyBullet: UInt32 = 0b1000
    static let wall: UInt32 = 0b10000
    static let item: UInt32 = 0b100000
} 