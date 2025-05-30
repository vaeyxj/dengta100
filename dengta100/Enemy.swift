//
//  Enemy.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import GameplayKit

// MARK: - 敌人状态枚举
enum EnemyState {
    case patrol     // 巡逻
    case alert      // 警戒
    case chase      // 追击
    case attack     // 攻击
    case dead       // 死亡
}

// MARK: - 敌人类型枚举
enum EnemyType {
    case slime      // 史莱姆
    case skeleton   // 骷髅战士
    case mage       // 法师
    case dragon     // 巨龙守卫
    case assassin   // 暗影刺客
    
    var baseHP: Int {
        switch self {
        case .slime: return 30
        case .skeleton: return 60
        case .mage: return 40
        case .dragon: return 120
        case .assassin: return 50
        }
    }
    
    var baseAttack: Int {
        switch self {
        case .slime: return 8
        case .skeleton: return 15
        case .mage: return 20
        case .dragon: return 25
        case .assassin: return 18
        }
    }
    
    var baseDefense: Int {
        switch self {
        case .slime: return 2
        case .skeleton: return 8
        case .mage: return 3
        case .dragon: return 15
        case .assassin: return 5
        }
    }
    
    var moveSpeed: CGFloat {
        switch self {
        case .slime: return 50
        case .skeleton: return 80
        case .mage: return 60
        case .dragon: return 40
        case .assassin: return 120
        }
    }
    
    var detectionRange: CGFloat {
        switch self {
        case .slime: return 80
        case .skeleton: return 100
        case .mage: return 120
        case .dragon: return 90
        case .assassin: return 150
        }
    }
    
    var attackRange: CGFloat {
        switch self {
        case .slime: return 35
        case .skeleton: return 40
        case .mage: return 150
        case .dragon: return 60
        case .assassin: return 45
        }
    }
}

class Enemy: SKSpriteNode {
    
    // MARK: - 基础属性
    var enemyType: EnemyType
    var maxHP: Int
    var currentHP: Int
    var attackPower: Int
    var defense: Int
    var moveSpeed: CGFloat
    var detectionRange: CGFloat
    var attackRange: CGFloat
    var attackCooldown: TimeInterval = 1.0
    var lastAttackTime: TimeInterval = 0
    
    // MARK: - AI状态
    var currentState: EnemyState = .patrol
    var player: Player?
    var patrolPath: [CGPoint] = []
    var currentPatrolIndex: Int = 0
    var patrolDirection: Int = 1
    
    // MARK: - 视野检测
    var visionAngle: CGFloat = CGFloat.pi / 3 // 60度视野
    var lastKnownPlayerPosition: CGPoint?
    var alertTimer: TimeInterval = 0
    var maxAlertTime: TimeInterval = 3.0
    
    // MARK: - 移动相关
    var targetPosition: CGPoint?
    var isMoving: Bool = false
    
    // MARK: - 初始化
    init(type: EnemyType, level: Int = 1) {
        self.enemyType = type
        
        // 根据等级调整属性
        let levelMultiplier = 1.0 + (Double(level - 1) * 0.2)
        self.maxHP = Int(Double(type.baseHP) * levelMultiplier)
        self.currentHP = maxHP
        self.attackPower = Int(Double(type.baseAttack) * levelMultiplier)
        self.defense = Int(Double(type.baseDefense) * levelMultiplier)
        self.moveSpeed = type.moveSpeed
        self.detectionRange = type.detectionRange
        self.attackRange = type.attackRange
        
        // 设置外观
        let texture = SKTexture(imageNamed: "\(type)_placeholder")
        let size = CGSize(width: 32, height: 32)
        
        super.init(texture: texture, color: Enemy.getColorForType(type), size: size)
        
        setupEnemy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEnemy() {
        // 设置物理体
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.enemy
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 0.8
        
        // 设置名称和Z位置
        name = "enemy_\(enemyType)"
        zPosition = 8
        
        // 创建血条
        createHealthBar()
    }
    
    private static func getColorForType(_ type: EnemyType) -> UIColor {
        switch type {
        case .slime: return .green
        case .skeleton: return .gray
        case .mage: return .purple
        case .dragon: return .red
        case .assassin: return .black
        }
    }
    
    // MARK: - 血条系统
    private var healthBarBackground: SKShapeNode?
    private var healthBarForeground: SKShapeNode?
    
    private func createHealthBar() {
        let barWidth: CGFloat = 30
        let barHeight: CGFloat = 4
        let barY: CGFloat = size.height/2 + 8
        
        // 背景
        healthBarBackground = SKShapeNode(rect: CGRect(x: -barWidth/2, y: barY, width: barWidth, height: barHeight))
        healthBarBackground?.fillColor = .red
        healthBarBackground?.strokeColor = .clear
        healthBarBackground?.zPosition = 1
        addChild(healthBarBackground!)
        
        // 前景
        healthBarForeground = SKShapeNode(rect: CGRect(x: -barWidth/2, y: barY, width: barWidth, height: barHeight))
        healthBarForeground?.fillColor = .green
        healthBarForeground?.strokeColor = .clear
        healthBarForeground?.zPosition = 2
        addChild(healthBarForeground!)
    }
    
    private func updateHealthBar() {
        let healthPercentage = CGFloat(currentHP) / CGFloat(maxHP)
        let barWidth: CGFloat = 30
        
        healthBarForeground?.path = CGPath(rect: CGRect(
            x: -barWidth/2,
            y: size.height/2 + 8,
            width: barWidth * healthPercentage,
            height: 4
        ), transform: nil)
        
        // 根据血量改变颜色
        if healthPercentage > 0.6 {
            healthBarForeground?.fillColor = .green
        } else if healthPercentage > 0.3 {
            healthBarForeground?.fillColor = .yellow
        } else {
            healthBarForeground?.fillColor = .red
        }
    }
    
    // MARK: - AI更新
    func update(deltaTime: TimeInterval, player: Player) {
        self.player = player
        
        switch currentState {
        case .patrol:
            updatePatrol(deltaTime: deltaTime)
        case .alert:
            updateAlert(deltaTime: deltaTime)
        case .chase:
            updateChase(deltaTime: deltaTime)
        case .attack:
            updateAttack(deltaTime: deltaTime)
        case .dead:
            return
        }
        
        // 检测玩家
        checkPlayerDetection()
        
        // 更新移动
        updateMovement(deltaTime: deltaTime)
    }
    
    // MARK: - 巡逻行为
    private func updatePatrol(deltaTime: TimeInterval) {
        if patrolPath.isEmpty {
            generatePatrolPath()
        }
        
        if let target = getCurrentPatrolTarget() {
            moveTowards(target)
            
            // 检查是否到达巡逻点
            let distance = distanceTo(target)
            if distance < 10 {
                moveToNextPatrolPoint()
            }
        }
    }
    
    private func generatePatrolPath() {
        // 生成简单的巡逻路径
        let center = position
        let radius: CGFloat = 60
        
        patrolPath = [
            CGPoint(x: center.x - radius, y: center.y),
            CGPoint(x: center.x, y: center.y + radius),
            CGPoint(x: center.x + radius, y: center.y),
            CGPoint(x: center.x, y: center.y - radius)
        ]
    }
    
    private func getCurrentPatrolTarget() -> CGPoint? {
        guard !patrolPath.isEmpty else { return nil }
        return patrolPath[currentPatrolIndex]
    }
    
    private func moveToNextPatrolPoint() {
        currentPatrolIndex += patrolDirection
        
        if currentPatrolIndex >= patrolPath.count {
            currentPatrolIndex = patrolPath.count - 2
            patrolDirection = -1
        } else if currentPatrolIndex < 0 {
            currentPatrolIndex = 1
            patrolDirection = 1
        }
    }
    
    // MARK: - 警戒行为
    private func updateAlert(deltaTime: TimeInterval) {
        alertTimer += deltaTime
        
        if let lastPos = lastKnownPlayerPosition {
            moveTowards(lastPos)
            
            // 到达最后已知位置后，如果没有发现玩家，返回巡逻
            if distanceTo(lastPos) < 20 && alertTimer > maxAlertTime {
                currentState = .patrol
                alertTimer = 0
            }
        }
    }
    
    // MARK: - 追击行为
    private func updateChase(deltaTime: TimeInterval) {
        guard let player = player else { return }
        
        let distanceToPlayer = distanceTo(player.position)
        
        if distanceToPlayer <= attackRange {
            currentState = .attack
        } else if distanceToPlayer > detectionRange * 1.5 {
            // 玩家逃得太远，进入警戒状态
            lastKnownPlayerPosition = player.position
            currentState = .alert
            alertTimer = 0
        } else {
            moveTowards(player.position)
        }
    }
    
    // MARK: - 攻击行为
    private func updateAttack(deltaTime: TimeInterval) {
        guard let player = player else { return }
        
        let distanceToPlayer = distanceTo(player.position)
        
        if distanceToPlayer > attackRange {
            currentState = .chase
        } else if canAttack() {
            performAttack(target: player)
        }
    }
    
    // MARK: - 玩家检测
    private func checkPlayerDetection() {
        guard let player = player, currentState != .dead else { return }
        
        let distanceToPlayer = distanceTo(player.position)
        
        if distanceToPlayer <= detectionRange {
            if isPlayerInVision(player.position) {
                // 发现玩家
                if currentState == .patrol || currentState == .alert {
                    currentState = .chase
                    showAlertEffect()
                }
                lastKnownPlayerPosition = player.position
            }
        }
    }
    
    private func isPlayerInVision(_ playerPosition: CGPoint) -> Bool {
        // 计算到玩家的方向
        let directionToPlayer = CGVector(
            dx: playerPosition.x - position.x,
            dy: playerPosition.y - position.y
        )
        
        // 计算敌人面向方向（基于移动方向或默认方向）
        let facingDirection = CGVector(dx: 1, dy: 0) // 默认面向右
        
        // 计算角度差
        let angleToPlayer = atan2(directionToPlayer.dy, directionToPlayer.dx)
        let facingAngle = atan2(facingDirection.dy, facingDirection.dx)
        let angleDiff = abs(angleToPlayer - facingAngle)
        
        return angleDiff <= visionAngle / 2
    }
    
    private func showAlertEffect() {
        // 显示感叹号
        let alertLabel = SKLabelNode(text: "!")
        alertLabel.fontName = "Arial-Bold"
        alertLabel.fontSize = 20
        alertLabel.fontColor = .red
        alertLabel.position = CGPoint(x: 0, y: size.height/2 + 20)
        addChild(alertLabel)
        
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        alertLabel.run(SKAction.sequence([scale, fadeOut, remove]))
    }
    
    // MARK: - 移动系统
    private func moveTowards(_ target: CGPoint) {
        targetPosition = target
        isMoving = true
    }
    
    private func updateMovement(deltaTime: TimeInterval) {
        guard isMoving, let target = targetPosition else {
            physicsBody?.velocity = CGVector.zero
            return
        }
        
        let direction = CGVector(
            dx: target.x - position.x,
            dy: target.y - position.y
        )
        let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        
        if distance > 5 {
            let normalizedDirection = CGVector(
                dx: direction.dx / distance,
                dy: direction.dy / distance
            )
            
            let velocity = CGVector(
                dx: normalizedDirection.dx * moveSpeed,
                dy: normalizedDirection.dy * moveSpeed
            )
            
            physicsBody?.velocity = velocity
        } else {
            physicsBody?.velocity = CGVector.zero
            isMoving = false
        }
    }
    
    // MARK: - 攻击系统
    private func canAttack() -> Bool {
        let currentTime = CACurrentMediaTime()
        return currentTime - lastAttackTime >= attackCooldown
    }
    
    private func performAttack(target: Player) {
        lastAttackTime = CACurrentMediaTime()
        
        switch enemyType {
        case .slime, .skeleton, .dragon, .assassin:
            // 近战攻击
            performMeleeAttack(target: target)
        case .mage:
            // 远程攻击
            performRangedAttack(target: target)
        }
    }
    
    private func performMeleeAttack(target: Player) {
        // 近战攻击动画
        let originalPosition = position
        let attackPosition = CGPoint(
            x: target.position.x + (position.x - target.position.x) * 0.3,
            y: target.position.y + (position.y - target.position.y) * 0.3
        )
        
        let moveToTarget = SKAction.move(to: attackPosition, duration: 0.2)
        let moveBack = SKAction.move(to: originalPosition, duration: 0.2)
        let attack = SKAction.run {
            target.takeDamage(self.attackPower)
        }
        
        run(SKAction.sequence([moveToTarget, attack, moveBack]))
    }
    
    private func performRangedAttack(target: Player) {
        // 创建敌人子弹
        let direction = CGVector(
            dx: target.position.x - position.x,
            dy: target.position.y - position.y
        )
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let normalizedDirection = CGVector(
            dx: direction.dx / length,
            dy: direction.dy / length
        )
        
        let bullet = Bullet(
            startPosition: position,
            direction: normalizedDirection,
            damage: attackPower,
            range: attackRange,
            weaponType: .pistol,
            isPlayerBullet: false
        )
        
        parent?.addChild(bullet)
    }
    
    // MARK: - 战斗系统
    func takeDamage(_ damage: Int) {
        let actualDamage = max(damage - defense, 1)
        currentHP = max(currentHP - actualDamage, 0)
        
        updateHealthBar()
        showDamageEffect(actualDamage)
        
        // 受到攻击时进入追击状态
        if currentState == .patrol {
            currentState = .chase
        }
        
        if currentHP <= 0 {
            die()
        }
    }
    
    private func showDamageEffect(_ damage: Int) {
        let damageLabel = SKLabelNode(text: "-\(damage)")
        damageLabel.fontName = "Arial-Bold"
        damageLabel.fontSize = 14
        damageLabel.fontColor = .white
        damageLabel.position = CGPoint(x: 0, y: size.height/2 + 15)
        addChild(damageLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let remove = SKAction.removeFromParent()
        damageLabel.run(SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove]))
        
        // 受伤闪烁
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(blink, count: 2))
    }
    
    private func die() {
        currentState = .dead
        physicsBody?.categoryBitMask = PhysicsCategory.none
        
        // 死亡动画
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scale = SKAction.scale(to: 0.8, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([SKAction.group([fadeOut, scale]), remove]))
        
        // 掉落经验值或道具
        dropRewards()
    }
    
    private func dropRewards() {
        // 这里可以添加掉落物品的逻辑
        print("敌人死亡，掉落奖励")
    }
    
    // MARK: - 工具方法
    private func distanceTo(_ point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
} 