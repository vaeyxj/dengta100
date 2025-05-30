//
//  VirtualJoystick.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import UIKit

protocol VirtualJoystickDelegate: AnyObject {
    func joystickDidMove(direction: CGVector)
    func joystickDidStop()
}

class VirtualJoystick: SKNode {
    
    // MARK: - 属性
    weak var delegate: VirtualJoystickDelegate?
    
    private var baseNode: SKShapeNode!
    private var knobNode: SKShapeNode!
    private var isTracking: Bool = false
    private var knobRadius: CGFloat = 30
    private var baseRadius: CGFloat = 60
    
    // 可自定义属性
    var joystickRadius: CGFloat {
        get { return baseRadius }
        set {
            baseRadius = newValue
            knobRadius = newValue * 0.5
            setupJoystick()
        }
    }
    
    override var alpha: CGFloat {
        get { return super.alpha }
        set {
            super.alpha = newValue
            baseNode?.alpha = newValue
            knobNode?.alpha = newValue
        }
    }
    
    // MARK: - 初始化
    override init() {
        super.init()
        setupJoystick()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupJoystick()
    }
    
    private func setupJoystick() {
        // 移除旧的节点
        removeAllChildren()
        
        // 创建底座
        baseNode = SKShapeNode(circleOfRadius: baseRadius)
        baseNode.fillColor = UIColor.white.withAlphaComponent(0.3)
        baseNode.strokeColor = UIColor.white.withAlphaComponent(0.6)
        baseNode.lineWidth = 2
        baseNode.zPosition = 1
        addChild(baseNode)
        
        // 创建摇杆
        knobNode = SKShapeNode(circleOfRadius: knobRadius)
        knobNode.fillColor = UIColor.white.withAlphaComponent(0.8)
        knobNode.strokeColor = UIColor.white
        knobNode.lineWidth = 2
        knobNode.zPosition = 2
        addChild(knobNode)
        
        // 设置初始透明度
        self.alpha = alpha
        
        // 设置用户交互
        isUserInteractionEnabled = true
    }
    
    // MARK: - 触摸处理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 检查触摸是否在摇杆范围内
        let distance = sqrt(location.x * location.x + location.y * location.y)
        if distance <= baseRadius {
            isTracking = true
            updateKnobPosition(location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTracking, let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateKnobPosition(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopTracking()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopTracking()
    }
    
    private func updateKnobPosition(_ location: CGPoint) {
        let distance = sqrt(location.x * location.x + location.y * location.y)
        
        var knobPosition = location
        
        // 限制摇杆在底座范围内
        if distance > baseRadius {
            let angle = atan2(location.y, location.x)
            knobPosition = CGPoint(
                x: cos(angle) * baseRadius,
                y: sin(angle) * baseRadius
            )
        }
        
        // 更新摇杆位置
        knobNode.position = knobPosition
        
        // 计算方向向量
        let normalizedDistance = min(distance, baseRadius) / baseRadius
        let direction = CGVector(
            dx: knobPosition.x / baseRadius,
            dy: knobPosition.y / baseRadius
        )
        
        // 通知代理
        delegate?.joystickDidMove(direction: direction)
        
        // 添加触觉反馈
        if normalizedDistance > 0.8 {
            addHapticFeedback()
        }
    }
    
    private func stopTracking() {
        isTracking = false
        
        // 摇杆回到中心
        let resetAction = SKAction.move(to: CGPoint.zero, duration: 0.2)
        resetAction.timingMode = .easeOut
        knobNode.run(resetAction)
        
        // 通知代理停止移动
        delegate?.joystickDidStop()
    }
    
    private func addHapticFeedback() {
        // 添加轻微的触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - 公共方法
    func setPosition(_ position: CGPoint, in scene: SKScene) {
        self.position = position
    }
    
    func show() {
        isHidden = false
        alpha = 0
        run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
    }
    
    func hide() {
        run(SKAction.fadeOut(withDuration: 0.3)) {
            self.isHidden = true
        }
    }
}

// MARK: - 射击控制区域
class ShootingArea: SKNode {
    
    // MARK: - 属性
    weak var delegate: ShootingAreaDelegate?
    
    private var shootingZone: SKShapeNode!
    private var isShooting: Bool = false
    private var shootingTimer: Timer?
    
    var isAutoFire: Bool = false
    var autoFireRate: TimeInterval = 0.3
    
    // MARK: - 初始化
    override init() {
        super.init()
        setupShootingArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShootingArea()
    }
    
    private func setupShootingArea() {
        // 创建射击区域（右半屏幕）
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        shootingZone = SKShapeNode(rect: CGRect(
            x: 0,
            y: -screenHeight/2,
            width: screenWidth/2,
            height: screenHeight
        ))
        shootingZone.fillColor = UIColor.clear
        shootingZone.strokeColor = UIColor.clear
        shootingZone.zPosition = 0
        addChild(shootingZone)
        
        // 设置用户交互
        isUserInteractionEnabled = true
    }
    
    // MARK: - 触摸处理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: parent!)
        
        isShooting = true
        delegate?.didStartShooting(at: location)
        
        // 如果开启自动射击
        if isAutoFire {
            startAutoFire(target: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isShooting, let touch = touches.first else { return }
        let location = touch.location(in: parent!)
        
        delegate?.didUpdateShootingTarget(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopShooting()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopShooting()
    }
    
    private func stopShooting() {
        isShooting = false
        stopAutoFire()
        delegate?.didStopShooting()
    }
    
    private func startAutoFire(target: CGPoint) {
        stopAutoFire()
        
        shootingTimer = Timer.scheduledTimer(withTimeInterval: autoFireRate, repeats: true) { _ in
            if self.isShooting {
                self.delegate?.didAutoFire(at: target)
            }
        }
    }
    
    private func stopAutoFire() {
        shootingTimer?.invalidate()
        shootingTimer = nil
    }
}

// MARK: - 射击区域代理
protocol ShootingAreaDelegate: AnyObject {
    func didStartShooting(at location: CGPoint)
    func didUpdateShootingTarget(_ location: CGPoint)
    func didStopShooting()
    func didAutoFire(at location: CGPoint)
} 