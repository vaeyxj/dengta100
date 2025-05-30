//
//  GameScene.swift
//  dengta100
//
//  Created by 喻西剑 on 2025/5/30.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - 游戏对象
    var player: Player!
    var enemies: [Enemy] = []
    var bullets: [Bullet] = []
    
    // MARK: - 控制系统
    var virtualJoystick: VirtualJoystick!
    var shootingArea: ShootingArea!
    
    // MARK: - UI系统
    var gameUI: GameUI!
    
    // MARK: - 游戏状态
    var currentLevel: Int = 1
    var currentExp: Int = 0
    var maxExp: Int = 100
    var gameTime: TimeInterval = 0
    
    // MARK: - 更新相关
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - 场景加载
    override func sceneDidLoad() {
        setupScene()
        setupPlayer()
        setupControls()
        setupUI()
        setupEnemies()
        setupPhysics()
    }
    
    private func setupScene() {
        // 设置场景背景
        backgroundColor = SKColor.darkGray
        
        // 设置场景边界
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.categoryBitMask = PhysicsCategory.wall
        physicsBody = border
    }
    
    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
    }
    
    private func setupControls() {
        // 创建虚拟摇杆
        virtualJoystick = VirtualJoystick()
        virtualJoystick.delegate = self
        virtualJoystick.position = CGPoint(
            x: -size.width/2 + 100,
            y: -size.height/2 + 100
        )
        addChild(virtualJoystick)
        
        // 创建射击区域
        shootingArea = ShootingArea()
        shootingArea.delegate = self
        shootingArea.position = CGPoint(x: size.width/4, y: 0)
        shootingArea.isAutoFire = true
        addChild(shootingArea)
    }
    
    private func setupUI() {
        gameUI = GameUI(screenSize: size)
        addChild(gameUI)
        
        // 初始化UI显示
        updateUI()
    }
    
    private func setupEnemies() {
        // 创建测试敌人
        createTestEnemies()
    }
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector.zero
    }
    
    // MARK: - 敌人生成
    private func createTestEnemies() {
        // 生成几个测试敌人
        let enemyPositions = [
            CGPoint(x: 200, y: 100),
            CGPoint(x: -150, y: 200),
            CGPoint(x: 100, y: -150),
            CGPoint(x: -200, y: -100)
        ]
        
        for (index, position) in enemyPositions.enumerated() {
            let enemyType: EnemyType = [.slime, .skeleton, .mage, .dragon][index % 4]
            let enemy = Enemy(type: enemyType, level: 1)
            enemy.position = position
            addChild(enemy)
            enemies.append(enemy)
        }
    }
    
    // MARK: - 游戏更新
    override func update(_ currentTime: TimeInterval) {
        // 计算deltaTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        gameTime += deltaTime
        
        // 更新游戏对象
        updatePlayer(deltaTime: deltaTime)
        updateEnemies(deltaTime: deltaTime)
        updateBullets(deltaTime: deltaTime)
        
        // 清理死亡的对象
        cleanupDeadObjects()
        
        // 更新UI
        updateUI()
    }
    
    private func updatePlayer(deltaTime: TimeInterval) {
        player.updateMovement(deltaTime: deltaTime)
    }
    
    private func updateEnemies(deltaTime: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime, player: player)
        }
    }
    
    private func updateBullets(deltaTime: TimeInterval) {
        for bullet in bullets {
            bullet.update(deltaTime: deltaTime)
        }
    }
    
    private func cleanupDeadObjects() {
        // 清理超出范围的子弹
        bullets.removeAll { bullet in
            if bullet.parent == nil {
                return true
            }
            
            let distance = sqrt(
                pow(bullet.position.x - player.position.x, 2) +
                pow(bullet.position.y - player.position.y, 2)
            )
            
            if distance > 1000 {
                bullet.removeFromParent()
                return true
            }
            
            return false
        }
        
        // 清理死亡的敌人
        enemies.removeAll { enemy in
            return enemy.parent == nil
        }
    }
    
    private func updateUI() {
        gameUI.updatePlayerStatus(
            hp: player.currentHP,
            maxHP: player.maxHP,
            level: currentLevel,
            exp: currentExp,
            maxExp: maxExp
        )
        
        gameUI.updateAmmo(
            current: -1, // 无限弹药
            max: -1,
            weaponType: player.currentWeapon
        )
    }
    
    // MARK: - 射击处理
    private func firePlayerBullet(towards target: CGPoint) {
        let currentTime = CACurrentMediaTime()
        
        if let bullet = player.fire(towards: target, currentTime: currentTime) {
            addChild(bullet)
            bullets.append(bullet)
        }
    }
    
    // MARK: - 经验和升级系统
    private func gainExperience(_ amount: Int) {
        currentExp += amount
        
        if currentExp >= maxExp {
            levelUp()
        }
    }
    
    private func levelUp() {
        currentLevel += 1
        currentExp = 0
        maxExp = Int(Double(maxExp) * 1.2) // 每级所需经验增加20%
        
        player.levelUp()
        gameUI.showMessage("等级提升！", duration: 2.0)
    }
    
    // MARK: - 游戏事件处理
    private func onEnemyDefeated(_ enemy: Enemy) {
        // 获得经验值
        let expGain = enemy.maxHP / 5
        gainExperience(expGain)
        
        // 显示经验获得提示
        gameUI.showMessage("+\(expGain) EXP", duration: 1.5)
    }
}

// MARK: - 虚拟摇杆代理
extension GameScene: VirtualJoystickDelegate {
    func joystickDidMove(direction: CGVector) {
        player.setMoveDirection(direction)
    }
    
    func joystickDidStop() {
        player.setMoveDirection(CGVector.zero)
    }
}

// MARK: - 射击区域代理
extension GameScene: ShootingAreaDelegate {
    func didStartShooting(at location: CGPoint) {
        firePlayerBullet(towards: location)
    }
    
    func didUpdateShootingTarget(_ location: CGPoint) {
        // 可以在这里添加瞄准线或其他视觉反馈
    }
    
    func didStopShooting() {
        // 停止射击时的处理
    }
    
    func didAutoFire(at location: CGPoint) {
        firePlayerBullet(towards: location)
    }
}

// MARK: - 物理碰撞代理
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // 玩家子弹击中敌人
        if (bodyA.categoryBitMask == PhysicsCategory.playerBullet && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemy && bodyB.categoryBitMask == PhysicsCategory.playerBullet) {
            
            let bullet = (bodyA.categoryBitMask == PhysicsCategory.playerBullet) ? bodyA.node as? Bullet : bodyB.node as? Bullet
            let enemy = (bodyA.categoryBitMask == PhysicsCategory.enemy) ? bodyA.node as? Enemy : bodyB.node as? Enemy
            
            if let bullet = bullet, let enemy = enemy {
                enemy.takeDamage(bullet.damage)
                bullet.hitTarget()
                
                // 如果敌人死亡，处理死亡事件
                if enemy.currentHP <= 0 {
                    onEnemyDefeated(enemy)
                }
            }
        }
        
        // 敌人子弹击中玩家
        if (bodyA.categoryBitMask == PhysicsCategory.enemyBullet && bodyB.categoryBitMask == PhysicsCategory.player) ||
           (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.enemyBullet) {
            
            let bullet = (bodyA.categoryBitMask == PhysicsCategory.enemyBullet) ? bodyA.node as? Bullet : bodyB.node as? Bullet
            let player = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as? Player : bodyB.node as? Player
            
            if let bullet = bullet, let player = player {
                player.takeDamage(bullet.damage)
                bullet.hitTarget()
            }
        }
        
        // 子弹击中墙壁
        if (bodyA.categoryBitMask == PhysicsCategory.playerBullet && bodyB.categoryBitMask == PhysicsCategory.wall) ||
           (bodyA.categoryBitMask == PhysicsCategory.wall && bodyB.categoryBitMask == PhysicsCategory.playerBullet) ||
           (bodyA.categoryBitMask == PhysicsCategory.enemyBullet && bodyB.categoryBitMask == PhysicsCategory.wall) ||
           (bodyA.categoryBitMask == PhysicsCategory.wall && bodyB.categoryBitMask == PhysicsCategory.enemyBullet) {
            
            let bullet = (bodyA.categoryBitMask == PhysicsCategory.playerBullet || bodyA.categoryBitMask == PhysicsCategory.enemyBullet) ? bodyA.node as? Bullet : bodyB.node as? Bullet
            
            bullet?.hitWall()
        }
    }
}
