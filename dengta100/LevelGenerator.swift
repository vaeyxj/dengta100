//
//  LevelGenerator.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import UIKit

class LevelGenerator {
    
    static func generateMultiFloorLevel(scene: GameScene, floorNumber: Int) {
        // 清除现有场景
        scene.removeAllChildren()
        
        // 设置场景背景
        setupBackground(scene: scene)
        
        // 生成多层建筑布局
        generateBuildingLayout(scene: scene, floorNumber: floorNumber)
        
        // 添加楼梯
        addStairs(scene: scene)
        
        // 添加家具和装饰
        addFurniture(scene: scene)
        
        // 添加敌人
        addEnemies(scene: scene, floorNumber: floorNumber)
        
        // 添加道具
        addItems(scene: scene)
    }
    
    private static func setupBackground(scene: GameScene) {
        // 创建明显的背景色，确保可见
        let background = SKShapeNode(rect: CGRect(
            x: -scene.size.width/2,
            y: -scene.size.height/2,
            width: scene.size.width,
            height: scene.size.height
        ))
        background.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)  // 更明显的蓝灰色
        background.strokeColor = .clear
        background.zPosition = -10
        background.name = "background"
        scene.addChild(background)
    }
    
    private static func generateBuildingLayout(scene: GameScene, floorNumber: Int) {
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        
        // 创建外墙边界
        createOuterWalls(scene: scene)
        
        // 创建四个房间区域 - 调整尺寸和位置
        createRoom(scene: scene, 
                  position: CGPoint(x: -screenWidth/3, y: screenHeight/3),
                  size: CGSize(width: screenWidth/3 - 20, height: screenHeight/3 - 20),
                  roomType: .livingRoom)
        
        createRoom(scene: scene,
                  position: CGPoint(x: screenWidth/3, y: screenHeight/3),
                  size: CGSize(width: screenWidth/3 - 20, height: screenHeight/3 - 20),
                  roomType: .bedroom)
        
        createRoom(scene: scene,
                  position: CGPoint(x: -screenWidth/3, y: -screenHeight/3),
                  size: CGSize(width: screenWidth/3 - 20, height: screenHeight/3 - 20),
                  roomType: .kitchen)
        
        createRoom(scene: scene,
                  position: CGPoint(x: screenWidth/3, y: -screenHeight/3),
                  size: CGSize(width: screenWidth/3 - 20, height: screenHeight/3 - 20),
                  roomType: .storage)
        
        // 添加中央走廊
        createCorridor(scene: scene)
    }
    
    private static func createOuterWalls(scene: GameScene) {
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        let wallThickness: CGFloat = 12
        let wallColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        
        // 上墙
        let topWall = SKShapeNode(rect: CGRect(
            x: -screenWidth/2,
            y: screenHeight/2 - wallThickness,
            width: screenWidth,
            height: wallThickness
        ))
        topWall.fillColor = wallColor
        topWall.strokeColor = .clear
        topWall.zPosition = 2
        topWall.name = "outerWall"
        topWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: screenWidth, height: wallThickness))
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(topWall)
        
        // 下墙
        let bottomWall = SKShapeNode(rect: CGRect(
            x: -screenWidth/2,
            y: -screenHeight/2,
            width: screenWidth,
            height: wallThickness
        ))
        bottomWall.fillColor = wallColor
        bottomWall.strokeColor = .clear
        bottomWall.zPosition = 2
        bottomWall.name = "outerWall"
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: screenWidth, height: wallThickness))
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(bottomWall)
        
        // 左墙
        let leftWall = SKShapeNode(rect: CGRect(
            x: -screenWidth/2,
            y: -screenHeight/2,
            width: wallThickness,
            height: screenHeight
        ))
        leftWall.fillColor = wallColor
        leftWall.strokeColor = .clear
        leftWall.zPosition = 2
        leftWall.name = "outerWall"
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: screenHeight))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(leftWall)
        
        // 右墙
        let rightWall = SKShapeNode(rect: CGRect(
            x: screenWidth/2 - wallThickness,
            y: -screenHeight/2,
            width: wallThickness,
            height: screenHeight
        ))
        rightWall.fillColor = wallColor
        rightWall.strokeColor = .clear
        rightWall.zPosition = 2
        rightWall.name = "outerWall"
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: screenHeight))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(rightWall)
    }
    
    private static func createRoom(scene: GameScene, position: CGPoint, size: CGSize, roomType: RoomType) {
        // 房间地板
        let floor = SKShapeNode(rect: CGRect(
            x: -size.width/2,
            y: -size.height/2,
            width: size.width,
            height: size.height
        ))
        floor.fillColor = getRoomFloorColor(roomType: roomType)
        floor.strokeColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        floor.lineWidth = 2
        floor.position = position
        floor.zPosition = 1
        floor.name = "floor_\(roomType.rawValue)"
        scene.addChild(floor)
        
        // 房间墙壁
        createWalls(scene: scene, roomPosition: position, roomSize: size, roomType: roomType)
    }
    
    private static func createWalls(scene: GameScene, roomPosition: CGPoint, roomSize: CGSize, roomType: RoomType) {
        let wallThickness: CGFloat = 6
        let wallColor = UIColor(red: 0.35, green: 0.35, blue: 0.4, alpha: 1.0)
        let doorWidth: CGFloat = 40
        
        // 上墙 - 根据房间类型决定是否有门
        if roomType == .livingRoom || roomType == .bedroom {
            // 上方房间不需要上墙（连接走廊）
        } else {
            let topWall = SKShapeNode(rect: CGRect(
                x: -roomSize.width/2,
                y: roomSize.height/2 - wallThickness,
                width: roomSize.width,
                height: wallThickness
            ))
            topWall.fillColor = wallColor
            topWall.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            topWall.lineWidth = 1
            topWall.position = roomPosition
            topWall.zPosition = 3
            topWall.name = "roomWall"
            topWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: roomSize.width, height: wallThickness))
            topWall.physicsBody?.isDynamic = false
            topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            scene.addChild(topWall)
        }
        
        // 下墙 - 根据房间类型决定是否有门
        if roomType == .kitchen || roomType == .storage {
            // 下方房间不需要下墙（连接走廊）
        } else {
            let bottomWall = SKShapeNode(rect: CGRect(
                x: -roomSize.width/2,
                y: -roomSize.height/2,
                width: roomSize.width,
                height: wallThickness
            ))
            bottomWall.fillColor = wallColor
            bottomWall.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            bottomWall.lineWidth = 1
            bottomWall.position = roomPosition
            bottomWall.zPosition = 3
            bottomWall.name = "roomWall"
            bottomWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: roomSize.width, height: wallThickness))
            bottomWall.physicsBody?.isDynamic = false
            bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            scene.addChild(bottomWall)
        }
        
        // 左墙 - 根据房间类型决定是否有门
        if roomType == .livingRoom || roomType == .kitchen {
            // 左侧房间不需要左墙（连接走廊）
        } else {
            let leftWall = SKShapeNode(rect: CGRect(
                x: -roomSize.width/2,
                y: -roomSize.height/2,
                width: wallThickness,
                height: roomSize.height
            ))
            leftWall.fillColor = wallColor
            leftWall.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            leftWall.lineWidth = 1
            leftWall.position = roomPosition
            leftWall.zPosition = 3
            leftWall.name = "roomWall"
            leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: roomSize.height))
            leftWall.physicsBody?.isDynamic = false
            leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            scene.addChild(leftWall)
        }
        
        // 右墙 - 根据房间类型决定是否有门
        if roomType == .bedroom || roomType == .storage {
            // 右侧房间不需要右墙（连接走廊）
        } else {
            let rightWall = SKShapeNode(rect: CGRect(
                x: roomSize.width/2 - wallThickness,
                y: -roomSize.height/2,
                width: wallThickness,
                height: roomSize.height
            ))
            rightWall.fillColor = wallColor
            rightWall.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            rightWall.lineWidth = 1
            rightWall.position = roomPosition
            rightWall.zPosition = 3
            rightWall.name = "roomWall"
            rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: roomSize.height))
            rightWall.physicsBody?.isDynamic = false
            rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            scene.addChild(rightWall)
        }
    }
    
    private static func createCorridor(scene: GameScene) {
        let corridorWidth: CGFloat = 60
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        
        // 垂直走廊（中央）
        let verticalCorridor = SKShapeNode(rect: CGRect(
            x: -corridorWidth/2,
            y: -screenHeight/2 + 12,
            width: corridorWidth,
            height: screenHeight - 24
        ))
        verticalCorridor.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        verticalCorridor.strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
        verticalCorridor.lineWidth = 2
        verticalCorridor.zPosition = 1
        verticalCorridor.name = "corridor"
        scene.addChild(verticalCorridor)
        
        // 水平走廊（中央）
        let horizontalCorridor = SKShapeNode(rect: CGRect(
            x: -screenWidth/2 + 12,
            y: -corridorWidth/2,
            width: screenWidth - 24,
            height: corridorWidth
        ))
        horizontalCorridor.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        horizontalCorridor.strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
        horizontalCorridor.lineWidth = 2
        horizontalCorridor.zPosition = 1
        horizontalCorridor.name = "corridor"
        scene.addChild(horizontalCorridor)
    }
    
    private static func addStairs(scene: GameScene) {
        // 中央楼梯
        let stairWidth: CGFloat = 60
        let stairHeight: CGFloat = 100
        
        let stairs = SKShapeNode(rect: CGRect(
            x: -stairWidth/2,
            y: -stairHeight/2,
            width: stairWidth,
            height: stairHeight
        ))
        stairs.fillColor = UIColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        stairs.strokeColor = UIColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 1.0)
        stairs.lineWidth = 2
        stairs.position = CGPoint(x: 0, y: 0)
        stairs.zPosition = 3
        stairs.name = "stairs"
        
        // 添加物理体用于检测碰撞
        stairs.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: stairWidth, height: stairHeight))
        stairs.physicsBody?.isDynamic = false
        stairs.physicsBody?.categoryBitMask = PhysicsCategory.item
        stairs.physicsBody?.contactTestBitMask = PhysicsCategory.player
        stairs.physicsBody?.collisionBitMask = 0 // 不产生物理碰撞，只检测接触
        
        scene.addChild(stairs)
        
        // 添加楼梯台阶效果
        for i in 0..<8 {
            let step = SKShapeNode(rect: CGRect(
                x: -stairWidth/2 + 5,
                y: -stairHeight/2 + CGFloat(i) * 12,
                width: stairWidth - 10,
                height: 2
            ))
            step.fillColor = UIColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
            step.strokeColor = .clear
            step.position = CGPoint(x: 0, y: 0)
            step.zPosition = 4
            step.name = "step"
            scene.addChild(step)
        }
        
        // 添加楼梯指示标志
        let arrow = SKLabelNode(text: "↑")
        arrow.fontName = "Arial-Bold"
        arrow.fontSize = 20
        arrow.fontColor = .yellow
        arrow.position = CGPoint(x: 0, y: 60)
        arrow.zPosition = 5
        arrow.name = "stairArrow"
        
        // 添加闪烁效果
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        arrow.run(SKAction.repeatForever(pulse))
        
        scene.addChild(arrow)
    }
    
    private static func addFurniture(scene: GameScene) {
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        
        // 客厅家具 - 左上角
        addSofa(scene: scene, position: CGPoint(x: -screenWidth/3 - 30, y: screenHeight/3 + 20))
        addTable(scene: scene, position: CGPoint(x: -screenWidth/3 + 20, y: screenHeight/3 - 10))
        
        // 卧室家具 - 右上角
        addBed(scene: scene, position: CGPoint(x: screenWidth/3 + 20, y: screenHeight/3 + 30))
        addDesk(scene: scene, position: CGPoint(x: screenWidth/3 - 30, y: screenHeight/3 - 20))
        
        // 厨房家具 - 左下角
        addKitchenCounter(scene: scene, position: CGPoint(x: -screenWidth/3 + 30, y: -screenHeight/3 + 30))
        addStove(scene: scene, position: CGPoint(x: -screenWidth/3 - 20, y: -screenHeight/3 + 30))
        
        // 储藏室箱子 - 右下角
        addStorageBoxes(scene: scene, position: CGPoint(x: screenWidth/3, y: -screenHeight/3))
    }
    
    private static func addSofa(scene: GameScene, position: CGPoint) {
        let sofa = SKShapeNode(rect: CGRect(x: -30, y: -15, width: 60, height: 30))
        sofa.fillColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        sofa.strokeColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        sofa.lineWidth = 2
        sofa.position = position
        sofa.zPosition = 3
        sofa.name = "furniture"
        sofa.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 30))
        sofa.physicsBody?.isDynamic = false
        sofa.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(sofa)
    }
    
    private static func addTable(scene: GameScene, position: CGPoint) {
        let table = SKShapeNode(rect: CGRect(x: -25, y: -15, width: 50, height: 30))
        table.fillColor = UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        table.strokeColor = UIColor(red: 0.4, green: 0.2, blue: 0.05, alpha: 1.0)
        table.lineWidth = 2
        table.position = position
        table.zPosition = 3
        table.name = "furniture"
        table.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 30))
        table.physicsBody?.isDynamic = false
        table.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(table)
    }
    
    private static func addBed(scene: GameScene, position: CGPoint) {
        let bed = SKShapeNode(rect: CGRect(x: -40, y: -20, width: 80, height: 40))
        bed.fillColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
        bed.strokeColor = UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
        bed.lineWidth = 2
        bed.position = position
        bed.zPosition = 3
        bed.name = "furniture"
        bed.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 40))
        bed.physicsBody?.isDynamic = false
        bed.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(bed)
    }
    
    private static func addDesk(scene: GameScene, position: CGPoint) {
        let desk = SKShapeNode(rect: CGRect(x: -30, y: -15, width: 60, height: 30))
        desk.fillColor = UIColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0)
        desk.strokeColor = UIColor(red: 0.3, green: 0.15, blue: 0.05, alpha: 1.0)
        desk.lineWidth = 2
        desk.position = position
        desk.zPosition = 3
        desk.name = "furniture"
        desk.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 30))
        desk.physicsBody?.isDynamic = false
        desk.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(desk)
    }
    
    private static func addKitchenCounter(scene: GameScene, position: CGPoint) {
        let counter = SKShapeNode(rect: CGRect(x: -35, y: -15, width: 70, height: 30))
        counter.fillColor = UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        counter.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        counter.lineWidth = 2
        counter.position = position
        counter.zPosition = 3
        counter.name = "furniture"
        counter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 30))
        counter.physicsBody?.isDynamic = false
        counter.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(counter)
    }
    
    private static func addStove(scene: GameScene, position: CGPoint) {
        let stove = SKShapeNode(rect: CGRect(x: -20, y: -15, width: 40, height: 30))
        stove.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        stove.strokeColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        stove.lineWidth = 2
        stove.position = position
        stove.zPosition = 3
        stove.name = "furniture"
        stove.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 30))
        stove.physicsBody?.isDynamic = false
        stove.physicsBody?.categoryBitMask = PhysicsCategory.wall
        scene.addChild(stove)
    }
    
    private static func addStorageBoxes(scene: GameScene, position: CGPoint) {
        let positions = [
            CGPoint(x: position.x - 40, y: position.y + 30),
            CGPoint(x: position.x + 40, y: position.y + 30),
            CGPoint(x: position.x - 40, y: position.y - 30),
            CGPoint(x: position.x + 40, y: position.y - 30)
        ]
        
        for boxPosition in positions {
            let box = SKShapeNode(rect: CGRect(x: -15, y: -15, width: 30, height: 30))
            box.fillColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
            box.strokeColor = UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0)
            box.lineWidth = 2
            box.position = boxPosition
            box.zPosition = 3
            box.name = "furniture"
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
            box.physicsBody?.isDynamic = false
            box.physicsBody?.categoryBitMask = PhysicsCategory.wall
            scene.addChild(box)
        }
    }
    
    private static func addEnemies(scene: GameScene, floorNumber: Int) {
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height
        
        // 在各个房间中分布敌人
        let enemyPositions = [
            // 客厅敌人
            CGPoint(x: -screenWidth/3 + 40, y: screenHeight/3 - 40),
            // 卧室敌人
            CGPoint(x: screenWidth/3 - 40, y: screenHeight/3 + 40),
            // 厨房敌人
            CGPoint(x: -screenWidth/3 - 40, y: -screenHeight/3 - 40),
            // 储藏室敌人
            CGPoint(x: screenWidth/3 + 40, y: -screenHeight/3 - 40),
            // 走廊敌人
            CGPoint(x: 0, y: screenHeight/4)
        ]
        
        for (index, position) in enemyPositions.enumerated() {
            let enemyType: EnemyType
            switch floorNumber {
            case 1...5:
                enemyType = .slime
            case 6...10:
                enemyType = index % 2 == 0 ? .slime : .skeleton
            case 11...20:
                let types: [EnemyType] = [.slime, .skeleton, .mage]
                enemyType = types[index % types.count]
            default:
                let types: [EnemyType] = [.slime, .skeleton, .mage, .dragon, .assassin]
                enemyType = types.randomElement() ?? .slime
            }
            
            let enemy = Enemy(type: enemyType, level: floorNumber)
            enemy.position = position
            scene.addChild(enemy)
            scene.enemies.append(enemy)
        }
    }
    
    private static func addItems(scene: GameScene) {
        // 添加一些道具
        let itemPositions = [
            CGPoint(x: -100, y: 200),
            CGPoint(x: 100, y: -200),
            CGPoint(x: 150, y: 100)
        ]
        
        for position in itemPositions {
            let item = createHealthPotion(position: position)
            scene.addChild(item)
        }
    }
    
    private static func createHealthPotion(position: CGPoint) -> SKSpriteNode {
        let potion = SKSpriteNode(color: .red, size: CGSize(width: 16, height: 16))
        potion.position = position
        potion.zPosition = 4
        potion.name = "healthPotion"
        
        // 添加闪烁效果
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 1.0)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        potion.run(SKAction.repeatForever(pulse))
        
        return potion
    }
    
    private static func getRoomFloorColor(roomType: RoomType) -> UIColor {
        switch roomType {
        case .livingRoom:
            return UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0) // 木地板
        case .bedroom:
            return UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0) // 地毯
        case .kitchen:
            return UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0) // 瓷砖
        case .storage:
            return UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // 水泥地
        }
    }
}

enum RoomType: String, CaseIterable {
    case livingRoom = "living"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case storage = "storage"
} 