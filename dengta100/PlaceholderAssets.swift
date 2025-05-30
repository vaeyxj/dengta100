//
//  PlaceholderAssets.swift
//  dengta100
//
//  Created by AI Assistant on 2024.
//

import SpriteKit
import UIKit

class PlaceholderAssets {
    
    static func createPlayerTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // 绘制玩家角色（蓝色圆形）
            context.cgContext.setFillColor(UIColor.blue.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            // 添加眼睛
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: 8, y: 20, width: 6, height: 6))
            context.cgContext.fillEllipse(in: CGRect(x: 18, y: 20, width: 6, height: 6))
            
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: 10, y: 22, width: 2, height: 2))
            context.cgContext.fillEllipse(in: CGRect(x: 20, y: 22, width: 2, height: 2))
        }
        
        return SKTexture(image: image)
    }
    
    static func createEnemyTexture(type: EnemyType) -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let color: UIColor
            switch type {
            case .slime:
                color = .green
            case .skeleton:
                color = .lightGray
            case .mage:
                color = .purple
            case .dragon:
                color = .red
            case .assassin:
                color = .darkGray
            }
            
            // 绘制敌人形状
            context.cgContext.setFillColor(color.cgColor)
            
            switch type {
            case .slime:
                // 史莱姆 - 椭圆形
                context.cgContext.fillEllipse(in: CGRect(x: 4, y: 8, width: 24, height: 20))
            case .skeleton, .assassin:
                // 骷髅/刺客 - 人形
                context.cgContext.fill(CGRect(x: 12, y: 8, width: 8, height: 16)) // 身体
                context.cgContext.fillEllipse(in: CGRect(x: 10, y: 20, width: 12, height: 12)) // 头
            case .mage:
                // 法师 - 三角形帽子
                context.cgContext.fill(CGRect(x: 12, y: 8, width: 8, height: 16)) // 身体
                context.cgContext.fillEllipse(in: CGRect(x: 10, y: 18, width: 12, height: 12)) // 头
                // 帽子
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 16, y: 30))
                path.addLine(to: CGPoint(x: 8, y: 4))
                path.addLine(to: CGPoint(x: 24, y: 4))
                path.close()
                context.cgContext.addPath(path.cgPath)
                context.cgContext.fillPath()
            case .dragon:
                // 巨龙 - 大型矩形
                context.cgContext.fill(CGRect(x: 2, y: 6, width: 28, height: 20))
                // 翅膀
                context.cgContext.fillEllipse(in: CGRect(x: 0, y: 10, width: 8, height: 12))
                context.cgContext.fillEllipse(in: CGRect(x: 24, y: 10, width: 8, height: 12))
            }
            
            // 添加眼睛
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: 12, y: 22, width: 3, height: 3))
            context.cgContext.fillEllipse(in: CGRect(x: 17, y: 22, width: 3, height: 3))
        }
        
        return SKTexture(image: image)
    }
    
    static func createBulletTexture() -> SKTexture {
        let size = CGSize(width: 4, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.yellow.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        
        return SKTexture(image: image)
    }
    
    static func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        
        return SKTexture(image: image)
    }
}

// MARK: - 扩展SKTexture以支持占位符
extension SKTexture {
    convenience init(imageNamed name: String) {
        // 如果找不到图片资源，使用占位符
        if let image = UIImage(named: name) {
            self.init(image: image)
        } else {
            // 根据名称生成对应的占位符
            if name.contains("player") {
                let image = PlaceholderAssets.createPlayerTexture()
                self.init(cgImage: image.cgImage())
            } else if name.contains("bullet") {
                let image = PlaceholderAssets.createBulletTexture()
                self.init(cgImage: image.cgImage())
            } else if name.contains("spark") {
                let image = PlaceholderAssets.createSparkTexture()
                self.init(cgImage: image.cgImage())
            } else if name.contains("slime") {
                let image = PlaceholderAssets.createEnemyTexture(type: .slime)
                self.init(cgImage: image.cgImage())
            } else if name.contains("skeleton") {
                let image = PlaceholderAssets.createEnemyTexture(type: .skeleton)
                self.init(cgImage: image.cgImage())
            } else if name.contains("mage") {
                let image = PlaceholderAssets.createEnemyTexture(type: .mage)
                self.init(cgImage: image.cgImage())
            } else if name.contains("dragon") {
                let image = PlaceholderAssets.createEnemyTexture(type: .dragon)
                self.init(cgImage: image.cgImage())
            } else if name.contains("assassin") {
                let image = PlaceholderAssets.createEnemyTexture(type: .assassin)
                self.init(cgImage: image.cgImage())
            } else {
                // 默认占位符
                let size = CGSize(width: 32, height: 32)
                let renderer = UIGraphicsImageRenderer(size: size)
                let image = renderer.image { context in
                    context.cgContext.setFillColor(UIColor.gray.cgColor)
                    context.cgContext.fill(CGRect(origin: .zero, size: size))
                }
                self.init(image: image)
            }
        }
    }
} 