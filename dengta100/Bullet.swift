//
//  Bullet.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import GameplayKit

class Bullet: SKSpriteNode {
    
    // MARK: - 子弹属性
    var damage: Int
    var bulletSpeed: CGFloat = 400.0  // 重命名避免与SKNode.speed冲突
    var maxRange: CGFloat
    var traveledDistance: CGFloat = 0
    var direction: CGVector
    var weaponType: WeaponType
    var isPlayerBullet: Bool
    
    // MARK: - 初始化
    init(startPosition: CGPoint, direction: CGVector, damage: Int, range: CGFloat, weaponType: WeaponType, isPlayerBullet: Bool = true) {
        self.damage = damage
        self.maxRange = range
        self.direction = direction
        self.weaponType = weaponType
        self.isPlayerBullet = isPlayerBullet
        
        // 根据武器类型设置子弹外观
        let bulletSize = CGSize(width: 4, height: 8)
        let texture = SKTexture(imageNamed: "bullet_placeholder")
        
        super.init(texture: texture, color: isPlayerBullet ? .yellow : .red, size: bulletSize)
        
        self.position = startPosition
        setupBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBullet() {
        // 设置物理体
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = isPlayerBullet ? PhysicsCategory.playerBullet : PhysicsCategory.enemyBullet
        physicsBody?.contactTestBitMask = isPlayerBullet ? PhysicsCategory.enemy : PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.wall
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.affectedByGravity = false
        
        // 设置名称
        name = isPlayerBullet ? "playerBullet" : "enemyBullet"
        
        // 设置Z位置
        zPosition = 5
        
        // 设置初始速度
        let velocity = CGVector(
            dx: direction.dx * bulletSpeed,
            dy: direction.dy * bulletSpeed
        )
        physicsBody?.velocity = velocity
        
        // 根据方向旋转子弹
        let angle = atan2(direction.dy, direction.dx) + CGFloat.pi / 2
        zRotation = angle
    }
    
    // MARK: - 更新方法
    func update(deltaTime: TimeInterval) {
        // 计算移动距离
        let moveDistance = bulletSpeed * CGFloat(deltaTime)
        traveledDistance += moveDistance
        
        // 检查是否超出射程
        if traveledDistance >= maxRange {
            removeFromParent()
        }
    }
    
    // MARK: - 碰撞处理
    func hitTarget() {
        // 创建命中特效
        createHitEffect()
        
        // 移除子弹
        removeFromParent()
    }
    
    func hitWall() {
        // 创建墙壁命中特效
        createWallHitEffect()
        
        // 移除子弹
        removeFromParent()
    }
    
    func createHitEffect() {
        guard let parent = parent else { return }
        
        // 创建命中粒子效果
        let hitEffect = SKEmitterNode()
        hitEffect.particleTexture = SKTexture(imageNamed: "spark_placeholder")
        hitEffect.particleBirthRate = 50
        hitEffect.numParticlesToEmit = 10
        hitEffect.particleLifetime = 0.3
        hitEffect.particleScale = 0.1
        hitEffect.particleScaleRange = 0.05
        hitEffect.particleSpeed = 50
        hitEffect.particleSpeedRange = 25
        hitEffect.emissionAngle = 0
        hitEffect.emissionAngleRange = CGFloat.pi * 2
        hitEffect.particleColor = isPlayerBullet ? .orange : .red
        hitEffect.position = position
        hitEffect.zPosition = 15
        
        parent.addChild(hitEffect)
        
        // 自动移除特效
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        hitEffect.run(SKAction.sequence([wait, remove]))
    }
    
    private func createWallHitEffect() {
        guard let parent = parent else { return }
        
        // 创建墙壁命中特效
        let sparkEffect = SKEmitterNode()
        sparkEffect.particleTexture = SKTexture(imageNamed: "spark_placeholder")
        sparkEffect.particleBirthRate = 30
        sparkEffect.numParticlesToEmit = 5
        sparkEffect.particleLifetime = 0.2
        sparkEffect.particleScale = 0.08
        sparkEffect.particleSpeed = 30
        sparkEffect.particleSpeedRange = 15
        sparkEffect.emissionAngle = 0
        sparkEffect.emissionAngleRange = CGFloat.pi
        sparkEffect.particleColor = .white
        sparkEffect.position = position
        sparkEffect.zPosition = 15
        
        parent.addChild(sparkEffect)
        
        // 自动移除特效
        let wait = SKAction.wait(forDuration: 0.3)
        let remove = SKAction.removeFromParent()
        sparkEffect.run(SKAction.sequence([wait, remove]))
    }
}

// MARK: - 特殊子弹类型
class ShotgunBullet: Bullet {
    
    // 霰弹枪子弹，散射效果
    static func createShotgunBullets(startPosition: CGPoint, direction: CGVector, damage: Int, range: CGFloat, isPlayerBullet: Bool = true) -> [Bullet] {
        var bullets: [Bullet] = []
        let bulletCount = 5
        let spreadAngle: CGFloat = 0.3 // 散射角度
        
        for i in 0..<bulletCount {
            let angleOffset = (CGFloat(i) - CGFloat(bulletCount - 1) / 2) * spreadAngle / CGFloat(bulletCount - 1)
            let bulletDirection = CGVector(
                dx: direction.dx * cos(angleOffset) - direction.dy * sin(angleOffset),
                dy: direction.dx * sin(angleOffset) + direction.dy * cos(angleOffset)
            )
            
            let bullet = Bullet(
                startPosition: startPosition,
                direction: bulletDirection,
                damage: damage / 2, // 每颗子弹伤害减半
                range: range * 0.8, // 射程稍短
                weaponType: .shotgun,
                isPlayerBullet: isPlayerBullet
            )
            bullets.append(bullet)
        }
        
        return bullets
    }
}

class SniperBullet: Bullet {
    
    // 狙击枪子弹，穿透效果
    private func setupSniperBullet() {  // 移除override关键字
        // 设置物理体
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = isPlayerBullet ? PhysicsCategory.playerBullet : PhysicsCategory.enemyBullet
        physicsBody?.contactTestBitMask = isPlayerBullet ? PhysicsCategory.enemy : PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.wall // 只与墙壁碰撞
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.linearDamping = 0
        physicsBody?.affectedByGravity = false
        
        // 设置名称
        name = isPlayerBullet ? "playerBullet" : "enemyBullet"
        
        // 设置Z位置
        zPosition = 5
        
        // 增加子弹大小和速度
        bulletSpeed = 600.0
        size = CGSize(width: 6, height: 12)
        color = isPlayerBullet ? .cyan : .purple
        
        // 设置初始速度
        let velocity = CGVector(
            dx: direction.dx * bulletSpeed,
            dy: direction.dy * bulletSpeed
        )
        physicsBody?.velocity = velocity
        
        // 根据方向旋转子弹
        let angle = atan2(direction.dy, direction.dx) + CGFloat.pi / 2
        zRotation = angle
    }
    
    override func hitTarget() {
        // 狙击枪子弹命中后不立即消失，可以穿透
        createHitEffect()
        
        // 减少一些伤害，但继续飞行
        damage = Int(CGFloat(damage) * 0.7)
        
        // 如果伤害太低，则移除
        if damage < 5 {
            removeFromParent()
        }
    }
} 